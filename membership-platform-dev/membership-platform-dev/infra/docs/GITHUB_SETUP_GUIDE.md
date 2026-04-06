# GitHub Configuration Guide — Infrastructure Pipelines

This guide covers every setting that must be configured in GitHub before the
infrastructure workflows can run successfully.

There are **two workflows**:

| Workflow | File | Purpose |
|----------|------|---------|
| **Foundations** | `.github/workflows/infra-platform.yml` | Deploys network, security, identities, observability |
| **App Layer** | `.github/workflows/infra-app.yml` | Deploys app and rbac stacks |

---

## Prerequisites

Before touching GitHub, have these values ready from your Azure setup:

| Value | Where to find it | Example |
|-------|-----------------|---------|
| Subscription ID | Azure Portal → Subscriptions | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Tenant ID | Azure Portal → Entra ID → Overview | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Service Principal Client ID | App Registration → Overview → Application (client) ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Service Principal Client Secret | App Registration → Certificates & secrets | `~xxxxxxxxxxxxxxxxxxxxxxxx` |
| Backend Resource Group | Where your Terraform state storage account lives | `rg-membership-eus2-01` |
| Backend Storage Account | Storage account for `.tfstate` blobs | `statetfmembershipdev` |
| Backend Container | Blob container name | `tfstate` |

---

## Step 1 — Create GitHub Environments

The workflows use GitHub Environments to gate deployments with required
reviewer approvals and to scope secrets to specific stages.

Three environments are required for `dev`. If you add `staging` or `prod`
later, repeat this step for each.

### 1.1 Navigate to Environments

1. Go to your repository on GitHub.
2. Click **Settings** → **Environments** (left sidebar).
3. Click **New environment** for each environment below.

> **Important — Required Reviewers:**
> The `dev-*` environments should **NOT** have Required Reviewers configured.
> Both `plan` and `apply` use the same environment to access credentials — if
> reviewers are required, the job will wait indefinitely even for a `plan`.
> Reserve Required Reviewers for `staging-*` and `prod-*` environments only.

### 1.2 Create `dev-platform`

Used by `infra-platform.yml` (foundations) for both plan and apply runs.

1. Name: `dev-platform`
2. Click **Configure environment**.
3. Under **Deployment protection rules**: **Leave empty — do not add reviewers for dev.**
4. Leave **Deployment branches** as **All branches** (or restrict to `dev`/`main`).
5. Click **Save protection rules**.

### 1.3 Create `dev-app-validation`

Used by `infra-app.yml` to validate prerequisite stacks before deployment begins.

1. Name: `dev-app-validation`
2. Click **Configure environment**.
3. Under **Deployment protection rules**: No reviewers needed — this is an automatic check.
4. Click **Save protection rules**.

### 1.4 Create `dev-app`

Used by `infra-app.yml` for both plan and apply runs of the app and rbac stacks.

1. Name: `dev-app`
2. Click **Configure environment**.
3. Under **Deployment protection rules**: **Leave empty — do not add reviewers for dev.**
4. Click **Save protection rules**.

---

## Step 2 — Add Secrets and Variables to Each Environment

Each environment needs **7 values**: 1 secret and 6 variables.

> **Secret vs Variable**: Secrets are encrypted and never printed in logs.
> Variables are plain text and appear in workflow logs.
> The client secret must be a Secret; the rest can be Variables.

### 2.1 Add values to `dev-platform`

Go to **Settings → Environments → dev-platform → Configure environment**.

#### Secrets (encrypted)

Click **Add secret** for each:

| Name | Value |
|------|-------|
| `AZURE_CLIENT_SECRET` | Your service principal client secret |

#### Variables (plain text)

Click **Add variable** for each:

| Name | Value |
|------|-------|
| `AZURE_CLIENT_ID` | Service principal Application (client) ID |
| `AZURE_TENANT_ID` | Azure Entra ID tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `TF_BACKEND_RG` | Resource group of the Terraform state storage account (`rg-membership-eus2-01`) |
| `TF_BACKEND_STORAGE_ACCOUNT` | Storage account name (`statetfmembershipdev`) |
| `TF_BACKEND_CONTAINER` | Blob container name (`tfstate`) |

### 2.2 Add values to `dev-app-validation`

Go to **Settings → Environments → dev-app-validation → Configure environment**.

Add the **exact same secrets and variables** as `dev-platform` (same names, same values).

The `validate-prerequisites` job runs Azure CLI commands to check state blobs and needs credentials.

### 2.3 Add values to `dev-app`

Go to **Settings → Environments → dev-app → Configure environment**.

Add the **exact same secrets and variables** as `dev-platform`.

---

## Step 3 — Add Repository-Level Variables (Optional)

If you want the `infra-deploy.yml` (general-purpose) workflow to work in
addition to the two main pipelines, add the same 6 variables at the
**repository level** (not environment level):

1. Go to **Settings → Secrets and variables → Actions → Variables tab**.
2. Click **New repository variable** for each variable listed in Step 2.

> Repository-level variables are the fallback when no environment is matched.
> Environment-level values always take precedence.

---

## Step 4 — Set Repository Permissions for Actions

The workflows need read access to repository contents and Actions metadata.

1. Go to **Settings → Actions → General**.
2. Under **Workflow permissions**, select:
   - **Read repository contents and packages permissions** (read-only).
