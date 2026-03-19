# Block: `modal-apply`

> **Status:** New — must be built
> **Loading phase:** DELAYED (triggered by user interaction only)
> **Category:** Product & Financial
> **Legal:** None — but external `mobile-app-redirect.commbank.com.au` URLs must never be modified

Two-path decision modal for product applications. Every "Apply now" CTA on CBA product pages triggers this modal. Presents two options: existing CommBank customer (applies via NetBank/app) and new customer (gets started with app download).

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Standard two-path apply modal |

There is only one variant. Product-specific deep links are configured per instance via content authoring.

---

## Content Authoring

```
| Modal Apply |
|------------|
| Already a customer banking online with us? | [Apply online](https://mobile-app-redirect.commbank.com.au/digihomeloans) |
| New to CommBank or don't bank online?      | [Get started](/digital-banking/apply-in-app.html) |
```

Row 1: existing customer path — CTA links to `mobile-app-redirect.commbank.com.au`
Row 2: new customer path — CTA links to internal `/digital-banking/apply-in-app.html`

---

## How It's Triggered

The `modal-apply` block is NOT placed at the call-to-action location. It lives at the end of the page (one per page). "Apply now" buttons elsewhere on the page trigger it via a hash link:

```html
<a href="#modal-apply" class="button primary">Apply now</a>
```

The JS watches for clicks on `a[href="#modal-apply"]` and opens the modal.

---

## Initial DOM (before JS)

```html
<div class="modal-apply block" data-block-name="modal-apply" data-block-status="initialized">
  <!-- Row 1: Existing customer path -->
  <div>
    <div><p>Already a customer banking online with us?</p></div>
    <div><p><a href="https://mobile-app-redirect.commbank.com.au/digihomeloans">Apply online</a></p></div>
  </div>
  <!-- Row 2: New customer path -->
  <div>
    <div><p>New to CommBank or don't bank online?</p></div>
    <div><p><a href="/digital-banking/apply-in-app.html">Get started</a></p></div>
  </div>
</div>
```

---

## Decorated DOM (after JS — modal hidden state)

The block itself is hidden initially. When "Apply now" is triggered, the modal overlay appears:

```html
<!-- Block is hidden in the page -->
<div class="modal-apply block hidden" data-block-name="modal-apply" data-block-status="loaded">
</div>

<!-- Modal overlay injected into <body> -->
<div class="modal-apply-overlay" role="dialog" aria-modal="true"
     aria-labelledby="modal-apply-title" hidden>
  <div class="modal-apply-backdrop"></div>
  <div class="modal-apply-dialog">
    <button class="modal-apply-close" aria-label="Close" type="button">
      <span aria-hidden="true">✕</span>
    </button>
    <h2 id="modal-apply-title" class="modal-apply-title">How would you like to apply?</h2>
    <div class="modal-apply-options">
      <div class="modal-apply-option">
        <p class="modal-apply-option-label">Already a customer banking online with us?</p>
        <a href="https://mobile-app-redirect.commbank.com.au/digihomeloans"
           class="button primary"
           data-analytics-event="cta-modalapply-existing">
          Apply online
        </a>
      </div>
      <div class="modal-apply-divider" aria-hidden="true">or</div>
      <div class="modal-apply-option">
        <p class="modal-apply-option-label">New to CommBank or don't bank online?</p>
        <a href="/digital-banking/apply-in-app.html"
           class="button secondary"
           data-analytics-event="cta-modalapply-new">
          Get started
        </a>
      </div>
    </div>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];
  const [existingRow, newRow] = rows;

  // Build the modal overlay (injected into body)
  const overlay = document.createElement('div');
  overlay.className = 'modal-apply-overlay';
  overlay.setAttribute('role', 'dialog');
  overlay.setAttribute('aria-modal', 'true');
  overlay.setAttribute('aria-labelledby', 'modal-apply-title');
  overlay.hidden = true;

  const backdrop = document.createElement('div');
  backdrop.className = 'modal-apply-backdrop';

  const dialog = document.createElement('div');
  dialog.className = 'modal-apply-dialog';

  const closeBtn = document.createElement('button');
  closeBtn.className = 'modal-apply-close';
  closeBtn.setAttribute('aria-label', 'Close');
  closeBtn.setAttribute('type', 'button');
  closeBtn.innerHTML = '<span aria-hidden="true">✕</span>';

  const title = document.createElement('h2');
  title.id = 'modal-apply-title';
  title.className = 'modal-apply-title';
  title.textContent = 'How would you like to apply?';

  const options = document.createElement('div');
  options.className = 'modal-apply-options';

  const divider = document.createElement('div');
  divider.className = 'modal-apply-divider';
  divider.setAttribute('aria-hidden', 'true');
  divider.textContent = 'or';

  [existingRow, newRow].forEach((row, i) => {
    const [labelCell, ctaCell] = [...row.querySelectorAll(':scope > div')];
    const option = document.createElement('div');
    option.className = 'modal-apply-option';

    const label = document.createElement('p');
    label.className = 'modal-apply-option-label';
    label.textContent = labelCell.textContent.trim();

    const link = ctaCell.querySelector('a');
    link.className = i === 0 ? 'button primary' : 'button secondary';
    link.dataset.analyticsEvent = i === 0 ? 'cta-modalapply-existing' : 'cta-modalapply-new';

    option.append(label, link);
    options.append(option);
    if (i === 0) options.append(divider);
  });

  dialog.append(closeBtn, title, options);
  overlay.append(backdrop, dialog);
  document.body.append(overlay);

  // Hide original block
  block.classList.add('hidden');

  // Open modal when any #modal-apply link is clicked
  document.addEventListener('click', (e) => {
    const trigger = e.target.closest('a[href="#modal-apply"]');
    if (trigger) {
      e.preventDefault();
      openModal(overlay, closeBtn, trigger);
    }
  });

  // Close on backdrop click
  backdrop.addEventListener('click', () => closeModal(overlay));

  // Close on button click
  closeBtn.addEventListener('click', () => closeModal(overlay));

  // Close on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !overlay.hidden) closeModal(overlay);
  });
}

function openModal(overlay, closeBtn, trigger) {
  overlay.hidden = false;
  document.body.style.overflow = 'hidden';
  // Trap focus — move to close button
  closeBtn.focus();
  // Store trigger for focus restoration on close
  overlay.dataset.trigger = '';
  overlay._trigger = trigger;
}

function closeModal(overlay) {
  overlay.hidden = true;
  document.body.style.overflow = '';
  // Restore focus to trigger element
  if (overlay._trigger) overlay._trigger.focus();
}
```

