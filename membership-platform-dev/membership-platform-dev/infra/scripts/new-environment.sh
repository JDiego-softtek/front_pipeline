#!/usr/bin/env bash
# =============================================================================
# new-environment.sh
# Genera la estructura completa de un nuevo environment Terraform.
#
# USO:
#   chmod +x infra/scripts/new-environment.sh
#   ./infra/scripts/new-environment.sh <environment> [resource_group] [storage_account]
#
# EJEMPLOS:
#   ./infra/scripts/new-environment.sh qa
#   ./infra/scripts/new-environment.sh prod rg-mot-prod stmotprodtfstate
#
# PARÁMETROS:
#   environment      Nombre del environment (qa, prod, staging, etc.)
#   resource_group   Resource group del backend de Terraform (default: igual a dev)
#   storage_account  Storage account para el tfstate (default: stmot<env>tfstate)
# =============================================================================

set -euo pipefail

# ─── Argumentos ──────────────────────────────────────────────────────────────
ENV="${1:-}"
if [[ -z "$ENV" ]]; then
  echo "❌ Error: debes especificar el nombre del environment."
  echo "   Uso: $0 <environment> [resource_group] [storage_account]"
  exit 1
fi

RESOURCE_GROUP="${2:-rg-membership-eus2-01}"
STORAGE_ACCOUNT="${3:-stmot${ENV}tfstate}"
CONTAINER="tfstate"
PROJECT="mot"
LOCATION="eastus2"
OWNER="devops-team"
COST_CENTER="IT-MOT-001"
WORKLOAD="mot"

# Ruta base relativa al repo (ejecutar desde la raíz del repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENVS_DIR="${REPO_ROOT}/infra/envs"
TARGET_DIR="${ENVS_DIR}/${ENV}"

echo ""
echo "════════════════════════════════════════════════"
echo "  Creando environment: ${ENV}"
echo "  Backend RG:          ${RESOURCE_GROUP}"
echo "  Storage Account:     ${STORAGE_ACCOUNT}"
echo "  Destino:             ${TARGET_DIR}"
echo "════════════════════════════════════════════════"
echo ""

# ─── Validaciones ────────────────────────────────────────────────────────────
if [[ -d "$TARGET_DIR" ]]; then
  echo "⚠️  El directorio '${TARGET_DIR}' ya existe."
  read -rp "   ¿Deseas sobrescribir los archivos? (s/N): " CONFIRM
  if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "   Cancelado."
    exit 0
  fi
fi

LAYERS=("network" "security" "observability" "identities" "app" "rbac")

# ─── Helper: crear directorio ─────────────────────────────────────────────────
mkdir_safe() {
  mkdir -p "$1"
}

# ─── Helper: escribir archivo solo si no existe (o si se confirmó sobrescribir) ─
write_file() {
  local path="$1"
  local content="$2"
  echo "$content" > "$path"
  echo "  ✅ $(realpath --relative-to="${REPO_ROOT}" "$path")"
}

# =============================================================================
# 1. backend.hcl compartido
# =============================================================================
mkdir_safe "${TARGET_DIR}"
write_file "${TARGET_DIR}/backend.hcl" "resource_group_name  = \"${RESOURCE_GROUP}\"
storage_account_name = \"${STORAGE_ACCOUNT}\"
container_name       = \"${CONTAINER}\""

# =============================================================================
# 2. _shared/common.tfvars del environment
# =============================================================================
mkdir_safe "${TARGET_DIR}/_shared"
write_file "${TARGET_DIR}/_shared/common.tfvars" "# ---------------------------------------------------------------------------
# SHARED ENVIRONMENT VARIABLES — ${ENV}
# Aplica a todas las capas: app, network, observability, security
#
# USO: pasar este archivo ANTES del tfvars específico de la capa:
#   terraform apply \\
#     -var-file=\"../../_shared/common.tfvars\" \\
#     -var-file=\"${ENV}.tfvars\"
# ---------------------------------------------------------------------------

# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
subscription_id = \"\"

project             = \"${PROJECT}\"
environment         = \"${ENV}\"
resource_group_name = \"${RESOURCE_GROUP}\"
location            = \"${LOCATION}\"
owner               = \"${OWNER}\"
cost_center         = \"${COST_CENTER}\"
criticality         = \"low\"
workload            = \"${WORKLOAD}\""

# =============================================================================
# 3. Capas: app, network, observability, security
# =============================================================================
for LAYER in "${LAYERS[@]}"; do
  LAYER_DIR="${TARGET_DIR}/${LAYER}"
  mkdir_safe "${LAYER_DIR}"
  echo ""
  echo "  📁 Capa: ${LAYER}"

  # ── backend.tf ──────────────────────────────────────────────────────────
  write_file "${LAYER_DIR}/backend.tf" "terraform {
  backend \"azurerm\" {
    key = \"${ENV}/${LAYER}.tfstate\"
  }
}"

  # ── providers.tf ────────────────────────────────────────────────────────
  write_file "${LAYER_DIR}/providers.tf" "provider \"azurerm\" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = \"none\"
}"

  # ── versions.tf ─────────────────────────────────────────────────────────
  if [[ "$LAYER" == "network" ]]; then
    RANDOM_PROVIDER=""
  else
    RANDOM_PROVIDER="
    random = {
      source  = \"hashicorp/random\"
      version = \"~> 3.5\"
    }"
  fi
  write_file "${LAYER_DIR}/versions.tf" "terraform {
  required_version = \">= 1.6.0, < 2.0.0\"
  required_providers {
    azurerm = {
      source  = \"hashicorp/azurerm\"
      version = \"~> 4.0\"
    }${RANDOM_PROVIDER}
  }
}"

  # ── variables.tf (solo variables comunes — las específicas se agregan manualmente) ──
  write_file "${LAYER_DIR}/variables.tf" "# Common variables — shared across all layers
