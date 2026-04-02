# Skill: build-extension

## Metadata

- Name: build-extension
- Version: 2.0.0
- Description: Implements and validates an AEM UI Extension (Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub) using Adobe App Builder, the AIO CLI, and the UIX Guest SDK.
- Last Updated: 2026-03-31

---

## When to use

Use this skill after `analyze-and-plan` and `scaffold-extension` to:

- Implement UI components and backend actions
- Wire host context to actions via the UIX Guest SDK
- Validate locally using `aio app dev` and in a dev host environment

---

## Bootstrap Script

A ready-to-run bash template is provided to create and verify a new extension project:

```bash
# Create a new extension project (interactive)
./scripts/create-extension.sh

# Or pass arguments directly: <project-name> <surface>
# Surfaces: cfe | ue | cfc | xp
./scripts/create-extension.sh my-cfe-extension cfe
```

The script handles: prerequisite checks, AIO login, org/project/workspace selection,
`aio app init` with the correct template, `npm install`, and a verification build.

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

This skill uses the AIO CLI for local development and building:

```bash
# Start local development server (hot-reload, serves UI + actions locally)
aio app dev

# Build the project for deployment (validates config, bundles assets)
aio app build

# Run project tests
aio app test

# View action logs (useful during development)
aio app logs

# Get current project/workspace info
aio where
```

---

## Architecture: Extension Registration and Host Communication

### The Extension Registration Pattern

Every AEM UI extension MUST have an `ExtensionRegistration` component that calls `register()` from `@adobe/uix-guest`. This is how the extension declares its capabilities to the host application.

**The registration is the contract between your extension and the host.** It tells the host:
- What extension points you implement
- What buttons/panels/widgets you provide
- What methods the host can call on your extension

### CFE Extension Registration Example

```jsx
// src/dx-excshell-1/web-src/src/components/ExtensionRegistration.jsx
import { register } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function ExtensionRegistration() {
  useEffect(() => {
    const init = async () => {
      const guestConnection = await register({
        id: extensionId,
        methods: {
          // Header menu extension point
          headerMenu: {
            getButtons() {
              return [
                {
                  id: "my-cfe-button",
                  label: "My Action",
                  icon: "Edit",  // Spectrum Workflow icon name
                  onClick: () => {
                    // Open a modal or perform an action
                    const modalURL = "/index.html#/my-modal";
                    guestConnection.host.modal.showUrl({
                      title: "My Action Modal",
                      url: modalURL,
                      width: "640px",
                      height: "480px",
                    });
                  },
                },
              ];
            },
          },
        },
      });
    };
    init().catch(console.error);
  }, []);

  return <></>;  // Registration component renders nothing
}
```

### UE Extension Registration Example

```jsx
// src/dx-excshell-1/web-src/src/components/ExtensionRegistration.jsx
import { register } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function ExtensionRegistration() {
  useEffect(() => {
    const init = async () => {
      const guestConnection = await register({
        id: extensionId,
        methods: {
          // Header menu extension point
          headerMenu: {
            getButtons() {
              return [
                {
                  id: "my-ue-button",
                  label: "Validate Content",
                  icon: "CheckmarkCircle",
                },
              ];
            },
          },
          // Rail panel extension point
          panel: {
            getPanels() {
              return [
                {
                  id: "my-panel",
                  label: "Validation Panel",
                  icon: "CheckmarkCircle",
                  url: "/index.html#/panel",
                },
              ];
            },
          },
        },
      });
    };
    init().catch(console.error);
  }, []);

  return <></>;
}
```

### CF Console Extension Registration Example

```jsx
// src/dx-excshell-1/web-src/src/components/ExtensionRegistration.jsx
import { register } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function ExtensionRegistration() {
  useEffect(() => {
    const init = async () => {
      const guestConnection = await register({
        id: extensionId,
        methods: {
          // Action bar extension point (shown when fragments are selected)
          actionBar: {
            getButtons() {
              return [
                {
                  id: "my-action-bar-btn",
                  label: "Bulk Export",
                  icon: "Export",
                  onClick: (selections) => {
                    // selections contains the selected fragment paths
                    const modalURL = "/index.html#/bulk-export";
                    guestConnection.host.modal.showUrl({
                      title: "Bulk Export",
                      url: modalURL,
                      width: "800px",
                      height: "600px",
                    });
                  },
                },
              ];
            },
          },
          // Header menu extension point
          headerMenu: {
            getButtons() {
              return [
                {
                  id: "my-header-btn",
                  label: "Dashboard",
                  icon: "Dashboard",
                },
              ];
            },
          },
        },
      });
    };
    init().catch(console.error);
  }, []);

  return <></>;
}
```

### Extracting Host Context

Inside modal or panel components, establish a guest connection to receive host context:

```jsx
import { attach } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function MyModal() {
  const [guestConnection, setGuestConnection] = useState(null);

  useEffect(() => {
    const init = async () => {
      const connection = await attach({ id: extensionId });
      setGuestConnection(connection);
    };
    init().catch(console.error);
  }, []);

  // Use connection to get host context:
  // CFE: guestConnection.host.contentFragment  → fragment data
  // UE:  guestConnection.host.editorContext     → page/component data
  // CF Console: guestConnection.sharedContext   → selected fragments

  return (/* your UI */);
}
```

### Backend Action Pattern

Backend actions run on Adobe I/O Runtime (serverless Node.js). They handle privileged operations:

