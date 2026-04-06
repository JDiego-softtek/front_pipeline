# Implementation Plan — ACA Multi-Service Expansion + APIM/FrontDoor Wiring

## Context

Current state:
- Single ACA service key `membership` in `dev.tfvars` → produces `ca-membership-mot-dev` (once bug fixed)
- Bug in `infra/modules/aca/main.tf`: name was `"ca-${var.resource_name}"` ignoring `each.key`
- Single APIM API `auth` pointing to `membership` backend
- FrontDoor routes `/api/*` → APIM, `/*` → frontend, `/appservice/*` → App Service

Target state:
- 5 ACA services sharing the same user-assigned identity
- 5 APIM APIs following `api/{servicename}` path pattern
- FrontDoor unchanged (already routes `/api/*` → APIM which handles per-service routing)

---

## Files to Change

| # | File | Action |
|---|------|--------|
| 1 | `infra/modules/aca/main.tf` | Fix/verify naming bug → `"ca-${each.key}-${var.resource_name}"` |
| 2 | `infra/envs/dev/app/dev.tfvars` | Add 4 new ACA services + replace APIM APIs |

No changes needed to:
- `ingress.tf` — APIM module already consumes `var.apim_apis` dynamically; FrontDoor already routes `/api/*` to APIM
- `modules/apim/main.tf` — already iterates `var.apis` with `for_each`
- `modules/frontdoor/main.tf` — `/api/*` pattern already captures all service paths

---

## Step 1 — Fix ACA Module Naming Bug

**File:** `infra/modules/aca/main.tf`

Current (buggy) line:
```
name = "ca-${var.resource_name}"
```

Fixed line:
```
name = "ca-${each.key}-${var.resource_name}"
```

Result per environment (e.g., `resource_name = "mot-dev"`):
| Key | Container App Name |
|-----|-------------------|
| membership | ca-membership-mot-dev |
| signup | ca-signup-mot-dev |
| renewal | ca-renewal-mot-dev |
| membership-external | ca-membership-external-mot-dev |
| validations | ca-validations-mot-dev |

**Status:** Already applied in working tree — verify only.

---

## Step 2 — Update dev.tfvars: ACA Services

Replace the single `membership` entry with all 5 services.

All services share:
- Placeholder image: `nginx:alpine`
- CPU: `0.5`, Memory: `1Gi`
- Same user-assigned identity (passed via `identity_id` in `aca.tf`)
- `transport = "http"`, `target_port = 80`

`external_enabled` policy:
| Service | external_enabled | Reason |
|---------|-----------------|--------|
| membership | true | existing config, BFF frontend |
| signup | false | internal, accessed via APIM |
| renewal | false | internal, accessed via APIM |
| membership-external | true | name implies external access |
| validations | false | internal, accessed via APIM |

Note: Keys with hyphens (`membership-external`) must be quoted in HCL.

---

## Step 3 — Update dev.tfvars: APIM APIs

Replace the `auth` API with 5 service-specific APIs.

Pattern: `path = "api/{servicename}"`

| APIM Key | display_name | path | backend_service |
|----------|-------------|------|----------------|
| membership | Membership API | api/membership | membership |
| signup | Signup API | api/signup | signup |
| renewal | Renewal API | api/renewal | renewal |
| membership-external | Membership External API | api/membership-external | membership-external |
| validations | Validations API | api/validations | validations |

The `ingress.tf` already does:
```hcl
backend_url = "https://${module.aca.service_fqdns[api_cfg.backend_service]}"
```
so each APIM API automatically resolves the ACA FQDN for its backend.

---

## Step 4 — FrontDoor Routing Verification

No code changes needed. Current routing:
- `/api/*` → APIM (handles all 5 services via path-based routing: `api/membership`, `api/signup`, etc.)
- `/*` → frontend (ACA membership service)
- `/appservice/*` → App Service

The single `/api/*` pattern in FrontDoor routes all service API calls to APIM, which then distributes based on the `api/{servicename}` prefix.

---

## Checklist

- [ ] Step 1: Verify/apply ACA naming bug fix in `modules/aca/main.tf`
- [ ] Step 2: Update `aca_services` in `dev.tfvars` (5 services)
- [ ] Step 3: Update `apim_apis` in `dev.tfvars` (5 APIs with `api/{name}` paths)
- [ ] Step 4: Confirm FrontDoor requires no changes
- [ ] Step 5: Delete this temp plan file when done

---

## Notes for Other Environments

When adding these services to QA/Prod:
1. Copy the same 5-service structure into the respective `{env}.tfvars`
2. Replace placeholder `nginx:alpine` images with real ACR image references
3. Adjust `external_enabled` per environment security policy (likely all `false` in prod)
4. `resource_name` drives the suffix automatically (e.g., `mot-qa`, `mot-prod`)
