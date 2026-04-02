# Skill: troubleshoot-extension

## Metadata

- Name: troubleshoot-extension
- Version: 2.0.0
- Description: Diagnoses and resolves common issues when developing or running AEM UI Extensions (Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub) backed by Adobe App Builder.
- Last Updated: 2026-03-31

---

## Why this skill exists

UI extensions commonly fail due to configuration/registration mistakes, missing scopes/permissions, host enablement issues, CORS/allowlist problems, or action/runtime errors. This skill provides a fast, structured troubleshooting workflow that reduces iteration time.

---

## AIO CLI Exception

This skill is primarily a **review and diagnostic** skill. AIO CLI usage is not required for the diagnostic process itself, but the agent SHOULD use AIO CLI diagnostic commands to gather information:

```bash
# Check current workspace context
aio where

# View action invocation logs (critical for diagnosing action failures)
aio app logs

# View action logs with tail (follow mode)
aio app logs --tail

# Get deployed app info (URLs, action endpoints, CDN)
aio app info

# Verify the build succeeds (catches config errors)
aio app build

# List available workspaces
aio console workspace list
```

---

## Architecture Context: Where Things Can Break

Understanding the UIX architecture helps pinpoint where failures occur:

```
┌─ LAYER 1: Extension Registration ─────────────────────┐
│  Extension Registry                                     │
│  ├── Is the extension registered?                       │
│  ├── Is it registered for the correct service?          │
│  └── Is it enabled in Extension Manager?                │
│       ↓ FAILURE = extension not visible in host         │
└─────────────────────────────────────────────────────────┘
           │
           ▼
┌─ LAYER 2: Extension Loading ──────────────────────────┐
│  Host Application loads extension iFrame               │
│  ├── Can the browser reach the extension URL?           │
│  ├── Does the iFrame load without errors?               │
│  ├── Does ExtensionRegistration.jsx call register()?    │
│  └── Does the registration handshake complete?          │
│       ↓ FAILURE = extension visible but blank/broken    │
└─────────────────────────────────────────────────────────┘
           │
           ▼
┌─ LAYER 3: UI Rendering ──────────────────────────────┐
│  Extension React SPA renders                           │
│  ├── Does the modal/panel route exist in App.jsx?       │
│  ├── Does attach() succeed in the component?            │
│  ├── Can the extension read host context?               │
│  └── Do React Spectrum components render correctly?     │
│       ↓ FAILURE = UI loads but shows errors/blank       │
└─────────────────────────────────────────────────────────┘
           │
           ▼
┌─ LAYER 4: Action Invocation ─────────────────────────┐
│  UI calls backend action via HTTPS                     │
│  ├── Is the action deployed? (aio app info)             │
│  ├── Is the action URL correct?                         │
│  ├── Does require-adobe-auth pass the IMS token?        │
│  ├── Is the action responding (not timing out)?         │
│  └── Is CORS configured correctly (web: "yes")?         │
│       ↓ FAILURE = action call fails (4xx/5xx/timeout)   │
└─────────────────────────────────────────────────────────┘
           │
           ▼
┌─ LAYER 5: Backend Processing ────────────────────────┐
│  Action executes on I/O Runtime                        │
│  ├── Does the action code parse inputs correctly?       │
│  ├── Are environment variables/secrets available?       │
│  ├── Do AEM API calls succeed (auth, permissions)?      │
│  ├── Do external API calls succeed?                     │
│  └── Is the response within size limits (<1MB)?         │
│       ↓ FAILURE = action returns error response         │
└─────────────────────────────────────────────────────────┘
```

---

## Failure Mode Catalog

### Category 1: Extension Not Visible in Host UI

| Check | Command / Action | What "Good" Looks Like |
|-------|-----------------|----------------------|
| Extension deployed? | `aio app info` | Shows deployed URL and action endpoints |
| Correct workspace? | `aio where` | Shows expected org/project/workspace |
| Correct service? | Check `ext.config.yaml` | Extension registered for correct host service |
| Enabled in Extension Manager? | AEM → Extension Manager | Extension listed and toggled ON |
| API service enabled in Console? | Adobe Developer Console → Project → Services | Correct service (e.g., "AEM CF Editor") added |
| IMS org matches? | Compare `aio where` org with AEM org | Same IMS org ID |
| Browser cache? | Hard refresh (Cmd+Shift+R) | Extension appears after cache clear |

