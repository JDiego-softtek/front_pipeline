# ---------------------------------------------------------------------------
# SHARED ENVIRONMENT VARIABLES — dev
# Aplica a todas las capas: app, network, observability, security
#
# USO: pasar este archivo ANTES del tfvars específico de la capa:
#   terraform apply \
#     -var-file="../../_shared/common.tfvars" \
#     -var-file="dev.tfvars"
# ---------------------------------------------------------------------------

# subscription_id is injected at runtime via TF_VAR_subscription_id in CI/CD.
# Do not set it here — a hardcoded empty string would override the env var.

project             = "mot"
environment         = "dev"
resource_group_name = "rg-membership-eus2-01"
location            = "eastus2"
owner               = "devops-team"
cost_center         = "IT-MOT-001"
criticality         = "low"
workload            = "mot"
