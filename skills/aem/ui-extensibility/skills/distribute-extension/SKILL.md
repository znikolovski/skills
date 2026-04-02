# Skill: distribute-extension

## Metadata

- Name: distribute-extension
- Version: 2.0.0
- Description: Packages, deploys, and promotes an AEM UI Extension (Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub) across App Builder workspaces using the AIO CLI.
- Last Updated: 2026-03-31

---

## When to use

Use this skill after the extension passes `build-extension` (and ideally `validate-and-harden`) to:

- Build production-optimized bundles
- Deploy to App Builder workspaces (dev → stage → prod)
- Register the extension in the Extension Registry so the host application can discover it
- Manage the extension lifecycle via the AEM Extension Manager

---

## AIO CLI Is Required

### Authentication Failure Recovery

If any `aio` command fails with an authentication error, the agent MUST:

1. **Stop** execution of the current step immediately.
2. **Inform the user** that re-authentication is required and prompt them to run:
   ```bash
   aio login
   ```
3. **Wait** for the user to confirm the login succeeded (browser auth flow completes).
4. **Retry** the failed command from the beginning of that step.

Common auth error indicators to watch for:
- `Error: You are not logged in`
- `Error: jwt expired` / `Error: jwt malformed` / `Error: invalid_token`
- HTTP 401 in any `aio` command output
- `Error: context not configured`
- `Error: No IMS context found`

This skill MUST use the AIO CLI for all deployment and promotion operations:

```bash
# Verify current context before deploying
aio where

# Build production-optimized bundle
aio app build

# Deploy to the currently selected workspace
aio app deploy

# Deploy only actions (no UI changes)
aio app deploy --skip-static

# Deploy only static UI assets (no action changes)
aio app deploy --skip-actions

# Undeploy (remove from current workspace)
aio app undeploy

# View action logs after deployment
aio app logs

# Switch workspace for promotion
aio console workspace select <workspace-name>

# Import workspace credentials after switching
aio app use

# Get deployed app info (URLs, action endpoints)
aio app info
```

---

## Architecture: Deployment and Extension Discovery

```
┌─────────────────────────────────────────────────────────┐
│  Developer Machine                                       │
│  aio app build → aio app deploy                          │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Adobe I/O Runtime (workspace-specific namespace)        │
│  ┌─────────────────────────────────────────────────────┐│
│  │  Actions: deployed to runtime namespace              ││
│  │  Static UI: served via CDN                           ││
│  │  Extension: registered in Extension Registry         ││
│  └─────────────────────────────────────────────────────┘│
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Extension Registry                                      │
│  Host applications query the registry to discover        │
│  which extensions are available for their extension       │
│  points and the current user/org context                  │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  AEM Extension Manager                                   │
│  ┌─────────────────────────────────────────────────────┐│
│  │  Controls which extensions are enabled/disabled      ││
│  │  per AEM environment (author instance)               ││
│  │  Admins can enable/disable extensions per-instance   ││
│  └─────────────────────────────────────────────────────┘│
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  AEM Host Application (CFE / UE / CF Console / Exp Hub)  │
│  Loads enabled extensions into iFrames at the            │
│  designated extension points                             │
└─────────────────────────────────────────────────────────┘
```

### Workspace-based environment promotion

App Builder uses **workspaces** for environment separation. Each workspace has its own:
- Runtime namespace (isolated action deployment)
- Credentials and secrets
- CDN endpoint for static assets
- Extension Registry entry

**Promotion workflow:**

```
Development workspace  →  Stage workspace  →  Production workspace
   (aio app deploy)       (aio app deploy)     (aio app deploy)
```

Each promotion requires:
1. Switch workspace: `aio console workspace select <name>`
2. Import credentials: `aio app use`
3. Verify `.env` has correct environment-specific values
4. Build and deploy: `aio app build && aio app deploy`
5. Verify deployment: `aio app info` + smoke test in host

---

## Critical Rule: One Extension Per Repository

Each GitHub repository MUST contain exactly **one** AEM UI extension. Deployment operates on the entire repo — `aio app deploy` deploys everything. The agent must verify only one extension exists before deploying. See `analyze-and-plan` for the full rationale.

---

## Agent Behavior Instructions

When executing this skill, the agent MUST:

1. **Verify this is a single-extension project** before deploying.
2. **Validate production readiness inputs**:
   - Ensure `.env` has the correct values for the target workspace.
   - Ensure `ext.config.yaml` actions have `require-adobe-auth: true` where needed.
   - Run `aio app build` to catch configuration errors before deploying.
