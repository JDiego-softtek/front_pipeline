# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
# Common variables (project, environment, location, owner, cost_center, etc.)
# are defined in ../_shared/common.tfvars — do NOT duplicate them here.
#
# REQUIRED INVOCATION (PowerShell — run from infra/envs/dev/observability/):
#   C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
#   C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
# See infra/docs/TERRAFORM_INVOCATION_GUIDE.md for details.

# No observability-specific variables in dev at this time.
# Add here when needed: retention_days, Log Analytics SKU, etc.
