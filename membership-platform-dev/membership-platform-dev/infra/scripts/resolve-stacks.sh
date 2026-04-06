#!/usr/bin/env bash
# resolve-stacks.sh
# ---------------------------------------------------------------------------
# Resolves an ordered list of Terraform stack paths for a given target.
#
# Usage:
#   ./resolve-stacks.sh --target <target> --env <environment> [--format json|lines]
#
# Arguments:
#   --target   Required. One of: full, foundations, network, security,
#              identities, observability, app, rbac
#   --env      Required. Environment name (e.g. dev, staging, prod).
#              Used to locate stack-order.txt.
#   --format   Optional. Output format: 'lines' (default) or 'json'.
#
# Output:
#   Newline-delimited list of relative stack paths (default), or JSON array.
#
# Examples:
#   ./resolve-stacks.sh --target app --env dev
#   ./resolve-stacks.sh --target foundations --env dev --format json
#   ./resolve-stacks.sh --target full --env dev
# ---------------------------------------------------------------------------

set -euo pipefail

# --------------------------------------------------------------------------
# Defaults
# --------------------------------------------------------------------------
TARGET=""
ENV=""
FORMAT="lines"

# --------------------------------------------------------------------------
# Argument parsing
# --------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --env)
      ENV="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '2,30p' "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------
if [[ -z "$TARGET" ]]; then
  echo "ERROR: --target is required." >&2
  echo "       Valid targets: full, foundations, network, security, identities, observability, app, rbac" >&2
  exit 1
fi

if [[ -z "$ENV" ]]; then
  echo "ERROR: --env is required." >&2
  exit 1
fi

if [[ "$FORMAT" != "lines" && "$FORMAT" != "json" ]]; then
  echo "ERROR: --format must be 'lines' or 'json'." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Locate stack-order.txt
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STACK_ORDER_FILE="${INFRA_ROOT}/envs/${ENV}/stack-order.txt"

if [[ ! -f "$STACK_ORDER_FILE" ]]; then
  echo "ERROR: stack-order.txt not found at: ${STACK_ORDER_FILE}" >&2
  echo "       Ensure --env '${ENV}' is correct and stack-order.txt exists." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Load full ordered stack list from stack-order.txt
# (strips comments and blank lines)
# --------------------------------------------------------------------------
mapfile -t ALL_STACKS < <(grep -v '^\s*#' "$STACK_ORDER_FILE" | grep -v '^\s*$')

if [[ ${#ALL_STACKS[@]} -eq 0 ]]; then
  echo "ERROR: stack-order.txt is empty or contains only comments: ${STACK_ORDER_FILE}" >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Target definitions
# Foundational (Layer 1) stacks — must match entries in stack-order.txt
# --------------------------------------------------------------------------
LAYER1_STACKS=("network" "security" "identities" "observability")
LAYER2_STACKS=("app" "rbac")

# --------------------------------------------------------------------------
# Validate that all defined stacks actually exist in stack-order.txt
# --------------------------------------------------------------------------
validate_stack_in_order() {
  local stack="$1"
  for s in "${ALL_STACKS[@]}"; do
    if [[ "$s" == "$stack" ]]; then
      return 0
    fi
  done
  echo "ERROR: Stack '${stack}' is referenced in target mapping but not found in stack-order.txt." >&2
  echo "       Add '${stack}' to ${STACK_ORDER_FILE} in the correct position." >&2
  exit 1
}

# --------------------------------------------------------------------------
# Resolve target → ordered subset of stacks
# --------------------------------------------------------------------------
resolve_target() {
  local target="$1"
  local -a resolved=()

  case "$target" in
    full)
      # All stacks in stack-order.txt order
      resolved=("${ALL_STACKS[@]}")
      ;;

    foundations)
      # Layer 1 stacks only, in stack-order.txt order
      for s in "${ALL_STACKS[@]}"; do
        for l1 in "${LAYER1_STACKS[@]}"; do
          if [[ "$s" == "$l1" ]]; then
            resolved+=("$s")
            break
          fi
        done
      done
      ;;

    network|security|identities|observability|app|rbac)
      # Single named stack
      validate_stack_in_order "$target"
      resolved=("$target")
      ;;

    *)
      # Check if the target matches any stack name in stack-order.txt (extensibility)
      local matched=false
      for s in "${ALL_STACKS[@]}"; do
        if [[ "$s" == "$target" ]]; then
          resolved=("$target")
          matched=true
          break
        fi
      done

      if [[ "$matched" == "false" ]]; then
        echo "ERROR: Unknown target: '${target}'" >&2
        echo "       Valid targets: full, foundations, $(IFS=', '; echo "${ALL_STACKS[*]}")" >&2
        exit 1
      fi
      ;;
  esac

  # Return resolved array by echoing each entry
  for s in "${resolved[@]}"; do
    echo "$s"
  done
}

# --------------------------------------------------------------------------
# Run resolution
# --------------------------------------------------------------------------
mapfile -t RESOLVED_STACKS < <(resolve_target "$TARGET")

if [[ ${#RESOLVED_STACKS[@]} -eq 0 ]]; then
  echo "ERROR: Target '${TARGET}' resolved to zero stacks. Check LAYER1_STACKS/LAYER2_STACKS definitions." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Build relative stack paths
# --------------------------------------------------------------------------
ENV_BASE="infra/envs/${ENV}"
declare -a STACK_PATHS=()

for stack in "${RESOLVED_STACKS[@]}"; do
  stack_path="${ENV_BASE}/${stack}"
  # Validate directory exists (optional: warn, not fatal, for CI pre-checks)
  full_path="${INFRA_ROOT}/envs/${ENV}/${stack}"
  if [[ ! -d "$full_path" ]]; then
    echo "WARNING: Stack directory not found: ${full_path}" >&2
    echo "         Ensure '${stack}' directory exists before running terraform." >&2
  fi
  STACK_PATHS+=("$stack_path")
done

# --------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------
if [[ "$FORMAT" == "json" ]]; then
  # Emit JSON array
  printf '['
  for i in "${!STACK_PATHS[@]}"; do
    if [[ $i -gt 0 ]]; then printf ','; fi
    printf '"%s"' "${STACK_PATHS[$i]}"
  done
  printf ']\n'
else
  # Default: newline-delimited
  for path in "${STACK_PATHS[@]}"; do
    echo "$path"
  done
fi
