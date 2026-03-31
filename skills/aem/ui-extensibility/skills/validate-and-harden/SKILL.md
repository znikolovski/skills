# Skill: validate-and-harden

## Metadata

- Name: validate-and-harden
- Version: 2.0.0
- Description: Performs a production-readiness review of an AEM UI Extension built with App Builder, focusing on security, performance, observability, and operational resilience — with specific checks for the UIX iFrame architecture.
- Last Updated: 2026-03-31

---

## Why this skill exists

`build-extension` focuses on functionality. This skill ensures the extension is safe and reliable before release, reducing production incidents and rollout friction. It is a **review-only skill** — it critiques and recommends improvements but does not create new functionality or deploy changes.

---

## AIO CLI Exception

This skill is a **review and critique** skill. It does not create new functionality or deploy changes. Therefore, AIO CLI usage is not required, though the agent MAY reference AIO CLI commands for verification steps (e.g., `aio app logs` to check logging, `aio app build` to verify the build).

---

## Architecture Context: UIX-Specific Security Model

Understanding the UIX architecture is critical for a meaningful security review:

```
┌─────────────────────────────────────────────────────────┐
│  Browser (User's session)                                │
│  ┌────────────────────────────────────────────────────┐  │
│  │  AEM Host Application                              │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │  Extension iFrame (SEPARATE ORIGIN)          │  │  │
│  │  │  ┌────────────────────────────────────────┐  │  │  │
│  │  │  │  React SPA                             │  │  │  │
│  │  │  │  - Has access to user's IMS token      │  │  │  │
│  │  │  │  - Runs in sandboxed iFrame            │  │  │  │
│  │  │  │  - Cannot access host DOM directly     │  │  │  │
│  │  │  │  - Communicates via postMessage only    │  │  │  │
│  │  │  └────────────────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────┘  │
│                          │                               │
│                     HTTPS calls                          │
│                          ▼                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │  App Builder Actions (I/O Runtime)                 │  │
│  │  - Receives IMS token via require-adobe-auth       │  │
│  │  - Has access to secrets via env vars              │  │
│  │  - Calls AEM APIs / external services              │  │
│  │  - MUST validate all inputs                        │  │
│  │  - MUST enforce authorization                      │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Security boundaries to review

1. **iFrame boundary**: Extension runs in a separate origin. It CANNOT access the host DOM, cookies, or localStorage. Communication is via `@adobe/uix-guest` postMessage protocol only.
2. **Client-server boundary**: The React SPA is untrusted code from a security perspective. All privileged operations MUST happen in backend actions.
3. **Action authentication**: Actions with `require-adobe-auth: true` receive the user's IMS token. Actions MUST validate this token and check permissions before performing operations.
4. **Secrets boundary**: Secrets stored in App Builder environment variables are available to actions at runtime but NEVER exposed to the client SPA.

---

## Agent Behavior Instructions

The agent MUST perform these review categories:

### 1. Security Review

- **Secrets handling**: No hardcoded secrets, API keys, or tokens in client code or committed files. Check `web-src/` for any hardcoded values. Verify `.env` is in `.gitignore`.
- **Token flow**: Verify `require-adobe-auth: true` is set on all actions that need authentication. Verify actions validate the IMS token before processing.
- **Least privilege**: Actions should only request/use the minimum IMS scopes needed. No wildcard permissions.
- **Server-side authorization**: Actions MUST check that the user has permission to perform the requested operation — do not trust the client.
- **Data exposure**: Verify actions do not return more data than the UI needs. No leaking of internal paths, credentials, or PII in error responses.
- **Input validation**: All action parameters must be validated server-side (type, range, format). Never trust client-provided data.
- **CORS**: If custom CORS headers are set, verify they are restricted to expected origins.

### 2. Performance Review

- **Cold start impact**: First invocation of I/O Runtime actions incurs cold start latency (1-3s). Evaluate if this is acceptable for the UX.
- **Action payload size**: I/O Runtime has a response payload limit (typically 1MB). Verify large responses are paginated or streamed.
- **Chatty API patterns**: Review whether the UI makes excessive action calls. Batch operations where possible.
- **Caching strategy**: Identify data that can be cached (in App Builder State or in-memory). Reduce redundant API calls.
- **UI responsiveness**: Loading states and progress indicators for all async operations. No blocking UI on action calls.
- **Bundle size**: Review `web-src` bundle size. Lazy-load heavy components that are not needed on initial render.

### 3. Observability Review

- **Structured logging**: Actions must use `@adobe/aio-lib-core-logging` with structured log entries (JSON). Include correlation IDs.
- **Error logging**: All caught exceptions must be logged with context. Stack traces for unexpected errors.
- **Telemetry events**: Key user flows (button click → action invoke → result displayed) should emit telemetry events.
- **Actionable alerts**: Define what log patterns or metrics should trigger alerts (e.g., sustained 5xx rate, action timeout rate).
- **Log access**: Verify logs are accessible via `aio app logs` for the deployed workspace.

### 4. Resilience Review

- **Timeouts**: All action HTTP calls must have explicit timeouts. Default fetch has no timeout.
- **Retries**: Transient failures (429, 503) should be retried with exponential backoff. Idempotent operations only.
- **Graceful degradation**: If a backend action fails, the UI should show a meaningful error, not a blank screen or cryptic message.
- **User-facing errors**: Error messages should be actionable ("Could not save. Please try again.") not technical ("500 Internal Server Error").
- **Extension isolation**: A failing extension must not break the host application. Verify the extension handles its own errors.

The agent MUST produce a **prioritized fix list**:
- **Must-fix before prod**: Security vulnerabilities, data exposure, missing auth checks
- **Should-fix**: Performance issues, missing logging, poor error messages
- **Could-fix**: Nice-to-have improvements, extra resilience, polish

The agent SHOULD:

- Provide concrete code-level guidance (patch-style) for key fixes.
- Include a smoke test checklist suitable for release gates.

The agent MUST NOT:

- Change the core product scope.
- Recommend storing secrets or privileged tokens in the client.
- Recommend bypassing `require-adobe-auth` for convenience.

---

## Required Inputs

- Built extension code (or a description of current implementation)
- Environments and SLO expectations (latency, uptime, usage volume)
- Logging/telemetry requirements (if any)

---

## Output Contract

The output MUST include:

1. **Security checklist + findings** (with severity: critical/high/medium/low)
2. **Performance checklist + findings**
3. **Observability checklist + findings**
4. **Resilience checklist + findings**
5. **Prioritized fix list** (must-fix / should-fix / could-fix)
6. **Release gate smoke test checklist**

---

## Knowledge Resources

| Resource | URL |
|----------|-----|
| App Builder Security Guide | https://developer.adobe.com/app-builder/docs/guides/security/ |
| I/O Runtime Limits | https://developer.adobe.com/runtime/docs/guides/using/system_settings/ |
| AIO Logging Library | https://github.com/adobe/aio-lib-core-logging |
| UIX Extension Security Model | https://developer.adobe.com/uix/docs/guides/creating-extension/ |
| App Builder Best Practices | https://developer.adobe.com/app-builder/docs/guides/ |

---

## Example Usage Prompts

### Full review

```
Use validate-and-harden on our Content Fragment Editor rewrite-suggestion
extension. Review the code in src/dx-excshell-1/ for security issues,
performance problems, missing logging, and resilience gaps. We expect
~500 users/day with a 2-second latency SLO for action responses.
```

### Security-focused review

```
Use validate-and-harden to perform a security-focused review of our
Universal Editor panel extension. Specifically check for token handling,
data exposure in action responses, and input validation in all actions.
```

### Pre-release gate

```
Use validate-and-harden to produce a release gate checklist for our
CF Console bulk export extension. We need to confirm it meets our
production readiness criteria before promoting to the production workspace.
```
