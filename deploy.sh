#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --service <backend|dashboard|all> [--env production]"
  echo ""
  echo "Builds and pushes Docker images to ACR, then deploys to Azure App Service."
  echo ""
  echo "Prerequisites:"
  echo "  - Azure CLI logged in (az login)"
  echo "  - ACR credentials available (terraform output)"
  echo ""
  echo "Examples:"
  echo "  $0 --service backend"
  echo "  $0 --service dashboard"
  echo "  $0 --service all"
  exit 1
}

SERVICE=""
ENV="production"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service|-s) SERVICE="$2"; shift 2;;
    --env|-e) ENV="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

[[ -n "$SERVICE" ]] || usage

PREFIX="duckly-${ENV}"
RG="${PREFIX}-rg"

require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }; }
require_cmd az
require_cmd docker
require_cmd git

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "WARNING: Uncommitted changes present."
  read -rp "Continue anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

SHA=$(git rev-parse --short=12 HEAD)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

ACR_SERVER=$(cd terraform && terraform output -raw acr_login_server 2>/dev/null || echo "")
if [[ -z "$ACR_SERVER" ]]; then
  echo "Could not read ACR login server from Terraform outputs."
  echo "Make sure you've run 'terraform apply' first."
  exit 1
fi

echo "Logging in to ACR: ${ACR_SERVER}..."
az acr login --name "${ACR_SERVER%%.*}"

deploy_backend() {
  local IMAGE="${ACR_SERVER}/duckly-backend"
  local TAG="${TIMESTAMP}-${SHA}"

  echo ""
  echo "Building backend image..."
  docker build \
    -t "${IMAGE}:${TAG}" \
    -t "${IMAGE}:latest" \
    ./duckly-backend

  echo "Pushing backend image..."
  docker push "${IMAGE}:${TAG}"
  docker push "${IMAGE}:latest"

  echo "Deploying backend to App Service..."
  az webapp config container set \
    --resource-group "$RG" \
    --name "${PREFIX}-api" \
    --docker-custom-image-name "${IMAGE}:${TAG}" \
    --docker-registry-server-url "https://${ACR_SERVER}" \
    --output none

  az webapp restart --resource-group "$RG" --name "${PREFIX}-api" --output none

  echo "Backend deployed: ${IMAGE}:${TAG}"
}

deploy_dashboard() {
  local IMAGE="${ACR_SERVER}/duckly-dashboard"
  local TAG="${TIMESTAMP}-${SHA}"
  local BACKEND_URL
  BACKEND_URL=$(cd terraform && terraform output -raw backend_url 2>/dev/null || echo "https://${PREFIX}-api.azurewebsites.net")

  echo ""
  echo "Building dashboard image..."
  docker build \
    --build-arg VITE_API_BASE_URL="${BACKEND_URL}" \
    --build-arg VITE_MAPBOX_TOKEN="${VITE_MAPBOX_TOKEN:-}" \
    -t "${IMAGE}:${TAG}" \
    -t "${IMAGE}:latest" \
    ./duckly-dashboard

  echo "Pushing dashboard image..."
  docker push "${IMAGE}:${TAG}"
  docker push "${IMAGE}:latest"

  echo "Deploying dashboard to App Service..."
  az webapp config container set \
    --resource-group "$RG" \
    --name "${PREFIX}-dashboard" \
    --docker-custom-image-name "${IMAGE}:${TAG}" \
    --docker-registry-server-url "https://${ACR_SERVER}" \
    --output none

  az webapp restart --resource-group "$RG" --name "${PREFIX}-dashboard" --output none

  echo "Dashboard deployed: ${IMAGE}:${TAG}"
}

case "$SERVICE" in
  backend)   deploy_backend;;
  dashboard) deploy_dashboard;;
  all)       deploy_backend; deploy_dashboard;;
  *)         echo "Unknown service: $SERVICE"; usage;;
esac

echo ""
echo "Deployment complete (${SERVICE}) — ${TIMESTAMP}"
echo ""
echo "Quick checks:"
echo "  Backend:   https://${PREFIX}-api.azurewebsites.net/health"
echo "  Dashboard: https://${PREFIX}-dashboard.azurewebsites.net"
