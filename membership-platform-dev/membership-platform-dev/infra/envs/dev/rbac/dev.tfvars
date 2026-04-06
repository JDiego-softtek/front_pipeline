# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
# Common variables (project, environment, location, owner, cost_center, etc.)
# are defined in ../_shared/common.tfvars — do NOT duplicate them here.
#
# See infra/docs/TERRAFORM_INVOCATION_GUIDE.md for details.

# Remote state references (must match the storage account used for all layers)
backend_resource_group  = "rg-membership-eus2-01"
backend_storage_account = "statetfmembershipdev"
backend_container       = "tfstate"
