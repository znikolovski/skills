# Skill: configure-and-register

## Metadata

- Name: configure-and-register
- Version: 2.0.0
- Description: Applies and verifies App Builder + AEM host configuration, including extension manifests, registration, environment variables, workspace management, and host enablement steps for CFE, UE, CF Console, and Experience Hub.
- Last Updated: 2026-03-31

---

## Why this skill exists

Configuration and registration issues are the **#1 cause of extension failures** — wrong manifest, missing scopes, incorrect workspace, stale environment variables. This skill makes configuration a first-class, repeatable workflow using the AIO CLI.

---

## AIO CLI Is Required

This skill uses the AIO CLI for all configuration and workspace management:

```bash
# Verify current context (org, project, workspace)
aio where

# Switch workspace (dev/stage/prod)
aio console workspace select

# List available workspaces
aio console workspace list

# Import App Builder config from Adobe Developer Console
aio app use

# Set environment variables for the current workspace
aio app config set <key> <value>

# View current configuration
aio app info

# Validate configuration and build
aio app build
```

---

## Architecture: How Configuration Connects Extension to Host

```
┌─────────────────────────────────────────────────────┐
│  Adobe Developer Console                             │
│  ┌───────────────────────────────────────────────┐  │
│  │  Project                                       │  │
│  │  ├── Workspace: Development                    │  │
│  │  │   ├── Services: AEM CF Editor, AEM Author   │  │
│  │  │   ├── Credentials: OAuth / JWT              │  │
│  │  │   └── Runtime namespace: aem-ext-dev        │  │
│  │  ├── Workspace: Stage                          │  │
│  │  │   └── (same structure, different namespace) │  │
│  │  └── Workspace: Production                     │  │
│  │      └── (same structure, different namespace) │  │
│  └───────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────┘
                       │ aio app use (downloads .env + .aio)
                       ▼
┌─────────────────────────────────────────────────────┐
│  Local Project                                       │
│  ├── .env                ← workspace-specific vars   │
│  ├── .aio                ← workspace context         │
│  ├── app.config.yaml     ← root config               │
│  └── src/dx-excshell-1/                              │
│      └── ext.config.yaml ← extension config          │
└──────────────────────┬──────────────────────────────┘
                       │ aio app deploy
                       ▼
┌─────────────────────────────────────────────────────┐
│  Adobe I/O Runtime (workspace namespace)             │
│  ├── Actions deployed                                │
│  ├── Static UI assets served via CDN                 │
│  └── Extension registered in Extension Registry      │
│       → Host discovers extension via registry        │
└─────────────────────────────────────────────────────┘
```

### Key configuration files

#### `app.config.yaml` (root)

```yaml
application:
  hostname: "my-extension"
  actions: actions
  web: web-src
extensions:
  dx/excshell/1:
    $include: src/dx-excshell-1/ext.config.yaml
```

#### `ext.config.yaml` (extension-specific)

```yaml
operations:
  view:
    - type: web
      impl: index.html
actions: actions
web: web-src
runtimeManifest:
  packages:
    my-extension:
      license: Apache-2.0
      actions:
        my-action:
          function: actions/my-action/index.js
          web: "yes"
          runtime: nodejs:18
          inputs:
            LOG_LEVEL: debug
            AEM_HOST: $AEM_HOST
          annotations:
            require-adobe-auth: true
            final: true
```

#### `.env` (workspace-specific, never commit)

```bash
# Auto-populated by `aio app use` for the selected workspace
AIO_runtime_namespace=12345-myproject-dev
AIO_runtime_auth=<runtime-auth-key>

# Custom environment variables
AEM_HOST=https://author-p12345-e67890.adobeaemcloud.com
SERVICE_API_KEY=<api-key>
```

---

## Critical Rule: One Extension Per Repository

Each GitHub repository MUST contain exactly **one** AEM UI extension. The `app.config.yaml` must reference a single extension entry. If the project contains multiple extensions, stop and advise splitting into separate repositories. See `analyze-and-plan` for the full rationale.

---

## Agent Behavior Instructions

The agent MUST:

1. **Verify this is a single-extension project** — the `app.config.yaml` must have exactly one extension entry.
2. **Treat configuration as environment-specific**:
   - Use AIO CLI workspaces to separate dev/stage/prod.
   - Run `aio console workspace select` to switch environments.
   - Run `aio app use` to import the correct credentials for each workspace.
   - Never hardcode environment-specific values in `ext.config.yaml` — use `$VARIABLE` references that resolve from `.env`.
