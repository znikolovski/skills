# Skill: scaffold-extension

## Metadata

- Name: scaffold-extension
- Version: 2.0.0
- Description: Generates a minimal, host-specific scaffold for an AEM UI Extension (Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub) using the AIO CLI and Adobe App Builder.
- Last Updated: 2026-03-31

---

## When to use

Use this skill to create the initial project structure for an AEM UI extension. This is typically the first implementation step after `analyze-and-plan`. The skill uses the **AIO CLI** to initialize the project and add the correct extension template for the target UI surface.

---

## AIO CLI Is Required

This skill MUST use the AIO CLI to scaffold the extension. Manual project creation is not allowed. The AIO CLI ensures the correct project structure, dependencies, configuration, and extension registration stubs are in place.

### Prerequisites

Before running the AIO CLI commands, ensure:

1. **AIO CLI is installed**: `npm install -g @adobe/aio-cli`
2. **User is logged in**: `aio login` (opens browser for IMS authentication)
3. **Correct org/project/workspace is selected**: `aio console org select` → `aio console project select` → `aio console workspace select`
4. **Verify context**: `aio where` (confirms org, project, workspace)

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

---

## Project Structure: How an App Builder UIX Project Is Organized

After scaffolding, the project follows this standard structure:

```
my-extension/
├── app.config.yaml              # Main App Builder configuration
├── package.json                 # Dependencies and scripts
├── .env                         # Local environment variables (never commit)
├── .aio                         # AIO CLI workspace context
├── src/
│   └── dx-excshell-1/           # Extension entry point
│       ├── ext.config.yaml      # Extension-specific configuration
│       ├── web-src/             # UI extension code (React SPA)
│       │   ├── src/
│       │   │   ├── components/
│       │   │   │   ├── App.jsx                    # Router / shell
│       │   │   │   ├── ExtensionRegistration.jsx  # Extension registration (CRITICAL)
│       │   │   │   └── YourModal.jsx              # Custom UI components
│       │   │   ├── Constants.js                   # Extension ID, etc.
│       │   │   └── index.jsx                      # Entry point
│       │   └── index.html
│       └── actions/             # Backend actions (Node.js on I/O Runtime)
│           └── my-action/
│               └── index.js
└── test/                        # Tests
```

### Key files explained

| File | Purpose |
|------|---------|
| `app.config.yaml` | Root config — declares which extension points are used, includes ext.config.yaml |
| `ext.config.yaml` | Extension-specific config — declares web-src location, actions, and runtime settings |
| `ExtensionRegistration.jsx` | **The most critical file** — calls `register()` from `@adobe/uix-guest` to declare what extension points this extension implements and what methods/UI it provides to the host |
| `.env` | Local secrets and environment variables (AIO CLI populates defaults) |
| `actions/` | Serverless functions deployed to Adobe I/O Runtime — handle privileged API calls |

---

## Critical Rule: One Extension Per Repository

Each GitHub repository MUST contain exactly **one** AEM UI extension. Never add a second extension to an existing project. If the business need spans multiple UI surfaces, create **separate repositories** — one per extension. See `analyze-and-plan` for the full rationale.

This means:
- Always use `aio app init` to create a **new** project in a dedicated repository.
- Never use `aio app add extension` to add a second extension to an existing project.
- Each repo has one `app.config.yaml` with one extension entry.

---

## Agent Behavior Instructions

The agent MUST:

1. **Confirm the target UI surface** before scaffolding:
   - Content Fragment Editor (CFE)
   - Universal Editor (UE)
   - Content Fragment Console (CF Console)
   - Experience Hub
2. **Enforce one extension per repository** — always create a new project with `aio app init`. Never add to an existing extension project.
3. **Use the AIO CLI to initialize the project**:
   ```bash
   # Initialize a new App Builder project with the extension template
   aio app init <project-name>
   # Interactive prompts will ask:
   #   → Select org
   #   → Select project
   #   → Select workspace
   #   → What templates do you want to search for? "All Extension Points"
   #   → Select the extension point template for your target surface
   ```
