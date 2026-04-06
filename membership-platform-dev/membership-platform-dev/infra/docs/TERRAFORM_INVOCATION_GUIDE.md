# Terraform Invocation Guide

## Overview

This guide documents the correct way to invoke `terraform plan` and `terraform apply` for each infrastructure layer in this project. Each layer requires specific `-var-file` arguments to ensure all variables are properly supplied.

> **Shell:** All commands below are written for **PowerShell** (Windows).  
> Backtick `` ` `` is the PowerShell line-continuation character.

## Architecture

The infrastructure is organized in layers:
- **network** — Virtual Network, Subnets, NSGs, DNS
- **app** — Container Apps, App Service, ACR, Cosmos DB, SQL, Storage
- **observability** — Log Analytics, Application Insights, Monitoring
- **security** — Key Vault, Managed Identities, RBAC

Each layer has:
1. **Shared variables** in `infra/envs/<env>/_shared/common.tfvars` (applied to ALL layers)
2. **Layer-specific variables** in `infra/envs/<env>/<layer>/<env>.tfvars` (applied to THAT layer only)

## Critical: The Two-File Pattern

**All layers REQUIRE both var-files in the correct order.**

The shared `common.tfvars` sits one level above each layer directory:

```
infra/envs/dev/
├── _shared/
│   └── common.tfvars   ← shared for all layers in this env
├── network/
│   └── dev.tfvars
├── app/
│   └── dev.tfvars
├── observability/
│   └── dev.tfvars
└── security/
    └── dev.tfvars
```

From any layer directory (e.g., `infra/envs/dev/network/`), the relative path to the shared file is **`../_shared/common.tfvars`** (one level up).

### Why Both Files Are Required

- **`../_shared/common.tfvars`** provides base variables used across ALL layers:
  - `project` (e.g., `mot`)
  - `environment` (e.g., `dev`, `qa`, `prod`)
  - `location` (e.g., `eastus`)
  - `owner` (e.g., `devops-team`)
  - `cost_center` (e.g., `IT-MOT-001`)
  - `criticality` (e.g., `low`, `medium`, `high`, `critical`)
  - `workload` (e.g., `mot`)

- **`<env>.tfvars`** provides layer-specific variables:
  - `vnet_cidr`, `subnets` (network layer)
  - `aca_services`, `acr_sku` (app layer)
  - etc.

If only the layer-specific file is provided, variables like `cost_center` will prompt interactively.

## Layer-Specific Invocations

### Network Layer

**Directory:** `infra/envs/dev/network/`

```powershell
cd infra/envs/dev/network

# Plan
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"

# Apply
C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

**Variables supplied from `_shared/common.tfvars`:**
- `project`, `environment`, `location`, `owner`, `cost_center`, `criticality`, `workload`

**Variables supplied from `dev.tfvars`:**
- `enable_private_endpoints`, `vnet_cidr`, `subnets`

---

### App Layer

**Directory:** `infra/envs/dev/app/`

```powershell
cd infra/envs/dev/app

# Plan
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"

# Apply
C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

**Variables supplied from `_shared/common.tfvars`:**
- `project`, `environment`, `location`, `owner`, `cost_center`, `criticality`, `workload`

**Variables supplied from `dev.tfvars`:**
- `aca_services`, `acr_sku`, `sql_server_name`, `cosmos_account_name`, etc.

---

### Observability Layer

**Directory:** `infra/envs/dev/observability/`

```powershell
cd infra/envs/dev/observability

# Plan
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"

# Apply
C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

---

### Security Layer

**Directory:** `infra/envs/dev/security/`

```powershell
cd infra/envs/dev/security

# Plan
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"

# Apply
C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

---

## Backend Initialization

Each layer requires backend initialization before planning. Run this once per workspace/layer:

```powershell
C:\terraform_1.14.7_windows_amd64\terraform.exe init `
  -backend-config="../../backend.hcl"
```

> **Note:** `-backend-config` is only required at `init` time. Subsequent `plan` and `apply` commands do not need it.

---

## Common Issues & Solutions

### Issue: Interactive Prompt for `cost_center`, `owner`, etc.

**Cause:** Only layer-specific tfvars was provided; `_shared/common.tfvars` was missing from the command.

**Solution:** Always include both files:
```powershell
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

### Issue: `Given variables file ../../_shared/common.tfvars does not exist`

**Cause:** The path `../../_shared/common.tfvars` is wrong. The shared file is only **one** level above the layer directory, not two.

**Solution:** Use `../_shared/common.tfvars` (single `..`).

### Issue: Variables Different Between Environments

**Cause:** Each environment (`dev`, `qa`, `prod`) has its own `_shared/common.tfvars` with environment-specific values.

**Solution:** When switching environments, ensure you `cd` into the correct env layer directory so the relative `../_shared/common.tfvars` points to the right file:
```powershell
cd infra/envs/prod/network
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="prod.tfvars"
```

---

## Variable Precedence

Terraform applies variables in this order (later values override earlier ones):

1. Variable defaults in `variables.tf`
2. `-var-file` arguments (in order specified)
3. Environment variables (`TF_VAR_*`)
4. Interactive prompts (if variable has no value by this point)

**In this project:**
- Shared `common.tfvars` is specified FIRST, providing base values
- Layer-specific tfvars is specified SECOND, so it can override shared values if needed

---

## Summary

Always use the two-file pattern from within the layer directory:

```powershell
C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
  -var-file="../_shared/common.tfvars" `
  -var-file="dev.tfvars"
```

This ensures:
- ✓ All shared variables are loaded
- ✓ Layer-specific variables are applied
- ✓ No interactive prompts
- ✓ Consistent configuration across environments
- ✓ CI/CD-friendly and reproducible deployments
