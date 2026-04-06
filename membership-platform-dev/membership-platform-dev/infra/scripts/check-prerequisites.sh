#!/usr/bin/env bash
# check-prerequisites.sh
# ---------------------------------------------------------------------------
# Validates that all required producer stack remote states exist and expose
# the expected outputs BEFORE a consumer stack (app, rbac) is allowed to
# run terraform init / plan / apply.
#
# How it works (shell-layer only — no cross-state Terraform references):
#   1. For each required producer stack, check that the .tfstate blob exists
#      in the Azure Storage Account backend and is non-empty.
#   2. Optionally, run `terraform output -json` in the producer directory to
#      confirm that required output keys are present and non-null.
#   3. Exit non-zero with a clear, actionable error message on any failure.
#
# Usage:
#   ./check-prerequisites.sh --consumer <stack> --env <env> [--check-outputs]
#
# Arguments:
#   --consumer       Required. Consumer stack to check prereqs for.
#                    Supported: app, rbac
#   --env            Required. Environment name (e.g. dev, staging, prod).
#   --check-outputs  Optional. If set, also run terraform output checks.
#                    Requires terraform CLI and backend to be reachable.
#   --storage-account  Optional. Override Azure Storage Account name.
#                      Falls back to env var TF_BACKEND_STORAGE_ACCOUNT.
#   --container-name   Optional. Override blob container name.
#                      Falls back to env var TF_BACKEND_CONTAINER (default: tfstate).
#
# Environment variables (all optional overrides):
#   TF_BACKEND_STORAGE_ACCOUNT   Azure Storage Account holding all state blobs
#   TF_BACKEND_CONTAINER         Container name (default: tfstate)
#   TF_BACKEND_RESOURCE_GROUP    Resource group of the storage account
#                                (required only for az storage blob commands
#                                 when --auth-mode login is used)
#
# Exit codes:
#   0  All prerequisites satisfied
#   1  One or more prerequisites missing or outputs absent
#   2  Configuration/usage error
# ---------------------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
CONSUMER=""
ENV=""
CHECK_OUTPUTS=false
STORAGE_ACCOUNT="${TF_BACKEND_STORAGE_ACCOUNT:-}"
CONTAINER_NAME="${TF_BACKEND_CONTAINER:-tfstate}"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --consumer)         CONSUMER="$2";          shift 2 ;;
    --env)              ENV="$2";               shift 2 ;;
    --check-outputs)    CHECK_OUTPUTS=true;     shift   ;;
    --storage-account)  STORAGE_ACCOUNT="$2";   shift 2 ;;
    --container-name)   CONTAINER_NAME="$2";    shift 2 ;;
    -h|--help)
      sed -n '2,45p' "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------
if [[ -z "$CONSUMER" ]]; then
  echo "ERROR: --consumer is required (e.g. app, rbac)." >&2
  exit 2
fi

if [[ -z "$ENV" ]]; then
  echo "ERROR: --env is required (e.g. dev, staging, prod)." >&2
  exit 2
fi

if [[ -z "$STORAGE_ACCOUNT" ]]; then
  echo "ERROR: Azure Storage Account name is required." >&2
  echo "       Set --storage-account or export TF_BACKEND_STORAGE_ACCOUNT." >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Dependency check: az CLI must be available
# ---------------------------------------------------------------------------
if ! command -v az &>/dev/null; then
  echo "ERROR: Azure CLI (az) is not installed or not on PATH." >&2
  echo "       Install it from https://docs.microsoft.com/cli/azure/install-azure-cli" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Consumer → required producer stacks mapping
# Each consumer declares which producer stacks it MUST have applied first.
# ---------------------------------------------------------------------------
declare -A CONSUMER_PREREQS
CONSUMER_PREREQS["app"]="network security identities observability"
CONSUMER_PREREQS["rbac"]="identities app"

# ---------------------------------------------------------------------------
# Producer stack → required output keys mapping
# Used when --check-outputs is set.
# ---------------------------------------------------------------------------
declare -A REQUIRED_OUTPUTS
REQUIRED_OUTPUTS["network"]="vnet_id subnet_ids nsg_ids"
REQUIRED_OUTPUTS["security"]="key_vault_uri key_vault_id"
REQUIRED_OUTPUTS["identities"]="aca_identity_client_id aca_identity_principal_id"
REQUIRED_OUTPUTS["observability"]="log_analytics_workspace_id app_insights_instrumentation_key"
REQUIRED_OUTPUTS["app"]="aca_fqdn acr_login_server"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ERRORS=0
WARNINGS=0

log_info()    { echo "  [INFO]  $*"; }
log_ok()      { echo "  [OK]    $*"; }
log_warn()    { echo "  [WARN]  $*" >&2; ((WARNINGS++)) || true; }
log_error()   { echo "  [ERROR] $*" >&2; ((ERRORS++)) || true; }
log_section() { echo; echo "━━━ $* ━━━"; }

