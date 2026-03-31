# Skill: generate-sample-extension

## Metadata

- Name: generate-sample-extension
- Version: 2.0.0
- Description: Generates a working reference implementation for an AEM UI Extension (Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub) using the AIO CLI and App Builder, including complete UI + backend action code, configuration, and verification steps.
- Last Updated: 2026-03-31

---

## Why this skill exists

Teams learn fastest from a working example. This skill produces a "known-good" sample aligned to the chosen host and extension point, which can be used as a starting point or to validate environment/registration correctness.

---

## AIO CLI Is Required

This skill MUST use the AIO CLI to scaffold and run the sample extension. The AIO CLI generates the correct project structure, dependencies, and configuration.

```bash
# Step 1: Login and select workspace
aio login
aio console org select
aio console project select
aio console workspace select

# Step 2: Initialize with the correct extension template
aio app init my-sample-extension
# Select the template for your target surface (see template table below)

# Step 3: Install dependencies
cd my-sample-extension
npm install

# Step 4: Run locally
aio app dev

# Step 5: Verify in host
# Open the URL printed by `aio app dev` in your browser
```

### Extension templates

| Target Surface | Template | Extension ID |
|---------------|----------|-------------|
| Content Fragment Editor | `@adobe/aem-cf-editor-ui-ext-tpl` | `dx/excshell/1` (service: aem-cf-editor) |
| Content Fragment Console | `@adobe/aem-cf-console-admin-ui-ext-tpl` | `dx/excshell/1` (service: aem-cf-console-admin) |
| Universal Editor | `@adobe/aem-universal-editor-ui-ext-tpl` | `dx/excshell/1` (service: aem-universal-editor) |
| Experience Hub | Experience Hub extension template | `dx/excshell/1` (service: experience-hub) |

---

## Sample Extension Patterns

### Pattern A: UI-Only Extension (No Backend)

A minimal extension that registers with the host and renders UI. No backend actions. Good for learning the registration pattern and verifying environment setup.

**What it demonstrates:**
- Extension registration via `@adobe/uix-guest`
- Host context extraction
- Adobe React Spectrum UI components
- Modal or panel rendering

### Pattern B: UI + Backend Action Roundtrip (Recommended)

A complete extension that registers with the host, renders UI, calls a backend action, and displays the result. This is the recommended starting point for real extensions.

**What it demonstrates:**
- Everything in Pattern A, plus:
- Backend action with `require-adobe-auth: true`
- Action invocation from the UI
- IMS token handling in actions
- Structured logging with `@adobe/aio-lib-core-logging`
- Error handling and loading states

---

## Complete Sample: CFE Header Menu + Modal + Action

This sample adds a header menu button to the Content Fragment Editor. When clicked, it opens a modal that calls a backend action and displays the result.

### File structure (after `aio app init` with CFE template)

```
my-sample-extension/
├── app.config.yaml
├── package.json
├── .env
├── src/
│   └── dx-excshell-1/
│       ├── ext.config.yaml
│       ├── web-src/
│       │   └── src/
│       │       ├── components/
│       │       │   ├── App.jsx
│       │       │   ├── ExtensionRegistration.jsx
│       │       │   └── SampleModal.jsx
│       │       ├── Constants.js
│       │       └── utils.js
│       └── actions/
│           └── sample-action/
│               └── index.js
└── test/
```

### ExtensionRegistration.jsx (CFE sample)

```jsx
import React, { useEffect } from "react";
import { register } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function ExtensionRegistration() {
  useEffect(() => {
    const init = async () => {
      const guestConnection = await register({
        id: extensionId,
        methods: {
          headerMenu: {
            getButtons() {
              return [
                {
                  id: "sample-button",
                  label: "Sample Action",
                  icon: "OpenIn",
                  onClick: () => {
                    guestConnection.host.modal.showUrl({
                      title: "Sample Extension",
                      url: "/index.html#/sample-modal",
                      width: "640px",
                      height: "400px",
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

  return <></>;
}

export default ExtensionRegistration;
```

### SampleModal.jsx

```jsx
import React, { useState, useEffect } from "react";
import { attach } from "@adobe/uix-guest";
import {
  Content,
  Heading,
  Button,
  ProgressCircle,
  Text,
} from "@adobe/react-spectrum";
import { extensionId } from "./Constants";
import actionWebInvoke from "../utils";

function SampleModal() {
  const [guestConnection, setGuestConnection] = useState(null);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const init = async () => {
      const connection = await attach({ id: extensionId });
      setGuestConnection(connection);
    };
    init().catch(console.error);
  }, []);

  const handleAction = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await actionWebInvoke(
        "sample-action",
        {},
        { message: "Hello from the extension!" }
      );
      setResult(response);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Content margin="size-200">
      <Heading level={2}>Sample Extension</Heading>
      <Text>This is a sample AEM UI Extension.</Text>
      <Button variant="cta" onPress={handleAction} isDisabled={loading}>
        {loading ? <ProgressCircle size="S" isIndeterminate /> : "Call Action"}
      </Button>
      {result && <Text>Result: {JSON.stringify(result)}</Text>}
      {error && <Text UNSAFE_style={{ color: "red" }}>Error: {error}</Text>}
    </Content>
  );
}

export default SampleModal;
```

### Backend Action (actions/sample-action/index.js)

```javascript
const { Core } = require("@adobe/aio-sdk");

async function main(params) {
  const logger = Core.Logger("sample-action", {
    level: params.LOG_LEVEL || "info",
  });
  logger.info("Sample action invoked");

  try {
    // Validate input
    const message = params.message || "No message provided";

    // In a real extension, you would:
    // 1. Validate the IMS token from params.__ow_headers.authorization
    // 2. Call AEM APIs or external services
    // 3. Return the result

    return {
      statusCode: 200,
      body: {
        message: `Echo: ${message}`,
        timestamp: new Date().toISOString(),
      },
    };
  } catch (error) {
    logger.error("Sample action failed", error);
    return {
      statusCode: 500,
      body: { error: error.message },
    };
  }
}

exports.main = main;
```