# Layer-specific variables go below this block

variable \"subscription_id\" {
  description = \"Azure subscription ID\"
  type        = string
}

variable \"project\" {
  description = \"Project short name\"
  type        = string
}

variable \"environment\" {
  description = \"Environment name (dev / qa / prod)\"
  type        = string
}

variable \"resource_group_name\" {
  description = \"Existing resource group name\"
  type        = string
}

variable \"location\" {
  description = \"Azure region for all resources\"
  type        = string
}

variable \"owner\" {
  description = \"Team or person responsible for this layer\"
  type        = string
}

variable \"cost_center\" {
  description = \"Cost center code for billing attribution\"
  type        = string
}

variable \"criticality\" {
  description = \"Workload criticality level\"
  type        = string
  validation {
    condition     = contains([\"low\", \"medium\", \"high\", \"critical\"], var.criticality)
    error_message = \"criticality must be one of: low, medium, high, critical.\"
  }
}

variable \"workload\" {
  description = \"Workload or application name\"
  type        = string
}

# ── Layer-specific variables ──────────────────────────────────────────────────
# TODO: copy layer-specific variables from infra/envs/dev/${LAYER}/variables.tf
$(if [[ "$LAYER" == "rbac" ]]; then echo "
variable \"backend_resource_group\" {
  description = \"Resource group containing the Terraform state storage account\"
  type        = string
}

variable \"backend_storage_account\" {
  description = \"Storage account name for Terraform remote state\"
  type        = string
}

variable \"backend_container\" {
  description = \"Blob container name for Terraform remote state\"
  type        = string
  default     = \"tfstate\"
}"; fi)"

  # ── locals.tf ───────────────────────────────────────────────────────────
  if [[ "$LAYER" == "network" ]]; then
    EXTRA_LOCALS="

  # Network-specific: filter subnets when private endpoints are disabled
  effective_subnets = var.enable_private_endpoints ? var.subnets : {
    for k, v in var.subnets : k => v if k != \"snet-data\"
  }"
  else
    EXTRA_LOCALS=""
  fi

  write_file "${LAYER_DIR}/locals.tf" "locals {
  resource_name = \"\${var.project}-\${var.environment}\"

  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = \"terraform\"
    cost_center = var.cost_center
    criticality = var.criticality
    workload    = var.workload
  }${EXTRA_LOCALS}
}"

  # ── outputs.tf (placeholder) ─────────────────────────────────────────────
  write_file "${LAYER_DIR}/outputs.tf" "# Outputs for the ${LAYER} layer — ${ENV} environment
# TODO: copy outputs from infra/envs/dev/${LAYER}/outputs.tf"

  # ── {env}.tfvars (solo variables comunes; las específicas van al final) ──
  if [[ "$LAYER" == "network" ]]; then
    LAYER_SPECIFIC_VARS="
enable_private_endpoints = false

vnet_cidr = \"10.XX.0.0/20\"

subnets = {
  # TODO: define subnets for ${ENV}
}"
  elif [[ "$LAYER" == "security" ]]; then
    LAYER_SPECIFIC_VARS="
keyvault_sku                        = \"standard\"
keyvault_public_access_enabled      = false
keyvault_purge_protection_enabled   = true
keyvault_soft_delete_retention_days = 30"
  elif [[ "$LAYER" == "identities" ]]; then
    LAYER_SPECIFIC_VARS="
# No layer-specific variables — all values come from ../_shared/common.tfvars"
  elif [[ "$LAYER" == "rbac" ]]; then
    LAYER_SPECIFIC_VARS="
# Remote state references (must match the storage account used for all layers)
backend_resource_group  = \"${RESOURCE_GROUP}\"
backend_storage_account = \"${STORAGE_ACCOUNT}\"
backend_container       = \"${CONTAINER}\""
  else
    LAYER_SPECIFIC_VARS="
# TODO: add ${LAYER}-specific variables for ${ENV}"
  fi

  write_file "${LAYER_DIR}/${ENV}.tfvars" "# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
# Common variables are in ../_shared/common.tfvars — do NOT duplicate them here.
${LAYER_SPECIFIC_VARS}"

done

# =============================================================================
# 4. Resumen final
# =============================================================================
echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ Environment '${ENV}' creado exitosamente"
echo ""
echo "  NEXT STEPS:"
echo ""
echo "  1. Complete layer-specific variables:"
for LAYER in "${LAYERS[@]}"; do
  echo "     • ${TARGET_DIR}/${LAYER}/variables.tf"
  echo "     • ${TARGET_DIR}/${LAYER}/${ENV}.tfvars"
done
echo ""
echo "  2. Copy resource .tf files from dev and adjust for ${ENV}:"
for LAYER in "${LAYERS[@]}"; do
  echo "     cp infra/envs/dev/${LAYER}/*.tf infra/envs/${ENV}/${LAYER}/"
done
echo ""
echo "  3. Deploy order: network → security → observability → identities → app → rbac"
echo ""
echo "  4. Validate all layers:"
echo "     for layer in ${LAYERS[*]}; do"
echo "       terraform -chdir=infra/envs/${ENV}/\$layer init -backend=false"
echo "       terraform -chdir=infra/envs/${ENV}/\$layer validate"
echo "     done"
echo "════════════════════════════════════════════════"
echo ""