### Category 2: Extension Visible but UI Fails to Load

| Check | Command / Action | What "Good" Looks Like |
|-------|-----------------|----------------------|
| Browser console errors? | DevTools → Console | No errors related to extension |
| iFrame blocked? | DevTools → Console (CSP errors) | No Content-Security-Policy blocks |
| Extension URL reachable? | Open extension URL directly in browser | React SPA loads |
| `register()` called? | Add console.log before register() | Log appears in console |
| Registration handshake? | DevTools → Console (UIX logs) | No "registration timeout" errors |
| Extension ID matches? | Compare Constants.js with ext.config.yaml | IDs are consistent |
| Correct routes in App.jsx? | Check that modal/panel URL routes exist | Routes match URLs in registration |

### Category 3: UI Loads but Action Calls Fail

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| 401 Unauthorized | Missing `require-adobe-auth: true` | Add annotation to action in ext.config.yaml |
| 401 Unauthorized | IMS token expired or invalid | Re-login: `aio login`, re-deploy |
| 403 Forbidden | User lacks AEM permissions for the operation | Check AEM user permissions |
| 404 Not Found | Action not deployed or wrong action name | `aio app deploy`, verify action name in invoke call |
| 500 Internal Server Error | Action code exception | Check `aio app logs` for stack trace |
| 504 Gateway Timeout | Action exceeds timeout limit | Increase timeout in ext.config.yaml annotations, or optimize action |
| CORS error | Action missing `web: "yes"` | Set `web: "yes"` on action in ext.config.yaml |
| Network error | Local dev not running | Run `aio app dev` |
| Payload too large | Response exceeds I/O Runtime limit (~1MB) | Paginate or reduce response data |

### Category 4: Authentication and Permission Failures

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| IMS token missing in action | `require-adobe-auth` not set | Add `require-adobe-auth: true` annotation |
| AEM API returns 401 | Service credentials not configured | Add AEM API service in Developer Console |
| AEM API returns 403 | Insufficient AEM permissions | Grant the service user or delegated user correct AEM permissions |
| Token delegation fails | Wrong token type | Verify user token delegation vs service token flow |
| "Invalid client" error | Wrong client ID / credentials | Verify workspace credentials: `aio app use` |
| `Error: You are not logged in` | AIO CLI session expired | Run `aio login`, then retry the failed command |
| `Error: jwt expired` / `jwt malformed` / `invalid_token` | Expired IMS token | Run `aio login`, then retry the failed command |
| `Error: context not configured` / `No IMS context found` | No saved AIO login context | Run `aio login`, then `aio app use`, then retry |

### Category 5: Deployment and Environment Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Old version still showing | CDN cache | Wait for CDN propagation or clear cache |
| Old version still showing | Deployed to wrong workspace | `aio where` to verify, redeploy to correct workspace |
| Build fails | Configuration error | Check `aio app build` output, fix ext.config.yaml |
| Deploy fails | Workspace credentials expired | `aio login` then `aio app use` |
| Works locally but not deployed | Missing env vars in deployed workspace | Set env vars in Developer Console for the workspace |
| Different behavior per environment | Workspace-specific config differences | Compare `.env` files across workspaces |

### Category 6: Performance Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Slow first action call | I/O Runtime cold start | Pre-warm or accept 1-3s first call latency |
| Slow subsequent calls | Chatty API pattern | Batch API calls, add caching |
| UI feels sluggish | Large bundle size | Lazy-load heavy components, check bundle with analyzer |
| Action timeouts on large data | Response payload too large | Paginate, stream, or reduce data |

---

## Agent Behavior Instructions

The agent MUST:

1. **Identify the host** (CFE, UE, CF Console, Experience Hub) and the failing extension point(s).
2. **Classify the failure** using the layered architecture model above (Layer 1-5). Start from the top layer and work down.
3. **Detect and recover from AIO authentication failures**: if any `aio` diagnostic command (e.g., `aio where`, `aio app logs`, `aio app info`) fails with an auth error (`not logged in`, `jwt expired`, `invalid_token`, `context not configured`, HTTP 401), the agent MUST:
   - Stop the current diagnostic step.
   - Prompt the user to run `aio login` and complete the browser auth flow.
   - After the user confirms login, re-run the failed command and continue troubleshooting from that point.