3. **Validate the `ext.config.yaml`** for the correct host:
   - Ensure `operations.view` points to the correct entry point.
   - Ensure actions are declared with correct `runtime`, `inputs`, and `annotations`.
   - `require-adobe-auth: true` MUST be set on actions that need IMS authentication.
4. **Verify extension registration**:
   - After `aio app deploy`, the extension should appear in the Extension Registry.
   - The host application discovers extensions via the registry — if the extension is not registered, it will not appear.
5. **Validate required IMS scopes and API services**:
   - Ensure the correct API services are added to the project in Adobe Developer Console.
   - For CFE extensions: `AEM Content Fragment Editor` service must be enabled.
   - For UE extensions: `AEM Universal Editor` service must be enabled.
   - For CF Console extensions: `AEM Content Fragment Console Admin` service must be enabled.
6. **Produce verification steps** the developer can run to confirm everything works.

The agent SHOULD:

- Provide a "known failure modes" section (see below).
- Warn about common pitfalls: stale `.env` after workspace switch, missing `require-adobe-auth`, incorrect `$include` paths.
- Recommend running `aio app build` after every configuration change to catch errors early.

The agent MUST NOT:

- Deploy production changes (that's `distribute-extension`).
- Store secrets in plaintext in any tracked file.
- Modify the Adobe Developer Console project configuration directly — guide the user to do it via the Console UI or AIO CLI.

---

## Known Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Extension not visible in host | Extension not deployed, or wrong workspace | `aio where` → verify workspace, then `aio app deploy` |
| Extension not visible in host | Required API service not enabled in Console | Add the correct service in Adobe Developer Console |
| 401 Unauthorized on action calls | Missing `require-adobe-auth: true` on action | Add annotation in `ext.config.yaml` |
| 401 Unauthorized on action calls | Wrong IMS scopes / credentials for workspace | Check credentials in Developer Console for this workspace |
| 403 Forbidden on AEM API calls | IMS token doesn't have required AEM permissions | Verify user/service has correct AEM permissions |
| Action timeout | Default timeout too low for long-running operations | Increase `timeout` in action annotations (max 300000ms) |
| CORS errors in browser | Action not configured as `web: "yes"` | Set `web: "yes"` on the action in `ext.config.yaml` |
| `.env` has wrong values after workspace switch | Forgot to run `aio app use` after `aio console workspace select` | Run `aio app use` to refresh `.env` |
| Extension loads but shows blank | Wrong entry point in `operations.view` | Verify `impl: index.html` path is correct |

---

## Required Inputs

- Target UI surface: Content Fragment Editor, Universal Editor, CF Console, or Experience Hub
- App Builder configuration from user (`app.config.yaml` + `ext.config.yaml`)
- Target environments (dev/stage/prod) and current workspace
- Required integrations (AEM APIs, external APIs) and their scopes

---

## Output Contract

The output MUST include:

1. **Configuration change list** (what files/values to change, with before/after)
2. **`ext.config.yaml` guidance** (complete or patch-style, host-specific)
3. **Environment variable checklist** (what must be in `.env` for each workspace)
4. **IMS scopes / API services checklist** (what must be enabled in Developer Console)
5. **AIO CLI commands** to apply and verify the configuration
6. **Verification steps** (how to confirm registration + basic functionality)
7. **Known failure modes** relevant to this specific configuration

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| App Builder Configuration Guide | https://developer.adobe.com/app-builder/docs/guides/configuration/ |
| Extension Registration | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| App Builder Environment Variables | https://developer.adobe.com/app-builder/docs/guides/configuration/#environment-variables |
| Adobe Developer Console | https://developer.adobe.com/developer-console/docs/guides/ |
| Extension Manager (AEM) | https://developer.adobe.com/uix/docs/guides/publication/ |
| Official UIX Examples | https://github.com/adobe/aem-uix-examples |

---

## Example Usage Prompts

### CFE

```
Use configure-and-register to validate and update configuration for a
Content Fragment Editor extension. Ensure ext.config.yaml is correct,
required API services are enabled in Developer Console, actions have
require-adobe-auth set, and the extension registers in the dev workspace.
```

### UE

```
Use configure-and-register to set up workspace-specific configuration
for a Universal Editor rail panel extension across dev and stage. Include
steps to verify the extension appears in the Universal Editor UI.
```

### Multi-environment promotion

```
Use configure-and-register to prepare the configuration for promoting
our CF Console extension from dev to stage workspace. Show the AIO CLI
commands to switch workspaces, update .env, and verify registration in
the stage environment.
```