### ext.config.yaml

```yaml
operations:
  view:
    - type: web
      impl: index.html
web: web-src
runtimeManifest:
  packages:
    my-sample-extension:
      license: Apache-2.0
      actions:
        sample-action:
          function: actions/sample-action/index.js
          web: "yes"
          runtime: nodejs:18
          inputs:
            LOG_LEVEL: debug
          annotations:
            require-adobe-auth: true
            final: true
```

### Constants.js

```javascript
export const extensionId = "my-sample-extension";
```

---

## Complete Sample: UE Rail Panel + Action

For a Universal Editor sample, replace the `ExtensionRegistration.jsx` with:

```jsx
import React, { useEffect } from "react";
import { register } from "@adobe/uix-guest";
import { extensionId } from "./Constants";

function ExtensionRegistration() {
  useEffect(() => {
    const init = async () => {
      const guestConnection = await register({
        id: extensionId,
        methods: {
          panel: {
            getPanels() {
              return [
                {
                  id: "sample-panel",
                  label: "Sample Panel",
                  icon: "Info",
                  url: "/index.html#/sample-panel",
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

export default ExtensionRegistration;
```

And create a `SamplePanel.jsx` that uses `attach()` to get the editor context:

```jsx
import React, { useState, useEffect } from "react";
import { attach } from "@adobe/uix-guest";
import { Content, Heading, Text } from "@adobe/react-spectrum";
import { extensionId } from "./Constants";

function SamplePanel() {
  const [guestConnection, setGuestConnection] = useState(null);
  const [editorState, setEditorState] = useState(null);

  useEffect(() => {
    const init = async () => {
      const connection = await attach({ id: extensionId });
      setGuestConnection(connection);

      // Access Universal Editor context
      const state = await connection.host.editorState.get();
      setEditorState(state);
    };
    init().catch(console.error);
  }, []);

  return (
    <Content margin="size-200">
      <Heading level={3}>Sample Panel</Heading>
      {editorState ? (
        <Text>Editing: {editorState.location}</Text>
      ) : (
        <Text>Loading editor context...</Text>
      )}
    </Content>
  );
}

export default SamplePanel;
```

---

## Critical Rule: One Extension Per Repository

Each sample extension MUST be created as its own standalone project in a dedicated repository. Never add a sample extension to an existing extension project. See `analyze-and-plan` for the full rationale.

---

## Agent Behavior Instructions

The agent MUST:

1. **Create a dedicated project** for the sample — one extension per repo, always use `aio app init`.
2. **Use the AIO CLI** to initialize the project with `aio app init` and the correct extension template.
3. **Confirm the target host** (CFE, UE, CF Console, or Experience Hub) and **sample type** (UI-only or UI+action).
4. **Generate complete, runnable code** — the sample must work out of the box after `npm install && aio app dev`.
5. **Include the `ExtensionRegistration.jsx`** configured for the correct host extension points.
6. **Include configuration** (`ext.config.yaml`, `Constants.js`) that matches the code.
7. **Provide run + verify steps**: local dev run, host verification, basic smoke checks.

The agent SHOULD:

- Keep dependencies minimal (only `@adobe/uix-guest`, `@adobe/react-spectrum`, `@adobe/aio-sdk`).
- Include basic error handling and loading states.
- Include comments explaining key patterns (registration, context extraction, action invocation).

The agent MUST NOT:

- Embed real credentials or secrets.
- Implement business-specific logic beyond the sample.
- Use any third-party UI libraries — only Adobe React Spectrum.

---

## Required Inputs

- Host: Content Fragment Editor, Universal Editor, CF Console, or Experience Hub
- Sample type: UI-only (Pattern A) or UI+action roundtrip (Pattern B, recommended)
- Target environment for verification (dev workspace recommended)

---

## Output Contract

The output MUST include:

1. **AIO CLI commands** to create and run the sample
2. **Sample overview** (what it demonstrates)
3. **Complete file list** with all code
4. **ExtensionRegistration.jsx** for the target host
5. **UI component code** (modal/panel)
6. **Action code** (if Pattern B)
7. **Configuration files** (`ext.config.yaml`, `Constants.js`)
8. **Run instructions** (`aio app dev`)
9. **Host verification steps** (how to see it in the actual editor)
10. **Smoke test checklist**

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| Official UIX Examples Repository | https://github.com/adobe/aem-uix-examples |
| CFE Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-editor |
| UE Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/universal-editor |
| CF Console Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-console |
| Creating Your First Extension | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| UIX Guest SDK | https://github.com/adobe/uix-sdk |
| Adobe React Spectrum | https://react-spectrum.adobe.com/react-spectrum/ |
| App Builder First App Guide | https://developer.adobe.com/app-builder/docs/getting_started/first_app/ |

---

## Example Usage Prompts

### CFE sample (UI + action)

```
Use generate-sample-extension to create a working Content Fragment Editor
sample extension: adds a header menu button that opens a modal, modal
calls a backend action that returns an echo response. Provide the
complete code, config, and steps to verify in our dev environment.
```

### UE sample (UI-only)

```
Use generate-sample-extension to create a UI-only Universal Editor rail
panel sample. The panel should display the current editor context
(page URL, selected component). No backend action needed.
```

### CF Console sample (UI + action)

```
Use generate-sample-extension to create a Content Fragment Console
action bar sample. When fragments are selected, show a modal that
calls a backend action to list the selected fragment paths.
```
