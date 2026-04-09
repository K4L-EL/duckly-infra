terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    subscription_id      = "ce9f377e-cfe1-4360-aae4-e40f72ce1280"
    resource_group_name  = "duckly-tfstate-rg"
    storage_account_name = "ducklytfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ce9f377e-cfe1-4360-aae4-e40f72ce1280"
}

locals {
  prefix = "${var.project_name}-${var.environment}"
  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ─────────────────────────────────────────────
# Resource Group
# ─────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

# ─────────────────────────────────────────────
# Container Registry
# ─────────────────────────────────────────────
resource "azurerm_container_registry" "acr" {
  name                = replace("${local.prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

# ─────────────────────────────────────────────
# PostgreSQL Flexible Server
# ─────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${local.prefix}-db"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "16"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  sku_name               = var.db_sku
  storage_mb             = var.db_storage_mb
  zone                   = "2"

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  tags = local.tags
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "${var.project_name}_${var.environment}"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ─────────────────────────────────────────────
# Blob Storage (replaces MinIO)
# ─────────────────────────────────────────────
resource "azurerm_storage_account" "blob" {
  name                            = replace("${local.prefix}storage", "-", "")
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
  tags                            = local.tags
}

resource "azurerm_storage_container" "images" {
  name                  = "duckly-images"
  storage_account_name  = azurerm_storage_account.blob.name
  container_access_type = "blob"
}

# ─────────────────────────────────────────────
# App Service Plan (shared by backend + dashboard)
# ─────────────────────────────────────────────
resource "azurerm_service_plan" "main" {
  name                = "${local.prefix}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_sku
  tags                = local.tags
}

# ─────────────────────────────────────────────
# Backend API (.NET 8)
# ─────────────────────────────────────────────
resource "azurerm_linux_web_app" "backend" {
  name                = "${local.prefix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = local.tags

  site_config {
    always_on                               = var.app_sku == "F1" ? false : true
    container_registry_use_managed_identity = false
    health_check_path                       = "/health"

    application_stack {
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
      docker_image_name        = "duckly-backend:latest"
    }

    cors {
      allowed_origins = compact([
        "https://${local.prefix}-dashboard.azurewebsites.net",
        var.landing_url,
        var.dashboard_custom_domain != "" ? "https://${var.dashboard_custom_domain}" : "",
        var.backend_custom_domain != "" ? "https://${var.backend_custom_domain}" : "",
      ])
      support_credentials = true
    }
  }

  app_settings = {
    ASPNETCORE_ENVIRONMENT              = var.environment == "production" ? "Production" : "Development"
    WEBSITES_PORT                       = "8080"
    WEBSITES_CONTAINER_START_TIME_LIMIT = "300"

    ConnectionStrings__DefaultConnection = "Host=${azurerm_postgresql_flexible_server.db.fqdn};Port=5432;Database=${azurerm_postgresql_flexible_server_database.app.name};Username=${var.db_admin_username};Password=${var.db_admin_password};SSL Mode=Require;Trust Server Certificate=true"

    Jwt__Secret      = var.jwt_secret
    Jwt__Issuer      = "duckly-backend"
    Jwt__Audience    = "duckly-frontend"
    Jwt__ExpiryHours = "24"

    Storage__Endpoint   = azurerm_storage_account.blob.primary_blob_endpoint
    Storage__AccessKey  = azurerm_storage_account.blob.primary_access_key
    Storage__SecretKey  = azurerm_storage_account.blob.primary_access_key
    Storage__BucketName = azurerm_storage_container.images.name
    Storage__UseSSL     = "true"
    Storage__Provider   = "azure"

    Stripe__SecretKey     = var.stripe_secret_key
    Stripe__WebhookSecret = var.stripe_webhook_secret

    ALLOWED_ORIGINS = join(",", compact([
      "https://${local.prefix}-dashboard.azurewebsites.net",
      var.landing_url,
      var.dashboard_custom_domain != "" ? "https://${var.dashboard_custom_domain}" : "",
    ]))
  }
}

# ─────────────────────────────────────────────
# Dashboard SPA (Vite + Nginx)
# ─────────────────────────────────────────────
resource "azurerm_linux_web_app" "dashboard" {
  name                = "${local.prefix}-dashboard"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = local.tags

  site_config {
    always_on                               = var.app_sku == "F1" ? false : true
    container_registry_use_managed_identity = false

    application_stack {
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
      docker_image_name        = "duckly-dashboard:latest"
    }
  }

  app_settings = {
    WEBSITES_PORT                       = "80"
    WEBSITES_CONTAINER_START_TIME_LIMIT = "120"
  }
}

# ─────────────────────────────────────────────
# Custom Domains (optional)
# ─────────────────────────────────────────────
resource "azurerm_app_service_custom_hostname_binding" "backend_custom" {
  count               = var.backend_custom_domain != "" ? 1 : 0
  hostname            = var.backend_custom_domain
  app_service_name    = azurerm_linux_web_app.backend.name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_app_service_custom_hostname_binding" "dashboard_custom" {
  count               = var.dashboard_custom_domain != "" ? 1 : 0
  hostname            = var.dashboard_custom_domain
  app_service_name    = azurerm_linux_web_app.dashboard.name
  resource_group_name = azurerm_resource_group.main.name
}
