# Terraform Architecture — membership-platform

## Table of Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [Layers and Dependencies](#3-layers-and-dependencies)
4. [Shared Boilerplate (_shared)](#4-shared-boilerplate-_shared)
5. [Adding a New Environment](#5-adding-a-new-environment)
6. [Day-to-Day Commands](#6-day-to-day-commands)
7. [Remote Backend (Terraform State)](#7-remote-backend-terraform-state)
8. [Onboarding for New Developers](#8-onboarding-for-new-developers)
9. [Architecture Decisions](#9-architecture-decisions)

---

## 1. Overview

The project uses the **Directory-per-Environment + Layer Separation** pattern:

- **One directory per environment** (`envs/dev/`, `envs/qa/`, `envs/prod/`)
- **One subdirectory per layer** (`app/`, `network/`, `observability/`, `security/`)
- **Reusable modules** in `infra/modules/` — the actual business logic
- **Shared boilerplate** in `infra/envs/_shared/` — single source of truth for common files

```
infra/
├── envs/
│   ├── _shared/                  ← Single source of truth for boilerplate
│   │   ├── common_variables.tf   ← 9 variables common to every layer
│   │   ├── providers.tf          ← azurerm provider block
│   │   ├── versions.tf           ← TF + provider version constraints
│   │   └── locals.tf             ← resource_name + tags
│   │
│   └── dev/
│       ├── backend.hcl           ← Shared remote backend config
│       ├── _shared/
│       │   └── common.tfvars     ← Common variable values for this environment
│       ├── app/
│       │   ├── backend.tf        ← key = "dev/app.tfstate"
│       │   ├── providers.tf      ← (identical to _shared/providers.tf)
│       │   ├── versions.tf       ← (identical to _shared/versions.tf)
│       │   ├── variables.tf      ← common variables + app-specific variables
│       │   ├── locals.tf         ← (identical to _shared/locals.tf)
│       │   ├── dev.tfvars        ← App-layer-specific values only
│       │   └── *.tf              ← Resources: aca.tf, acr.tf, sql.tf, ...
│       ├── network/
│       ├── observability/
│       └── security/
│
├── modules/                      ← Reusable modules (real logic lives here)
│   ├── aca/, acr/, cosmosdb/, mssql/, ...
│
├── platform/                     ← Platform-level config (RBAC, policies)
│   ├── rbac/, policies/
│
└── scripts/
    ├── new-environment.sh        ← Scaffolding script for new environments
    └── azure_setup_script.ps1
```

---

## 2. Directory Structure

### `infra/envs/_shared/` — Single Source of Truth

These files contain the boilerplate that is **identical across all layers and environments**. They are the canonical reference; each layer keeps its own copy (required because Terraform does not support portable symlinks on all operating systems).

| File | Contents | When to update |
|------|----------|----------------|
| `common_variables.tf` | 9 shared variables (`project`, `environment`, `location`, etc.) | When adding a variable that applies to every layer |
| `providers.tf` | `provider "azurerm"` block | When changing the provider version or adding a feature flag |
| `versions.tf` | `required_version` + `required_providers` | When upgrading Terraform or the azurerm provider |
| `locals.tf` | `resource_name` + `tags` | When adding a new standard tag |

### `infra/envs/<env>/_shared/common.tfvars`

Concrete values for the shared variables for that environment. This file is **always** passed as the first `-var-file` when running Terraform.

---

## 3. Layers and Dependencies

Layers must be applied in the following order. Each layer may depend on outputs from the previous one.

```
┌─────────────┐
│   network   │  ← First: VNet, subnets, NSGs, DNS
└──────┬──────┘
       │ outputs: vnet_id, subnet_ids
       ▼
┌─────────────┐
│  security   │  ← Key Vault, RBAC, managed identities
└──────┬──────┘
       │ outputs: keyvault_id, managed_identity_ids
       ▼
┌───────────────┐
│ observability │  ← Log Analytics, App Insights, dashboards
└───────┬───────┘
        │ outputs: log_analytics_workspace_id
        ▼
┌─────────────┐
│     app     │  ← ACA, ACR, APIM, SQL, Cosmos, Storage, ADF
└─────────────┘
```

**Rules:**
- Always apply **top to bottom** on the first deployment
- For subsequent changes, only apply the affected layer
- **NEVER** run `terraform apply` across all layers simultaneously without an explicit ordered script

### Cross-layer References (Remote State)

If a layer needs an output from another layer, use `terraform_remote_state`:

```hcl
# In app/data.tf — read outputs from the network layer
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/network.tfstate"
  }
}

# Usage:
# data.terraform_remote_state.network.outputs.vnet_id
```

---

## 4. Shared Boilerplate (`_shared`)

### Problem It Solves

Without `_shared`, every layer in every environment would have identical copies of:

| File | Duplicated Lines | Layers × Environments |
|------|------------------|-----------------------|
| `providers.tf` | 5 lines | 4 × N envs |
| `versions.tf` | 13 lines | 4 × N envs |
| `locals.tf` | 11 lines | 4 × N envs |
| Common variables in `variables.tf` | 45 lines | 4 × N envs |
| Common variables in `*.tfvars` | 9 lines | 4 × N envs |

With 3 environments (dev, qa, prod): **~312 duplicated lines** → reduced to **~83 lines** in `_shared/`.

### Keeping Consistency

When you need to change something that applies to **all layers**:

1. **Modify the file in `infra/envs/_shared/`** (source of truth)
2. **Replicate the change in each affected layer** — use this command to check for drift:

```bash
# Check whether providers.tf in any layer has diverged from _shared
for layer in app network observability security; do
  echo "=== dev/$layer/providers.tf ==="
  diff infra/envs/_shared/providers.tf infra/envs/dev/$layer/providers.tf || true
done
```

> **Note on symlinks:** Windows does not support symlinks reliably without administrator privileges, so we keep explicit copies. If the team works 100% on Linux/macOS, symlinks can be used for `providers.tf`, `versions.tf`, and `locals.tf`.

### `common.tfvars` — Separation of Concerns

The `*.tfvars` pattern follows this hierarchy:

```
_shared/common.tfvars     ← values that do not change between layers of the same env
  └── app/dev.tfvars      ← only values specific to the app layer
  └── network/dev.tfvars  ← only values specific to the network layer
  ...
```

Values in `common.tfvars` can always be overridden by the layer-specific `*.tfvars` file when needed (Terraform uses the last defined value when multiple `-var-file` flags are provided).

---

## 5. Adding a New Environment

### Option A: Automated Script (Recommended)

```bash
# From the repository root
chmod +x infra/scripts/new-environment.sh

# Create the qa environment with defaults
./infra/scripts/new-environment.sh qa

# Create the prod environment with a specific backend
./infra/scripts/new-environment.sh prod rg-mot-prod stmotprodtfstate
```

The script generates:
- `infra/envs/<env>/backend.hcl`
- `infra/envs/<env>/_shared/common.tfvars`
- For each layer (`app`, `network`, `observability`, `security`):
  - `backend.tf`, `providers.tf`, `versions.tf`, `variables.tf`, `locals.tf`, `outputs.tf`
  - `<env>.tfvars` with only layer-specific variables

### Option B: Manual

1. Copy the `infra/envs/dev/` directory as a base:
   ```bash
   cp -r infra/envs/dev/ infra/envs/qa/
   ```

2. Update `infra/envs/qa/backend.hcl`:
   ```hcl
   resource_group_name  = "rg-mot-qa-backend"
   storage_account_name = "stmotqatfstate"
   container_name       = "tfstate"
   ```

3. Update `infra/envs/qa/_shared/common.tfvars`:
   ```hcl
   environment         = "qa"
   resource_group_name = "rg-mot-qa"
   criticality         = "medium"
   ```

4. Rename `dev.tfvars` to `qa.tfvars` in each layer:
   ```bash
   for layer in app network observability security; do
     mv infra/envs/qa/$layer/dev.tfvars infra/envs/qa/$layer/qa.tfvars
   done
   ```

5. Update layer-specific values in each `qa.tfvars`.

6. Initialize each layer:
   ```bash
   for layer in app network observability security; do
     terraform -chdir=infra/envs/qa/$layer init \
       -backend-config=../../backend.hcl
   done
   ```

---

## 6. Day-to-Day Commands

### Initialize a Layer

```bash
cd infra/envs/dev/app
terraform init -backend-config=../../backend.hcl
```

### Plan

```bash
terraform plan \
  -var-file="../../_shared/common.tfvars" \
  -var-file="dev.tfvars"
```

### Apply

```bash
terraform apply \
  -var-file="../../_shared/common.tfvars" \
  -var-file="dev.tfvars"
```

### Destroy (use with caution)

```bash
terraform destroy \
  -var-file="../../_shared/common.tfvars" \
  -var-file="dev.tfvars"
```

### Validate All Layers in an Environment

```bash
#!/bin/bash
ENV="dev"
for layer in app network observability security; do
  echo "Validating $ENV/$layer..."
  terraform -chdir="infra/envs/$ENV/$layer" validate
done
```

### View Layer Outputs

```bash
cd infra/envs/dev/network
terraform output
```

---

## 7. Remote Backend (Terraform State)

Each layer has its own state file in Azure Blob Storage:

| Layer | State Key |
|-------|-----------|
| `network` | `dev/network.tfstate` |
| `security` | `dev/security.tfstate` |
| `observability` | `dev/observability.tfstate` |
| `app` | `dev/app.tfstate` |

The backend configuration (`resource_group_name`, `storage_account_name`, `container_name`) is shared in `backend.hcl` and passed with `-backend-config` during `init`.

**Only the `key` differs per layer** (defined in each layer's `backend.tf`).

### CI/CD Access to State

The pipeline requires the following environment variable:
```bash
export TF_VAR_subscription_id="<azure-subscription-id>"
```

Azure credentials are configured via Service Principal or Managed Identity (see `infra/scripts/azure_setup_script.ps1`).

---

## 8. Onboarding for New Developers

### Prerequisites

- [Terraform >= 1.6.0](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Access to the project's Azure Subscription
- Read access to the Terraform state Storage Account

### Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/pricesmart/membership-platform.git
cd membership-platform

# 2. Authenticate with Azure
az login
az account set --subscription "<subscription-id>"

# 3. Set the subscription as an environment variable
export TF_VAR_subscription_id=$(az account show --query id -o tsv)

# 4. Initialize the layer you will work on (example: app)
cd infra/envs/dev/app
terraform init -backend-config=../../backend.hcl

# 5. Review the plan before making any changes
terraform plan \
  -var-file="../../_shared/common.tfvars" \
  -var-file="dev.tfvars"
```

### Standard Workflow

```
1. Make your change in infra/modules/<module>/main.tf  (or directly in the layer)
2. cd infra/envs/dev/<layer>
3. terraform plan -var-file="../../_shared/common.tfvars" -var-file="dev.tfvars"
4. Review the plan — verify only the expected resources are changing
5. terraform apply -var-file="../../_shared/common.tfvars" -var-file="dev.tfvars"
6. Open a PR with your changes
7. CI/CD automatically runs the plan for qa/prod
```

### ⚠️ Important Rules

- **NEVER** run `terraform apply` directly against `prod` from your local machine
- **ALWAYS** review the `terraform plan` output before running `apply`
- **DO NOT** edit the tfstate file directly
- **DO NOT** duplicate variables that are already defined in `_shared/common.tfvars`
- If you change something in `_shared/`, **update all layers** that copy those files

---

## 9. Naming Conventions

### Azure Resource Names

All Azure resources follow a standardized naming convention that prioritizes clarity and consistency:

**General Format:** `<resource-type>-<project>-<purpose>-<environment>`

**Network Security Group (NSG) Names:**

| NSG Type | Pattern | Example |
|----------|---------|---------|
| APIM NSG | `nsg-apim-<project>-<environment>` | `nsg-apim-mot-dev` |
| Subnet NSG | `nsg-<project>-<subnet>-<environment>` | `nsg-mot-snet-aca-exp-dev` |

**Key Points:**
- The **environment identifier** (e.g., `dev`, `qa`, `prod`) is placed at the **end** of the name for consistency
- Subnet identifiers (e.g., `snet-aca-exp`, `snet-frontend`) are included to clearly map NSGs to their associated subnets
- This naming convention allows for easy filtering and sorting in Azure Portal by environment

**Implementation:**
- NSG names are generated dynamically in `infra/modules/networking/main.tf`
- The module accepts `resource_name_prefix` (project name) and `environment` as separate variables
- Environment-specific values are passed from `infra/envs/<env>/_shared/common.tfvars`

### Shared Directory Prefix (`_shared`)

All shared or utility directories are prefixed with an underscore (`_shared`). This convention serves three purposes:

| Purpose | Benefit |
|---------|---------|
| **Alphabetical Sorting** | Directories starting with `_` appear first in file explorers and CLI listings, making shared resources immediately visible |
| **Visual Distinction** | The underscore visually separates utility/shared directories from environment-specific or domain-specific folders |
| **Team Communication** | New developers instantly recognize `_shared` as a "shared utility" without reading documentation |

**Examples in this project:**
- `infra/envs/_shared/` — shared boilerplate (providers, versions, locals, common variables)
- `infra/envs/<env>/_shared/` — environment-specific shared values (common.tfvars)

**This is a convention, not a technical requirement.** Terraform treats `_shared` the same as `shared`. However, the underscore prefix is a widely adopted industry practice (seen in monorepos and large projects) and significantly improves navigation and clarity.

---

## 10. Architecture Decisions

### Why Directory-per-Environment Instead of Workspaces?

Terraform Workspaces share the same backend and do not allow granular permissions per environment. With a dedicated directory per environment:
- The `prod` state is physically isolated from `dev`
- Different Azure RBAC permissions can be applied per environment
- A mistake in `dev` cannot affect `prod`

### Why Separate Layers (app, network, observability, security)?

- **Reduced blast radius**: an `apply` in `app` cannot break the network layer
- **Speed**: the `network` state is small and fast to plan
- **Parallel teams**: infrastructure and application teams can work simultaneously on different layers
- **Explicit dependencies**: layers consume each other via `terraform_remote_state`

### Why Not Terragrunt?

Terragrunt would add a steeper learning curve. The `_shared/` pattern solves 80% of the duplication problem using native Terraform. If the team grows or more than 4 environments are added, Terragrunt would be the natural next step.

### Why Modules in `infra/modules/` Instead of Inline Resources?

Azure resources are complex (20+ parameters for a Cosmos DB account). Extracting them into modules allows:
- Reuse across multiple environments without duplicating logic
- Independent versioning and testing of each module
- Changing the implementation without touching environment-specific files

### Why Underscore Prefix for Shared Directories?

The underscore prefix (`_shared`) is a lightweight convention that:
- **Sorts first alphabetically** — no extra tooling required
- **Distinguishes shared from domain-specific** — clearer intent at a glance
- **Aligns with industry practice** — common in Google, Meta, and other large monorepo projects
- **Zero technical overhead** — Terraform treats `_shared/` the same as `shared/`, but the visual signal helps team coordination

This project applies the convention consistently to all shared directories. If you prefer to rename them to `shared/` or `common/`, the functionality remains identical — only the organizational clarity is lost.
