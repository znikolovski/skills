# Skill: analyze-and-plan

## Metadata

- Name: analyze-and-plan
- Version: 2.0.0
- Description: Produces a complete technical architecture and execution plan for building an AEM UI Extension (Content Fragment Editor, Universal Editor, or Experience Hub) using Adobe App Builder.
- Last Updated: 2026-03-31

---

## When to use

Use this skill **before any implementation** to:

- Confirm which AEM UI surface is targeted (**Content Fragment Editor**, **Universal Editor**, or **Experience Hub**) and which extension points are in scope.
- Produce a build-ready plan that downstream skills (`scaffold-extension`, `build-extension`) can execute without re-discovering requirements.

---

## Architecture Overview: How AEM UI Extensions Work

AEM UI extensions are built on the **Adobe App Builder** platform and loaded into host applications via **iFrames**. The communication between the host and the extension uses a **postMessage-based protocol** provided by the UIX SDK.

### High-level architecture

```
┌──────────────────────────────────────────────────────────┐
│  Browser                                                  │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  AEM Host Application (CFE / UE / Experience Hub)    │ │
│  │                                                      │ │
│  │  ┌──────────────────────────────────────────┐        │ │
│  │  │  Extension iFrame                        │        │ │
│  │  │  (Your App Builder SPA)                  │        │ │
│  │  │                                          │        │ │
│  │  │  React UI  ←→  @adobe/uix-guest SDK      │        │ │
│  │  └────────────────────┬─────────────────────┘        │ │
│  │                       │ postMessage (UIX protocol)   │ │
│  │  Host App  ←→  @adobe/uix-host SDK                   │ │
│  └──────────────────────────────────────────────────────┘ │
│                          │                                │
│                          ▼                                │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  Adobe I/O Runtime (App Builder Actions)             │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐     │ │
│  │  │ Action A   │  │ Action B   │  │ Action C   │     │ │
│  │  │ (Node.js)  │  │ (Node.js)  │  │ (Node.js)  │     │ │
│  │  └─────┬──────┘  └─────┬──────┘  └────────────┘     │ │
│  │        │               │                             │ │
│  │        ▼               ▼                             │ │
│  │   AEM APIs        External APIs                      │ │
│  └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### Key SDK packages

| Package | Role | Used by |
|---------|------|---------|
| `@adobe/uix-guest` | Guest SDK — registers extension, receives host context, exposes methods | Extension (iFrame) |
| `@adobe/uix-host` | Host SDK — discovers extensions, renders iFrames, dispatches context | AEM Host (not user-managed) |
| `@adobe/exc-app` | Experience Cloud Shell integration, IMS auth helpers | Extension runtime |
| `@adobe/aio-sdk` | App Builder SDK for actions (state, files, events, logger) | Backend actions |

### Communication flow

1. Host application loads and discovers registered extensions via the Extension Registry.
2. Host renders the extension as an iFrame at the designated extension point.
3. Extension calls `register()` from `@adobe/uix-guest` to handshake with the host and declare its capabilities.
4. Host provides context (selection, entity IDs, locale, authoring state) to the extension via the guest connection.
5. Extension UI can invoke App Builder backend actions over HTTPS for privileged operations.
6. Backend actions authenticate via IMS service tokens and call AEM APIs or external services.

---

## Extension Point Reference

### Content Fragment Editor (CFE)

The Content Fragment Editor is the authoring UI for AEM Content Fragments. Extensions appear inside the editor while a fragment is being edited.

**Extension identifier in app.config.yaml:** `dx/excshell/1` with service `aem-cf-editor`

| Extension Point | Description | UX Location |
|----------------|-------------|-------------|
| `headerMenu` | Adds button(s) to the editor header toolbar | Top toolbar area |
| `richTextEditor` (RTE toolbar) | Adds custom buttons to the Rich Text Editor toolbar | Inside RTE fields |
| `richTextEditor` (RTE widgets) | Adds custom widgets rendered inside the RTE editing area | Inside RTE content area |
| `richTextEditor` (RTE badges) | Adds badges/annotations on RTE content | Inside RTE content area |

**Host context available to CFE extensions:**

- Fragment model path and ID
- Fragment path and ID
- Selected field(s) and current values
- Locale / language
- User IMS token (for delegation)
- AEM host URL

**Official documentation:**
- https://developer.adobe.com/uix/docs/services/aem-cf-editor/

**Official code examples:**
- https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-editor

### Universal Editor (UE)

The Universal Editor is the visual, in-context editing surface for AEM content. Extensions appear alongside the editing canvas.

**Extension identifier in app.config.yaml:** `dx/excshell/1` with service `aem-universal-editor`

| Extension Point | Description | UX Location |
|----------------|-------------|-------------|
| `headerMenu` | Adds button(s) to the UE header toolbar | Top toolbar area |
| `rail` (panels) | Adds custom panels to the right-side rail | Right rail panel list |
| `canvas.headerMenu` | Adds button(s) above the canvas area | Canvas header |

**Host context available to UE extensions:**

- Page URL being edited
- Selected component and its resource path
- Content tree structure
- Component model / definition
- Locale / language
- User IMS token (for delegation)
- AEM host URL and connection details
- Editor mode (edit, preview)
- Universal Editor connection metadata

**Official documentation:**
- https://developer.adobe.com/uix/docs/services/aem-universal-editor/

**Official code examples:**
- https://github.com/adobe/aem-uix-examples/tree/main/universal-editor

### Content Fragment Console / Admin

The Content Fragment Console is the admin/management UI for browsing and managing Content Fragments.

**Extension identifier in app.config.yaml:** `dx/excshell/1` with service `aem-cf-console-admin`

| Extension Point | Description | UX Location |
|----------------|-------------|-------------|
| `headerMenu` | Adds button(s) to the console header | Top toolbar |
| `actionBar` | Adds button(s) to the action bar when fragment(s) are selected | Action bar (contextual) |
| `grid columns` | Adds custom columns to the fragment list | List/grid view |
| `navigationPanel` | Adds items to the left navigation | Left nav panel |

**Host context available:**

- Selected fragment(s) path(s) and model(s)
- Current folder path
- User IMS token
- AEM host URL

**Official documentation:**
- https://developer.adobe.com/uix/docs/services/aem-cf-console-admin/

**Official code examples:**
- https://github.com/adobe/aem-uix-examples/tree/main/content-fragment-console

### Experience Hub (AEM Home)

Experience Hub is the landing page / home screen for AEM as a Cloud Service. Extensions can add custom cards and widgets to the hub.

**Extension identifier in app.config.yaml:** `dx/excshell/1` with service configuration for Experience Hub

**Official documentation:**
- https://developer.adobe.com/uix/docs/services/aem-experience-hub/

---

## Critical Rule: One Extension Per Repository

Each GitHub repository MUST contain exactly **one** AEM UI extension. This is a hard requirement to ensure:

- **Clear ownership**: One team, one repo, one extension.
- **Simple deployments**: `aio app deploy` deploys the entire repo — no risk of accidentally deploying unrelated changes to another extension.
- **Independent lifecycles**: Each extension can be versioned, promoted, and rolled back independently without affecting others.
- **Clean CI/CD**: Build and deploy pipelines map 1:1 to a single extension.

If the business need spans multiple UI surfaces (e.g., a CFE extension AND a UE extension), create **separate repositories** — one per extension. They can share backend logic via shared npm packages or shared I/O Runtime actions, but the App Builder project and deployment unit must be isolated per repo.

The agent MUST enforce this rule during planning. If a user requests multiple extensions in one repo, the agent must advise splitting them into separate repositories and explain the rationale above.

---

## Agent Behavior Instructions

When executing this skill, the agent MUST:

1. **Enforce one extension per repository** — if the requirement involves multiple UI surfaces, plan separate repos/projects for each.
2. **Identify the target UI surface** up front:
   - Content Fragment Editor (CFE), Universal Editor (UE), Content Fragment Console, Experience Hub.
3. **Pin down extension points** using the Extension Point Reference above and the host UI context they provide (selection, entity IDs, authoring context, events).
3. **Verify extension point feasibility**:
   - Cross-reference the requested behavior with the extension points listed above.
   - If any extension point is uncertain or not listed, include a verification checklist with links to official documentation.
4. **Map UI → backend responsibilities**:
   - What runs in the UI extension (React, inside the iFrame) vs what runs as App Builder actions (Node.js, on Adobe I/O Runtime).
   - Privileged operations (API calls with service tokens, secrets access) MUST run in backend actions, never in the client.
6. **Plan for AIO CLI usage**:
   - All downstream implementation will use the AIO CLI. The plan must reference which AIO CLI commands will be used at each stage (init, dev, build, deploy).
7. **Security-first design**:
   - Explicitly cover IMS scopes, secrets, token handling, and least-privilege access.
   - Map which IMS scopes are needed for each backend action.
   - Specify whether user token delegation or service-to-service tokens are used.
8. **Environment strategy**:
   - Dev/stage/prod configuration separation via App Builder workspaces.
   - Promotion steps and rollback notes.
9. **Deliver structured outputs** exactly per the Output Contract below.

The agent SHOULD:

- Call out performance risks (cold starts, chatty API calls, large payloads) and propose mitigations.
- Include telemetry/logging from day one using `@adobe/aio-lib-core-logging`.
- Propose a clear integration-test approach inside the host editor.
- Reference official Adobe documentation and examples for each extension point.
- Consult third-party code repositories for extension examples if no official Adobe reference exists.

The agent MUST NOT:

- Produce large code implementations (small illustrative snippets are OK) unless explicitly asked.
- Invent extension points that are not documented — if unsure, list verification steps and cite official docs.
- Use extension examples in third-party code repositories outside the Adobe ecosystem as a starting point.

---

## Required Inputs

- Extension target: **Content Fragment Editor**, **Universal Editor**, **Content Fragment Console**, **Experience Hub**, or a combination
- Extension point(s) to use (or business requirement from which the agent derives the extension point)
- Business objective and user stories
- Target environments (dev/stage/prod)
- Security constraints (IMS scopes, data residency, compliance)

---

## Output Contract

The output MUST include:

1. **Executive Summary**
2. **Host & Extension Point Matrix**
   - Host: CFE / UE / CF Console / Experience Hub
   - Extension point(s) and their identifiers
   - Context available from host (what data the extension receives)
   - UX affordances (where it shows up, user flow)
3. **Architecture Diagram Description** (using the architecture pattern from above, customized for this extension)
4. **Extension → Action Mapping Table**
   - For each UI interaction, what backend action it calls, what APIs the action invokes, what data flows back
5. **Security Design**
   - Auth model (user token delegation vs service tokens), IMS scopes, token flow, secrets, permission checks
6. **Storage + State Design**
   - App Builder state/files usage, caching strategy
7. **AIO CLI Workflow**
   - Which AIO CLI commands will be used at each project phase (scaffold, develop, configure, deploy)
8. **Deployment + Promotion Strategy**
   - Workspace-based environment separation, promotion steps
9. **Testing Strategy**
   - Unit, integration (host), e2e smoke checks
10. **Risk Assessment + Mitigations**
11. **Open Questions / Verification Checklist**
    - Anything that must be confirmed in official docs

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| UI Extensibility Overview | https://developer.adobe.com/uix/docs/ |
| Content Fragment Editor Extensions | https://developer.adobe.com/uix/docs/services/aem-cf-editor/ |
| Universal Editor Extensions | https://developer.adobe.com/uix/docs/services/aem-universal-editor/ |
| Content Fragment Console Extensions | https://developer.adobe.com/uix/docs/services/aem-cf-console-admin/ |
| Experience Hub Extensions | https://developer.adobe.com/uix/docs/services/aem-experience-hub/ |
| App Builder Overview | https://developer.adobe.com/app-builder/docs/overview/ |
| AIO CLI Reference | https://developer.adobe.com/app-builder/docs/getting_started/first_app/#4-bootstrapping-new-app-using-the-cli |
| Extension Registration Guide | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| Official UIX Examples Repository | https://github.com/adobe/aem-uix-examples |
| UIX SDK (Guest) | https://github.com/adobe/uix-sdk |

---

## Example Usage Prompts

### Content Fragment Editor (CFE)

```
Use analyze-and-plan to design an AEM Content Fragment Editor extension.
Add a header menu button that opens a modal to run an AI-based rewrite
suggestion on the selected field. The backend action must call an external
LLM API and write the approved suggestion back to the fragment via AEM
Content Fragment APIs. Environments: dev and stage.
```

### Universal Editor (UE)

```
Use analyze-and-plan to design a Universal Editor extension. The extension
should add a rail panel that lets authors validate page content against a
custom checklist and show actionable fixes. Backend actions should fetch
validation rules from an internal service and optionally create tasks via
a REST API. Environments: dev, stage, prod.
```

### Content Fragment Console

```
Use analyze-and-plan to design a Content Fragment Console extension. Add
an action bar button that, when one or more fragments are selected, opens
a modal showing a bulk translation status dashboard. A backend action
queries the translation management system API. Environments: dev and prod.
```

### Experience Hub

```
Use analyze-and-plan to design an Experience Hub extension that adds a
custom card to the AEM Home page showing recent publishing activity.
A backend action queries AEM's audit log API. Environments: dev, stage, prod.
```