# ---------------------------------------------------------------------------
# check_state_blob_exists <stack_name>
#
# Constructs the canonical blob key used by the azurerm backend:
#   infra/envs/<env>/<stack>/terraform.tfstate
# and checks that it exists and has a non-zero size.
# ---------------------------------------------------------------------------
check_state_blob_exists() {
  local stack="$1"

  # ---------------------------------------------------------------------------
  # FLAT BLOB KEY PATTERN
  # Azure Blob Storage has NO real directory structure. "Folders" are purely
  # virtual — they are formed by the blob name prefix up to the last "/".
  # The blob name IS the full key. We use:
  #
  #   <env>/<stack>.tfstate   (e.g. dev/network.tfstate)
  #
  # NOT a hierarchical path like:
  #   network/network.tfstate       ← WRONG
  #   dev/network/network.tfstate   ← WRONG
  #
  # This matches the azurerm backend `key` value set in each stack's
  # backend.hcl / backend.tf, e.g.:  key = "dev/network.tfstate"
  # ---------------------------------------------------------------------------
  local blob_key="${ENV}/${stack}.tfstate"

  # Print the exact blob name being checked — makes debugging straightforward.
  echo "Checking blob: ${blob_key}"
  log_info "Storage account: ${STORAGE_ACCOUNT} | Container: ${CONTAINER_NAME} | Blob: ${blob_key}"

  # Check blob existence
  local exists
  exists=$(az storage blob exists \
    --account-name "$STORAGE_ACCOUNT" \
    --container-name "$CONTAINER_NAME" \
    --name "$blob_key" \
    --auth-mode login \
    --output tsv \
    --query "exists" 2>/dev/null || echo "false")

  if [[ "$exists" != "true" ]]; then
    log_error "Required prerequisite state blob not found: ${blob_key} — deploy the ${stack} stack first."
    log_error "  Storage account : ${STORAGE_ACCOUNT}"
    log_error "  Container       : ${CONTAINER_NAME}"
    log_error "  Blob key        : ${blob_key}"
    log_error "  Fix             : Run infra-platform.yml with target=${stack} (or target=foundations) in env=${ENV}."
    log_error "  Verify manually : az storage blob show --account-name ${STORAGE_ACCOUNT} --container-name ${CONTAINER_NAME} --name \"${blob_key}\" --auth-mode login"
    return 1
  fi

  # Check blob is non-empty (a freshly locked / empty state would be ~47 bytes)
  local size
  size=$(az storage blob show \
    --account-name "$STORAGE_ACCOUNT" \
    --container-name "$CONTAINER_NAME" \
    --name "$blob_key" \
    --auth-mode login \
    --output tsv \
    --query "properties.contentLength" 2>/dev/null || echo "0")

  if [[ "${size:-0}" -lt 100 ]]; then
    log_error "State blob for '${stack}' exists but appears empty or corrupt (${size} bytes)."
    log_error "  Action  : Re-apply the '${stack}' stack to populate the remote state."
    return 1
  fi

  log_ok "State blob found and non-empty (${size} bytes): ${stack}"
  return 0
}

