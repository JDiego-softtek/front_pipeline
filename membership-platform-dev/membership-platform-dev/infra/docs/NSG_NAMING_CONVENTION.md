# Network Security Group (NSG) Naming Convention

## Overview

Network Security Groups (NSGs) in this project follow a standardized naming convention that ensures clarity, consistency, and easy identification across Azure environments.

## Naming Patterns

### 1. APIM NSG (API Management)

**Pattern:** `nsg-apim-<project>-<environment>`

**Example:** `nsg-apim-mot-dev`

**Components:**
- `nsg` — Resource type identifier
- `apim` — Indicates this NSG is for API Management
- `<project>` — Project name (e.g., `mot` for Membership Operations Tracking)
- `<environment>` — Deployment environment (e.g., `dev`, `qa`, `prod`)

### 2. Subnet NSG (Virtual Network Subnets)

**Pattern:** `nsg-<project>-<subnet>-<environment>`

**Examples:**
- `nsg-mot-snet-aca-exp-dev` (Container Apps Experiment subnet)
- `nsg-mot-snet-frontend-dev` (Frontend subnet)
- `nsg-mot-snet-functions-dev` (Functions subnet)
- `nsg-mot-snet-logic-apps-dev` (Logic Apps subnet)
- `nsg-mot-snet-management-dev` (Management subnet)

**Components:**
- `nsg` — Resource type identifier
- `<project>` — Project name (e.g., `mot`)
- `<subnet>` — Subnet identifier (e.g., `snet-aca-exp`, `snet-frontend`)
- `<environment>` — Deployment environment (e.g., `dev`, `qa`, `prod`)

## Key Design Principles

### Environment Identifier Placement

The **environment identifier is placed at the end** of the NSG name for consistency and to enable:
- Easy filtering and grouping in Azure Portal by environment
- Predictable sorting when viewing resources
- Simplified resource naming across all Azure resources

### Subnet Mapping

Subnet identifiers are included in NSG names to clearly indicate:
- Which subnet the NSG is protecting
- The purpose of the subnet (e.g., `aca-exp`, `frontend`, `logic-apps`)
- Dependencies between subnets and their security configurations

### Dynamic Generation

NSG names are generated dynamically in Terraform to ensure consistency:

```hcl
# From infra/modules/networking/main.tf

# APIM NSG
resource "azurerm_network_security_group" "nsg_apim" {
  name = "nsg-apim-${var.resource_name}-${var.environment}"
  ...
}

# Subnet NSGs
resource "azurerm_network_security_group" "subnet" {
  for_each = local.non_apim_subnets

  name = "nsg-${var.resource_name}-${each.key}-${var.environment}"
  ...
}
```

## Implementation Details

### Module Parameters

The `infra/modules/networking/` module accepts:
- `resource_name` (string) — Project name (e.g., `mot`)
- `environment` (string) — Environment identifier (e.g., `dev`, `qa`, `prod`)

### Environment Configuration

Environment-specific values are provided via `infra/envs/<env>/_shared/common.tfvars`:

```hcl
# Example: infra/envs/dev/_shared/common.tfvars
project     = "mot"
environment = "dev"
```

### Module Invocation

```hcl
# From infra/envs/dev/network/main.tf
module "networking" {
  source = "../../../modules/networking"

  resource_name = var.project
  environment   = var.environment
  ...
}
```

### Dynamic Subnet NSGs

Subnet NSGs are created dynamically from the subnet configuration:

```hcl
# From infra/envs/dev/network/dev.tfvars
subnets = {
  snet-aca-exp = {
    cidr = "10.10.2.0/23"
    delegation = { ... }
  }
  snet-frontend = {
    cidr = "10.10.1.0/24"
    delegation = { ... }
  }
  # ... other subnets
}
```

Resulting NSG names:
- `nsg-mot-snet-aca-exp-dev`
- `nsg-mot-snet-frontend-dev`
- ... (one NSG per subnet)

## Migration from Old Convention

### Old Naming Pattern

Previously, NSG names followed the pattern:
- `nsg-mot-dev-snet-aca-exp` (environment in the middle)
- `nsg-apim-mot-dev` (different pattern for APIM)

### New Naming Pattern

Now, all NSGs follow:
- `nsg-mot-snet-aca-exp-dev` (environment at the end)
- `nsg-apim-mot-dev` (kept consistent)

### Terraform Upgrade Path

When upgrading to the new convention:

1. Terraform will detect that NSG names have changed
2. Run `terraform plan` to review the changes
3. The plan will show:
   - Destruction of old NSGs
   - Creation of new NSGs with updated names
4. Use `terraform apply` to apply the changes

**Note:** This operation is safe because:
- Azure subnet associations are updated automatically
- No rules are lost (rules are associated with NSG name)
- Downtime is minimal (milliseconds)

## Future Considerations

### When to Update This Convention

Update this convention if:
- New NSG types are needed (e.g., different patterns for specific services)
- Environment naming changes (e.g., different environment identifiers)
- Organization-wide naming standards are updated

### Multi-Project Scenarios

If multiple projects share the same infrastructure:
- Each project gets its own project identifier (e.g., `mot`, `sales`, `inventory`)
- NSG names clearly indicate which project they belong to
- Example: `nsg-sales-snet-frontend-dev`

## References

- **Implementation:** `infra/modules/networking/main.tf`
- **Module Configuration:** `infra/modules/networking/variables.tf`
- **Environment Setup:** `infra/envs/dev/_shared/common.tfvars`
- **Architecture Guide:** `infra/docs/ARCHITECTURE.md`
