# Block: `announcement-banner`

> **Status:** New — must be built
> **Loading phase:** EAGER (renders above hero, affects LCP perception)
> **Category:** Hero & Promotional
> **Legal:** None — but emergency weather alerts must never be dismissible

Dismissible top-of-page alert bar. Appears above the hero block. Used for rate change announcements, weather emergency alerts (flood/fire/drought), promotional offers, and system maintenance notices.

---

## Variants

| Variant class | Usage | Background |
|---|---|---|
| *(no variant)* | Promotional offer (yellow) | `var(--cba-yellow)` |
| `alert` | Emergency alert (floods, fires) | `#c0392b` (red) |
| `info` | System notice, maintenance | `#1a5276` (dark blue) |

---

## Content Authoring

```
| Announcement Banner [alert] |
|------------------------------|
| 🚨 If you've been impacted by flooding, [financial support is available](/hardship). |
```

```
| Announcement Banner |
|---------------------|
| Up to 300,000 Qantas Points on eligible home loans. Offer ends 30 June. [Find out more](/home-loans/qantas-points) |
```

Single row, single cell. Optional inline link. Dismiss button is added by JS (not authored).

---

## Initial DOM (before JS)

```html
<div class="announcement-banner block [alert|info]"
     data-block-name="announcement-banner"
     data-block-status="initialized">
  <div>
    <div>
      <p>
        🚨 If you've been impacted by flooding,
        <a href="/hardship">financial support is available</a>.
      </p>
    </div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="announcement-banner block alert"
     data-block-name="announcement-banner"
     data-block-status="loaded"
     role="alert"
     aria-live="polite">
  <div class="announcement-banner-inner">
    <p>
      🚨 If you've been impacted by flooding,
      <a href="/hardship">financial support is available</a>.
    </p>
    <button
      class="announcement-banner-dismiss"
      aria-label="Dismiss announcement"
      type="button">
      <span aria-hidden="true">✕</span>
    </button>
  </div>
</div>
```

When dismissed (alert variant is NOT dismissible):
```html
<div class="announcement-banner block hidden" ...>
```

---

## JavaScript Decoration

```javascript
const STORAGE_KEY = 'cba-announcement-dismissed';

export default async function decorate(block) {
  const isAlert = block.classList.contains('alert');

  // Check if previously dismissed (not for alert variant)
  if (!isAlert) {
    const dismissed = sessionStorage.getItem(STORAGE_KEY);
    if (dismissed === block.textContent.trim().substring(0, 50)) {
      block.classList.add('hidden');
      return;
    }
  }

  // Wrap content
  const inner = document.createElement('div');
  inner.className = 'announcement-banner-inner';
  inner.append(...block.children);
  block.append(inner);

  // ARIA for accessibility
  block.setAttribute('role', 'alert');
  block.setAttribute('aria-live', isAlert ? 'assertive' : 'polite');

  // Dismiss button (not for emergency alerts)
  if (!isAlert) {
    const dismiss = document.createElement('button');
    dismiss.className = 'announcement-banner-dismiss';
    dismiss.setAttribute('aria-label', 'Dismiss announcement');
    dismiss.setAttribute('type', 'button');
    dismiss.innerHTML = '<span aria-hidden="true">✕</span>';

    dismiss.addEventListener('click', () => {
      block.classList.add('hidden');
      // Store fingerprint to avoid re-showing same message
      sessionStorage.setItem(STORAGE_KEY, block.textContent.trim().substring(0, 50));
    });

    inner.append(dismiss);
  }
}
```

---

## CSS Structure

```css
main .announcement-banner {
  background-color: var(--cba-yellow);
  padding-block: 12px;
  padding-inline: var(--inline-section-padding);
}

main .announcement-banner-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  max-width: var(--max-content-width);
  margin-inline: auto;
  position: relative;
}

main .announcement-banner p {
  margin: 0;
  font-size: var(--body-font-size-s);
  color: var(--cba-black);
  text-align: center;
}

main .announcement-banner a {
  color: var(--cba-black);
  font-weight: 600;
  text-decoration: underline;
}

main .announcement-banner-dismiss {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  font-size: 1rem;
  color: var(--cba-black);
  flex-shrink: 0;
  position: absolute;
  inset-inline-end: 0;
}

main .announcement-banner-dismiss:hover {
  opacity: 0.7;
}

/* Alert variant */
main .announcement-banner.alert {
  background-color: #c0392b;
}

main .announcement-banner.alert p,
main .announcement-banner.alert a {
  color: var(--clr-white);
}

/* Info variant */
main .announcement-banner.info {
  background-color: var(--cba-dark-blue);
}

main .announcement-banner.info p,
main .announcement-banner.info a {
  color: var(--clr-white);
}

/* Hidden state */
main .announcement-banner.hidden {
  display: none;
}
```

---

## Universal Editor Fields

```json
{
  "id": "announcement-banner",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Type",
      "options": [
        { "name": "Promotional", "value": "" },
        { "name": "Emergency Alert", "value": "alert" },
        { "name": "System Notice", "value": "info" }
      ]
    },
    { "component": "richtext", "name": "text", "label": "Banner message (supports inline links)" }
  ]
}
```

---

## Accessibility

- `role="alert"` + `aria-live="assertive"` for emergency (alert variant)
- `role="alert"` + `aria-live="polite"` for promotional
- Dismiss button must have `aria-label="Dismiss announcement"`
- Do NOT make emergency alerts dismissible — `alert` variant never gets dismiss button
- Text + background contrast must meet 4.5:1 (white on `#c0392b` passes; check yellow)

---

## CBA-Specific Notes

- **Auto-blocking candidate**: `buildAutoBlocks` in `scripts.js` can auto-inject this block at the top of `<main>` by checking a `/banner.json` spreadsheet for an active banner message, avoiding the need for authors to manually add it to every page
- Emergency alerts (flood/fire/bushfire) follow the Australian Government Emergency Alert format — always use `alert` variant, never auto-dismiss
- Banner dismissal is stored in `sessionStorage` (not `localStorage`) — users see it again on a new browser session