---

## CSS Structure

```css
/* Block itself is hidden */
main .modal-apply.hidden {
  display: none;
}

/* Overlay */
.modal-apply-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-apply-overlay[hidden] {
  display: none;
}

.modal-apply-backdrop {
  position: absolute;
  inset: 0;
  background: rgb(0 0 0 / 60%);
}

.modal-apply-dialog {
  position: relative;
  background: var(--clr-white);
  border-radius: 12px;
  padding: 40px;
  max-width: 480px;
  width: calc(100% - 32px);
  box-shadow: 0 20px 60px rgb(0 0 0 / 30%);
}

.modal-apply-close {
  position: absolute;
  top: 16px;
  inset-inline-end: 16px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.25rem;
  padding: 8px;
  color: var(--cba-black);
  border-radius: 50%;
}

.modal-apply-close:hover {
  background: var(--cba-grey);
}

.modal-apply-title {
  font-size: var(--heading-font-size-s);
  font-weight: 700;
  margin: 0 0 32px;
  padding-inline-end: 40px; /* Space for close button */
}

.modal-apply-options {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.modal-apply-option {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.modal-apply-option-label {
  font-size: var(--body-font-size-m);
  margin: 0;
  color: var(--cba-black);
}

.modal-apply-divider {
  text-align: center;
  color: #999;
  font-size: var(--body-font-size-s);
  position: relative;
}

.modal-apply-divider::before,
.modal-apply-divider::after {
  content: '';
  position: absolute;
  top: 50%;
  width: 44%;
  height: 1px;
  background: #e0e0e0;
}

.modal-apply-divider::before { inset-inline-start: 0; }
.modal-apply-divider::after  { inset-inline-end: 0; }

.modal-apply-option .button {
  width: 100%;
  text-align: center;
}
```

---

## Universal Editor Fields

```json
{
  "id": "modal-apply",
  "fields": [
    { "component": "text", "name": "existingLabel", "label": "Existing customer prompt text" },
    { "component": "aem-content", "name": "existingCta", "label": "Existing customer CTA (mobile-app-redirect URL)" },
    { "component": "text", "name": "existingCtaLabel", "label": "Existing customer CTA label" },
    { "component": "text", "name": "newLabel", "label": "New customer prompt text" },
    { "component": "aem-content", "name": "newCta", "label": "New customer CTA" },
    { "component": "text", "name": "newCtaLabel", "label": "New customer CTA label" }
  ]
}
```

---

## Accessibility

- `role="dialog"` + `aria-modal="true"` on the overlay
- `aria-labelledby` pointing to the modal title `<h2>`
- Focus trapped within modal when open — `Tab` must not exit the dialog
- `Escape` key closes the modal
- Focus returns to the triggering element on close
- Backdrop blocks scroll: `document.body.style.overflow = 'hidden'` when open
- Do not use `display:none` on overlay — use `hidden` attribute to ensure it's invisible to all assistive technologies

---

## CBA-Specific Notes

- `mobile-app-redirect.commbank.com.au` URLs are CBA's app deep-link redirector — **never modify these URLs**. The path after the domain is the product ID defined by the CommBank digital team
- One `modal-apply` block per page — place it once at the bottom of `<main>`, before the `footnotes` block
- All "Apply now" buttons on the page link to `#modal-apply` — they do not navigate away
- The "existing customer" path takes users to NetBank or the CommBank App; the "new customer" path goes to app download/sign up
- Analytics events: `cta-modalapply-existing` and `cta-modalapply-new` fire when each path is selected