4. **Select the correct extension template** based on the target surface:

   | Target Surface | Template to Select |
   |---------------|-------------------|
   | Content Fragment Editor | `@adobe/aem-cf-editor-ui-ext-tpl` |
   | Content Fragment Console | `@adobe/aem-cf-console-admin-ui-ext-tpl` |
   | Universal Editor | `@adobe/aem-universal-editor-ui-ext-tpl` |
   | Experience Hub | Select the Experience Hub extension template |

5. **Verify the scaffold** after creation:
   ```bash
   # Check the project structure was created correctly
   ls -la src/dx-excshell-1/

   # Verify dependencies are installed
   npm install

   # Verify the project builds
   aio app build

   # Verify local dev server starts
   aio app dev
   ```
6. **Keep the scaffold minimal** — only what the selected extension point requires. Do not add extra extension points beyond what was requested.
7. **Ensure the `ExtensionRegistration.jsx` is correctly configured** for the target host's extension points.

The agent SHOULD:

- Provide a "first-run" checklist (see below) to verify the scaffold loads in the host.
- Explain the purpose of each generated file to the developer.
- Note which files will need modification during the `build-extension` phase.

The agent MUST NOT:

- Implement full business logic (that's `build-extension`).
- Add extra extension points beyond the requested ones.
- Add a second extension to an existing project — always one extension per repo.
- Manually create project files that the AIO CLI would generate — always use the CLI.

---

## First-Run Verification Checklist

After scaffolding, verify with these steps:

1. **Run locally**: `aio app dev` — starts the local dev server
2. **Open the host URL with extension loading parameter**:
   - The AIO CLI will output a URL like: `https://experience.adobe.com/?devMode=true&ext=https://localhost:9080`
   - Open this in the browser to verify the extension loads in the host
3. **Check browser console** for errors — look for:
   - CORS errors (may need allowlist configuration)
   - Extension registration failures
   - Missing IMS scope errors
4. **Verify extension visibility** in the host UI:
   - CFE: Open a content fragment → look for your header menu button
   - UE: Open a page in Universal Editor → look for your rail panel or header button
   - CF Console: Open the Content Fragment Console → look for your action bar button or header button
5. **Check AIO CLI output** for any warnings about missing configuration

---

## Required Inputs

- Target UI surface: Content Fragment Editor, Universal Editor, Content Fragment Console, or Experience Hub
- Chosen extension point(s) from the `analyze-and-plan` output

---

## Output Contract

The output MUST include:

1. **AIO CLI commands used** (exact commands with flags)
2. **Template selected** and why
3. **Generated folder/file structure** with purpose annotations
4. **Key files to modify** in the next phase (build-extension)
5. **First-run verification results** or steps to verify
6. **Any warnings or issues** encountered during scaffolding

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| AIO CLI — Bootstrapping a New App | https://developer.adobe.com/app-builder/docs/getting_started/first_app/#4-bootstrapping-new-app-using-the-cli |
| AIO CLI Reference | https://developer.adobe.com/app-builder/docs/getting_started/ |
| Creating an Extension | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| Local Development Environment | https://developer.adobe.com/uix/docs/guides/local-environment/ |
| CFE Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-editor |
| UE Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/universal-editor |
| CF Console Extension Examples | https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-console |
| App Builder Project Structure | https://developer.adobe.com/app-builder/docs/guides/app-hooks/ |

---

## Example Usage Prompts

### New CFE extension project

```
Use scaffold-extension to create a new App Builder project for a Content
Fragment Editor header menu button + modal extension. Use `aio app init`
to initialize and select the CFE extension template.
```

### New UE extension project

```
Use scaffold-extension to create a new App Builder project for a
Universal Editor rail panel extension. Use `aio app init` to initialize
and select the UE extension template.
```

### CF Console extension

```
Use scaffold-extension to create a new project for a Content Fragment
Console action bar extension. The extension will add a button that
appears when fragments are selected.
```