2. **Execute the deployment via AIO CLI**:
   - `aio where` to confirm the correct workspace.
   - `aio app build` to create production bundles.
   - `aio app deploy` to deploy actions + static assets + register extension.
3. **Verify extension registration** after deployment:
   - `aio app info` to see deployed URLs and action endpoints.
   - Open the host application and verify the extension appears at the correct extension point.
4. **Provide Extension Manager guidance**:
   - After deployment, the extension must be **enabled** in the AEM Extension Manager for the target AEM environment.
   - Provide steps to access the Extension Manager and enable the extension.
5. **Produce a rollback plan**:
   - How to revert: `aio app undeploy` removes the extension from the current workspace.
   - For quick rollback: disable the extension in the Extension Manager (no redeploy needed).
   - For full rollback: switch to previous workspace version and redeploy.
6. **Provide release documentation** (release notes draft, operational notes, smoke test checklist).

The agent SHOULD:

- Recommend CI/CD pipeline steps (GitHub Actions, etc.) for automated deployments.
- Include a post-deployment monitoring checklist (logs, error rates, latency).
- Highlight any manual steps required in AEM (enabling in Extension Manager).
- Provide a smoke test plan specific to the extension's host (CFE/UE/Console).

The agent MUST NOT:

- Assume a single environment or single tenant.
- Skip the `aio where` verification before deployment.
- Deploy to production without confirming the developer has reviewed the changes.

---

## Smoke Test Templates

### CFE Extension Smoke Test

1. Open a Content Fragment in the editor
2. Verify the extension button appears in the header menu
3. Click the button → verify the modal opens without errors
4. Perform the extension's action → verify the result
5. Check browser console for errors
6. Check `aio app logs` for action invocation logs

### UE Extension Smoke Test

1. Open a page in the Universal Editor
2. Verify the extension panel appears in the right rail (or button in header)
3. Open the panel → verify it loads content
4. Interact with the extension → verify actions complete
5. Check browser console for errors
6. Check `aio app logs` for action invocation logs

### CF Console Extension Smoke Test

1. Open the Content Fragment Console
2. Select one or more fragments
3. Verify the action bar button appears
4. Click the button → verify the modal or action works
5. Check browser console for errors
6. Check `aio app logs` for action invocation logs

---

## Required Inputs

- Completed App Builder project (built + tested via `build-extension`)
- Target deployment workspace (dev/stage/prod)
- Distribution requirements (internal-only vs public)
- AEM environment details (for Extension Manager enablement)

---

## Output Contract

The output MUST include:

1. **Pre-deployment checklist** (workspace verification, config validation)
2. **AIO CLI deployment commands** (exact sequence)
3. **Post-deployment verification steps** (`aio app info`, host verification)
4. **Extension Manager enablement steps** (for the target AEM environment)
5. **Smoke test plan** (host-specific, from templates above)
6. **Release notes draft**
7. **Rollback plan** (Extension Manager disable + `aio app undeploy`)
8. **CI/CD recommendations** (optional, for automated pipelines)

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| App Builder Deployment Guide | https://developer.adobe.com/app-builder/docs/getting_started/first_app/#7-deploying-the-application |
| Extension Publication / Distribution | https://developer.adobe.com/uix/docs/guides/publication/ |
| AEM Extension Manager | https://developer.adobe.com/uix/docs/guides/publication/ |
| App Builder CI/CD | https://developer.adobe.com/app-builder/docs/guides/deployment/ |
| AIO CLI Commands Reference | https://developer.adobe.com/app-builder/docs/getting_started/ |
| Official UIX Examples | https://github.com/adobe/aem-uix-examples |

---

## Example Usage Prompts

### Deploy to dev

```
Use distribute-extension to deploy our Content Fragment Editor extension
to the dev workspace. Verify it appears in the CFE header menu and the
backend action responds correctly. Provide a smoke test plan.
```

### Promote to production

```
Use distribute-extension to promote our Universal Editor panel extension
from stage to production. Include workspace switch commands, deployment
steps, Extension Manager enablement, a smoke test plan, and a rollback
plan.
```

### CI/CD setup

```
Use distribute-extension to recommend a GitHub Actions CI/CD pipeline for
our CF Console extension. The pipeline should build, test, and deploy to
stage on PR merge, and deploy to production on release tag.
```