3. Click **Save**.

These permissions match the `permissions:` block declared in both workflow files:
```yaml
permissions:
  contents: read
  actions: read
```

---

## Step 5 — Create the `workflow-test` Branch (Recommended)

Both `infra-platform.yml` and `infra-app.yml` have a secondary push trigger
on the `workflow-test` branch. This lets you test workflow changes without
going through the `workflow_dispatch` UI.

```bash
git checkout -b workflow-test
git push origin workflow-test
```

When you push a change to `.github/workflows/infra-platform.yml` on this
branch, it automatically runs with safe defaults:
- `target=foundations`, `action=plan`, `environment=dev`

When you push a change to `.github/workflows/infra-app.yml` on this branch:
- `target=app`, `action=plan`, `environment=dev`

> **Do not use `workflow-test` for production deployments.**

---

## Step 6 — Configure Branch Protection (Recommended)

Prevent direct pushes to long-lived branches and require PR reviews.

1. Go to **Settings → Branches → Add rule**.
2. Branch name pattern: `dev`
3. Enable:
   - **Require a pull request before merging**
   - **Require status checks to pass before merging** (add the plan jobs once they have run once)
   - **Restrict who can push to matching branches** (platform team only)
4. Click **Create**.

Repeat for `main` / `staging` / `prod` as needed.

---

## Step 7 — Verify Service Principal Permissions

The service principal used by the workflows needs the following Azure RBAC
roles. Assign them in the Azure Portal or via CLI.

### Minimum required roles

| Role | Scope | Why |
|------|-------|-----|
| `Contributor` | Subscription or Resource Group | Create/update/delete infrastructure resources |
| `Storage Blob Data Contributor` | Terraform state storage account | Read and write `.tfstate` blobs |
| `User Access Administrator` | Subscription or Resource Group | Create role assignments in the `rbac` stack |

> If you prefer the principle of least privilege, scope `Contributor` to the
> target resource group (`rg-membership-eus2-01`) instead of the
> whole subscription.

### Assign via Azure CLI

```bash
# Replace with your actual values
SP_OBJECT_ID="<service-principal-object-id>"
SUBSCRIPTION_ID="<subscription-id>"
RG="rg-membership-eus2-01"
STORAGE_ACCOUNT_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/statetfmembershipdev"

# Contributor on the resource group
az role assignment create \
  --assignee "$SP_OBJECT_ID" \
  --role "Contributor" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}"

# Storage Blob Data Contributor on the state storage account
az role assignment create \
  --assignee "$SP_OBJECT_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "$STORAGE_ACCOUNT_ID"

# User Access Administrator on the resource group (for rbac stack)
az role assignment create \
  --assignee "$SP_OBJECT_ID" \
  --role "User Access Administrator" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}"
```

---

## Step 8 — Confirm the Terraform State Container Exists

The storage account and container must exist before any workflow can run.
Run this check once:

```bash
az storage container show \
  --account-name statetfmembershipdev \
  --name tfstate \
  --auth-mode login
```

If missing, create it:

```bash
az storage container create \
  --account-name statetfmembershipdev \
  --name tfstate \
  --auth-mode login
```

---

## Step 9 — Run Your First Plan

### Deploy foundations first

1. Go to **Actions** tab in your repository.
2. Click **Infrastructure Deploy — Platform (Foundations)**.
3. Click **Run workflow**.
4. Select:
   - **target**: `foundations`
   - **action**: `plan`
   - **environment**: `dev`
5. Click **Run workflow**.

Review the plan output. When satisfied:

6. Run again with **action**: `apply`.
7. The `dev-platform` environment requires reviewer approval — approve it to proceed.

### Deploy the app layer

Only after foundations have been applied:

1. Click **Infrastructure Deploy — Application (App/RBAC)**.
2. Click **Run workflow**.
3. Select:
   - **target**: `app`
   - **action**: `plan`
   - **environment**: `dev`
4. The `validate-prerequisites` job runs first and checks that all foundation
   state blobs exist. If it fails, run the foundations apply first.
5. When plan looks good, re-run with **action**: `apply`.
6. The `dev-app` environment requires reviewer approval — approve to proceed.

---

## Environment Summary

| Environment | Used by | Jobs | Requires approval |
|-------------|---------|------|------------------|
| `dev-platform` | `infra-platform.yml` | `terraform-execute` | Yes — platform team |
| `dev-app-validation` | `infra-app.yml` | `validate-prerequisites` | No — automatic |
| `dev-app` | `infra-app.yml` | `terraform-execute` | Yes — app team |

## Secrets & Variables Summary

All three environments need the same 7 values:

| Name | Type | Description |
|------|------|-------------|
| `AZURE_CLIENT_SECRET` | Secret | Service principal client secret |
| `AZURE_CLIENT_ID` | Variable | Service principal Application ID |
| `AZURE_TENANT_ID` | Variable | Entra ID tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Variable | Azure subscription ID |
| `TF_BACKEND_RG` | Variable | Resource group of the state storage account |
| `TF_BACKEND_STORAGE_ACCOUNT` | Variable | Storage account name for `.tfstate` blobs |
| `TF_BACKEND_CONTAINER` | Variable | Blob container name (e.g., `tfstate`) |