# ---------------------------------------------------------------------------
# check_stack_outputs <stack_name>
#
# Changes into the producer stack directory, runs `terraform output -json`,
# and verifies that each expected key is present and non-null.
#
# Requires:
#   - terraform CLI on PATH
#   - The stack directory must have a valid backend.tf / backend.hcl
#   - `terraform init` must have been run in the producer stack at least once
# ---------------------------------------------------------------------------
check_stack_outputs() {
  local stack="$1"
  local stack_dir="${INFRA_ROOT}/envs/${ENV}/${stack}"
  local required_keys="${REQUIRED_OUTPUTS[$stack]:-}"

  if [[ -z "$required_keys" ]]; then
    log_warn "No required outputs defined for stack '${stack}'. Skipping output check."
    return 0
  fi

  if [[ ! -d "$stack_dir" ]]; then
    log_error "Stack directory not found: ${stack_dir}"
    return 1
  fi

  if ! command -v terraform &>/dev/null; then
    log_warn "terraform CLI not found; skipping output validation for '${stack}'."
    return 0
  fi

  log_info "Running: terraform output -json in ${stack_dir}"

  local tf_output
  if ! tf_output=$(terraform -chdir="$stack_dir" output -json 2>/dev/null); then
    log_error "Failed to retrieve outputs for stack '${stack}'."
    log_error "  Ensure the stack is initialized: cd ${stack_dir} && terraform init -backend-config=../backend.hcl"
    return 1
  fi

  local all_ok=true
  for key in $required_keys; do
    local value
    value=$(echo "$tf_output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
entry = data.get('${key}')
if entry is None:
    sys.exit(1)
val = entry.get('value')
if val is None or val == '' or val == [] or val == {}:
    sys.exit(2)
print(val)
" 2>/dev/null || echo "__MISSING__")

    if [[ "$value" == "__MISSING__" ]]; then
      log_error "Required output '${key}' is missing or null in stack '${stack}'."
      log_error "  Action  : Add output '${key}' to ${stack_dir}/outputs.tf and re-apply."
      all_ok=false
    else
      log_ok "Output '${key}' present in stack '${stack}'."
    fi
  done

  [[ "$all_ok" == "true" ]] && return 0 || return 1
}

# ---------------------------------------------------------------------------
# guard_consumer <consumer_stack>
#
# Main entry point. Iterates over the required producers for the given
# consumer and runs all checks.
# ---------------------------------------------------------------------------
guard_consumer() {
  local consumer="$1"

  if [[ -z "${CONSUMER_PREREQS[$consumer]:-}" ]]; then
    echo "ERROR: No prerequisite definition found for consumer stack '${consumer}'." >&2
    echo "       Add an entry to CONSUMER_PREREQS in this script." >&2
    exit 2
  fi

  log_section "Prerequisite check for consumer stack: ${consumer} (env: ${ENV})"
  echo "  Storage Account : ${STORAGE_ACCOUNT}"
  echo "  Container       : ${CONTAINER_NAME}"
  echo "  Output checks   : ${CHECK_OUTPUTS}"

  local prereqs="${CONSUMER_PREREQS[$consumer]}"
  local prereq_list=($prereqs)

  for producer in "${prereq_list[@]}"; do
    log_section "Producer: ${producer}"

    # Step 1: Check state blob exists
    if ! check_state_blob_exists "$producer"; then
      # Already logged by the function; continue to check others (collect all errors)
      continue
    fi

    # Step 2: Check outputs (optional)
    if [[ "$CHECK_OUTPUTS" == "true" ]]; then
      check_stack_outputs "$producer" || true
    fi
  done

  log_section "Result"

  if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  PREREQUISITE CHECK FAILED                                      ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║  Consumer  : ${consumer}"
    echo "║  Env       : ${ENV}"
    echo "║  Errors    : ${ERRORS}"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║  Missing foundations must be applied before this consumer can   ║"
    echo "║  be planned or applied. Run the appropriate target first:       ║"
    echo "║                                                                 ║"
    echo "║    target=foundations   → deploys network, security,            ║"
    echo "║                           identities, observability             ║"
    echo "║    target=<stack-name>  → deploys a single producer stack       ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
  fi

  if [[ $WARNINGS -gt 0 ]]; then
    echo "[WARN] Completed with ${WARNINGS} warning(s). Review above output."
  fi

  echo ""
  echo "╔══════════════════════════════════════════════════════════════════╗"
  echo "║  ALL PREREQUISITES SATISFIED ✓                                  ║"
  echo "║  Consumer '${consumer}' may proceed with terraform init/plan/apply.    ║"
  echo "╚══════════════════════════════════════════════════════════════════╝"
  echo ""
}

# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------
guard_consumer "$CONSUMER"

# =============================================================================
# CHANGE DOCUMENTATION — Flat tfstate Blob Layout
# =============================================================================
#
# ## What Was Wrong
#
# Earlier versions of this script (or similar validation logic) constructed
# blob keys using a hierarchical pattern such as:
#
#   network/network.tfstate
#   dev/network/network.tfstate
#
# These patterns do NOT match the actual blob names written by the azurerm
# Terraform backend and will cause `az storage blob exists` / `blob show`
# to return "not found" even when the state is present.
#
# ## What Was Fixed
#
# All blob key construction now uses the flat, environment-scoped pattern:
#
#   ${env}/${stack}.tfstate
#
# Examples:
#   dev/network.tfstate
#   dev/security.tfstate
#   dev/identities.tfstate
#   dev/observability.tfstate
#   staging/network.tfstate
#   prod/app.tfstate
#
# The relevant change is inside `check_state_blob_exists()`:
#
#   local blob_key="${ENV}/${stack}.tfstate"
#
# accompanied by an explicit `echo "Checking blob: ${blob_key}"` before every
# `az storage blob exists` call so the exact key is visible in CI logs.
#
# The error message on failure now reads:
#   ERROR: Required prerequisite state blob not found: dev/network.tfstate —
#          deploy the network stack first.
# and includes the `az storage blob show` command for manual verification.
#
# ## Why This Pattern Is Correct
#
# Azure Blob Storage has NO real directory structure. "Folders" in the Azure
# portal or Storage Explorer are purely VIRTUAL — they are rendered by
# grouping blobs whose names share a common prefix ending in "/".
#
# The blob NAME is the full key. When the azurerm Terraform backend is
# configured with:
#
#   key = "dev/network.tfstate"
#
# it writes a single blob whose name is literally "dev/network.tfstate".
# There is no "dev/" folder object and no "network/" subfolder object.
#
# Therefore the only correct way to reference or validate that blob is to
# use the full name "dev/network.tfstate" as the --name argument.
#
# ## How to Verify Manually
#
# To confirm that a required state blob exists in Azure Storage, run:
#
#   az storage blob show \
#     --account-name  <storage_account_name> \
#     --container-name <container_name> \
#     --name "dev/network.tfstate" \
#     --auth-mode login
#
# Replace "dev/network.tfstate" with the appropriate env/stack combination.
# A successful response returns JSON with blob properties including
# "contentLength" > 0. A 404 / "BlobNotFound" error means the stack has
# not been applied yet and foundations must be deployed first.
#
# Supported environments: dev, staging, prod (passed via --env at runtime).
# No hardcoding of environment names is present in this script.
# =============================================================================
