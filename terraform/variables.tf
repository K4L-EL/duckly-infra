variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "duckly"
}

variable "environment" {
  description = "Deployment environment (staging, production)"
  type        = string
  default     = "production"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

# ── Database ──

variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "ducklyadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "db_sku" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B2s"
}

variable "db_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

# ── Auth ──

variable "jwt_secret" {
  description = "JWT signing secret (min 32 chars)"
  type        = string
  sensitive   = true
}

# ── Stripe ──

variable "stripe_secret_key" {
  description = "Stripe secret key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "stripe_webhook_secret" {
  description = "Stripe webhook secret"
  type        = string
  sensitive   = true
  default     = ""
}

# ── App Service ──

variable "app_sku" {
  description = "App Service Plan SKU (B1, P1v3, etc.)"
  type        = string
  default     = "B1"
}

# ── URLs ──

variable "landing_url" {
  description = "Landing page URL (Vercel)"
  type        = string
  default     = "https://duckly-landing.vercel.app"
}

variable "vite_mapbox_token" {
  description = "Mapbox public token for dashboard map"
  type        = string
  default     = ""
}

# ── Custom Domains (optional) ──

variable "backend_custom_domain" {
  description = "Custom domain for the backend API (optional)"
  type        = string
  default     = ""
}

variable "dashboard_custom_domain" {
  description = "Custom domain for the dashboard (optional)"
  type        = string
  default     = ""
}