```javascript
// src/dx-excshell-1/actions/my-action/index.js
const { Core, State, Logger } = require("@adobe/aio-sdk");
const fetch = require("node-fetch");

async function main(params) {
  const logger = Core.Logger("my-action", { level: params.LOG_LEVEL || "info" });
  logger.info("Action invoked");

  try {
    // Validate input
    if (!params.fragmentPath) {
      return { statusCode: 400, body: { error: "Missing fragmentPath" } };
    }

    // Use IMS token from params (passed by the runtime)
    const token = params.__ow_headers?.authorization?.replace("Bearer ", "");

    // Call AEM APIs or external services
    const response = await fetch(`${params.aemHost}/api/assets/${params.fragmentPath}`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    const result = await response.json();

    return {
      statusCode: 200,
      body: result,
    };
  } catch (error) {
    logger.error("Action failed", error);
    return { statusCode: 500, body: { error: error.message } };
  }
}

exports.main = main;
```

### Invoking Actions from the UI

```jsx
import actionWebInvoke from "../utils";  // Generated utility by AIO CLI

const result = await actionWebInvoke(
  "my-action",                           // Action name
  { "Content-Type": "application/json" }, // Headers
  { fragmentPath: "/content/dam/my-fragment" } // Params
);
```

---

## Critical Rule: One Extension Per Repository

Each GitHub repository MUST contain exactly **one** AEM UI extension. The agent must verify the project contains a single extension before implementing. If the project already has a different extension, stop and advise creating a separate repository. See `analyze-and-plan` for the full rationale.

---

## Agent Behavior Instructions

When executing this skill, the agent MUST:

1. **Verify this is a single-extension project** — one extension per repo, no exceptions.
2. **Follow the approved plan** from `analyze-and-plan` (no scope creep).
3. **Use `aio app dev`** for local development and testing throughout implementation.
4. **Keep UI and backend concerns separate**:
   - UI extension (React SPA in `web-src/`): host context handling, UX, accessibility using Adobe React Spectrum components.
   - App Builder actions (`actions/`): secure calls to AEM/external APIs, secrets, validation.
5. **Implement the `ExtensionRegistration.jsx` correctly** for the target host — this is the most critical file. Use the patterns above as reference.
6. **Use `@adobe/uix-guest`** for all host communication:
   - `register()` in the registration component
   - `attach()` in modal/panel components to access host context
7. **Use Adobe React Spectrum** (`@adobe/react-spectrum`) for all UI components to ensure visual consistency with the AEM host.
8. **Secure by default**:
   - Never hardcode secrets; use App Builder environment variables and `.env`.
   - Never place privileged operations (API calls with service tokens) in the client.
   - All API calls with elevated permissions go through backend actions.
9. **Add structured logging** to actions using `@adobe/aio-lib-core-logging`.
10. **Provide complete local testing instructions** using `aio app dev`.

The agent SHOULD:

- Prefer small, composable React components.
- Include robust error handling and user-friendly loading/error states.
- Call out dependencies on AEM APIs, CORS, allowlists, or permissions.
- Use the `actionWebInvoke` utility (generated by the AIO CLI scaffold) for action calls.

The agent MUST NOT:

- Introduce new extension points beyond the plan.
- Store sensitive data in client-side state or localStorage.
- Use third-party UI component libraries — only Adobe React Spectrum.
- Assume production readiness (that is handled by `validate-and-harden` and `distribute-extension`).

---

## Required Inputs

- Approved technical plan from `analyze-and-plan`
- Scaffolded project from `scaffold-extension`
- Target AEM environment details (URLs, org/program identifiers)
- API credentials/scopes available to the project

---

## Output Contract

The output MUST include:

1. **Files created/modified** with purpose annotations
2. **ExtensionRegistration.jsx** implementation for the target host
3. **Backend action implementations** (or clear patch-style guidance)
4. **UI component implementations** with host SDK integration points, context usage, loading/error states
5. **Configuration updates** to `ext.config.yaml` (actions, web-src)
6. **Local testing instructions** using `aio app dev`
7. **Host integration testing steps** (how to verify in the actual CFE/UE/Console)
8. **Known issues / follow-ups**

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| UIX Guest SDK Reference | https://developer.adobe.com/uix/docs/services/aem-cf-editor/api/ |
| CFE Extension API | https://developer.adobe.com/uix/docs/services/aem-cf-editor/api/header-menu/ |
| UE Extension API | https://developer.adobe.com/uix/docs/services/aem-universal-editor/api/header-menu/ |
| CF Console Extension API | https://developer.adobe.com/uix/docs/services/aem-cf-console-admin/api/action-bar/ |
| Adobe React Spectrum | https://react-spectrum.adobe.com/react-spectrum/ |
| App Builder Actions Guide | https://developer.adobe.com/app-builder/docs/guides/app-hooks/ |
| Official UIX Examples | https://github.com/adobe/aem-uix-examples |
| App Builder SDK Reference | https://developer.adobe.com/app-builder/docs/guides/ |

---

## Example Usage Prompts

### Content Fragment Editor (CFE)

```
Use build-extension to implement the planned Content Fragment Editor
header menu + modal extension. The modal should show the current
fragment field value, call the backend action for rewrite suggestions,
and allow writing the selected suggestion back to the fragment.
```

### Universal Editor (UE)

```
Use build-extension to implement the planned Universal Editor rail panel
extension. It should read the current authoring context from the host,
fetch validation results from a backend action, and render a checklist
with fix actions.
```

### Content Fragment Console

```
Use build-extension to implement the planned Content Fragment Console
action bar extension. When fragments are selected, the action bar button
opens a modal that shows bulk export options and invokes a backend action
to generate the export.
```