3. **Request or infer minimal diagnostics** without stalling:
   - Browser console errors (screenshots or copy-paste)
   - `aio app logs` output (for action failures)
   - `aio where` output (to verify workspace context)
   - `aio app info` output (to verify deployment)
   - Relevant `ext.config.yaml` sections
   - Environment variable names (NOT values)
4. **Produce a ranked hypothesis list** (most likely cause first) using the Failure Mode Catalog above.
5. **Provide step-by-step verification actions** with clear "what good looks like" indicators.
6. **Provide fix guidance** that is:
   - Host-specific (CFE vs UE vs Console)
   - Environment-specific (dev/stage/prod)
   - Safe (no secret leakage, no bypassing auth)

The agent SHOULD:

- Start with the most common causes: workspace mismatch, missing `require-adobe-auth`, Extension Manager not enabled, stale deployment.
- Suggest a minimal reproduction path if the issue is unclear.
- Recommend adding structured logging or correlation IDs to improve future debugging.
- Reference the Failure Mode Catalog tables above.

The agent MUST NOT:

- Ask for secret values, API keys, or tokens.
- Suggest bypassing security controls (removing `require-adobe-auth`, disabling CSP) to "make it work".
- Suggest using third-party debugging tools — use browser DevTools, `aio app logs`, and AIO CLI commands.

---

## Required Inputs

At minimum:

- Host: Content Fragment Editor, Universal Editor, CF Console, or Experience Hub
- Symptoms (what the user sees, including error messages)
- Target environment (dev/stage/prod)

Helpful (if available):

- Browser console errors
- `aio app logs` output
- `aio where` output
- `aio app info` output
- `ext.config.yaml` excerpts
- `ExtensionRegistration.jsx` excerpts

---

## Output Contract

The output MUST include:

1. **Problem summary**
2. **Architecture layer** where the failure occurs (Layer 1-5)
3. **Host + extension point(s) involved**
4. **Observations** (from provided diagnostics)
5. **Ranked hypotheses** (most likely first, with reasoning)
6. **Verification checklist** (step-by-step, with expected outcomes)
7. **Fix plan** (specific config/code changes)
8. **Prevention recommendations** (logging, CI checks, configuration validation)

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| UIX Troubleshooting Guide | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| App Builder Debugging | https://developer.adobe.com/app-builder/docs/getting_started/first_app/#6-debugging-the-application |
| I/O Runtime System Settings (Limits) | https://developer.adobe.com/runtime/docs/guides/using/system_settings/ |
| AIO CLI Reference | https://developer.adobe.com/app-builder/docs/getting_started/ |
| Extension Manager | https://developer.adobe.com/uix/docs/guides/publication/ |
| Official UIX Examples | https://github.com/adobe/aem-uix-examples |
| UIX SDK Source | https://github.com/adobe/uix-sdk |

---

## Example Usage Prompts

### Extension not visible (CFE)

```
Use troubleshoot-extension. Our Content Fragment Editor header menu
extension is not showing up. We deployed to the dev workspace with
`aio app deploy` and it succeeded. `aio where` shows the correct org
and project. What should we check?
```

### Action returns 401 (UE)

```
Use troubleshoot-extension. Our Universal Editor panel extension loads
fine, but when we click the button to call our backend action, we get a
401 Unauthorized error. Here are the browser console errors:
[paste errors]. What's wrong?
```

### Works locally but not after deploy

```
Use troubleshoot-extension. Our CF Console extension works perfectly with
`aio app dev` but after deploying to the stage workspace, the action
returns 500 errors. `aio app logs` shows "undefined" for AEM_HOST.
Help us fix this.
```

### Performance issue

```
Use troubleshoot-extension. Our Content Fragment Editor extension loads
but the modal takes 5+ seconds to show results after clicking the action
button. This is too slow for our users. What can we optimize?
```
