# Block: `contact-form`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Legal & Support
> **Legal:** Privacy collection statement required on all forms (OAIC compliance)

Dropdown "What's your enquiry?" selector that dynamically reveals relevant contact details (phone number, hours, email, chat link). This is NOT a traditional form submission — it's a JS-driven routing/disclosure widget. Used on Contact Us and Help & Support pages.

---

## Content Authoring

```
| Contact Form |
|-------------|
| Home Loans    | Call 13 22 21 | Available 8am–8pm Mon–Fri, 8am–5pm Sat–Sun | [Chat online](/chat) |
| Credit Cards  | Call 13 22 21 | Available 24/7 | [Message us](/secure-messages) |
| Business      | Call 13 19 98 | Available 8am–8pm Mon–Fri | [Book a call](/book) |
| General       | Call 13 22 21 | Available 24/7 | [Find a branch](/branch-locator) |
```

Row = one enquiry category. Cells = category name, phone, hours, secondary CTA.

---

## Initial DOM (before JS)

```html
<div class="contact-form block" data-block-name="contact-form" data-block-status="initialized">
  <div>
    <div><p>Home Loans</p></div>
    <div><p>Call 13 22 21</p></div>
    <div><p>Available 8am–8pm Mon–Fri, 8am–5pm Sat–Sun</p></div>
    <div><p><a href="/chat">Chat online</a></p></div>
  </div>
  <!-- 3 more rows -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="contact-form block" data-block-name="contact-form" data-block-status="loaded">
  <div class="contact-form-selector">
    <label for="contact-enquiry" class="contact-form-label">
      What's your enquiry about?
    </label>
    <select id="contact-enquiry" class="contact-form-select">
      <option value="">Select an option...</option>
      <option value="home-loans">Home Loans</option>
      <option value="credit-cards">Credit Cards</option>
      <option value="business">Business</option>
      <option value="general">General</option>
    </select>
  </div>

  <!-- Hidden panels — one per category, shown on select change -->
  <div class="contact-form-results" aria-live="polite">
    <div class="contact-form-panel" data-category="home-loans" hidden>
      <div class="contact-form-phone">
        <p class="contact-form-phone-number">Call <a href="tel:132221">13 22 21</a></p>
        <p class="contact-form-hours">Available 8am–8pm Mon–Fri, 8am–5pm Sat–Sun AEST</p>
      </div>
      <div class="contact-form-secondary">
        <a href="/chat" class="button secondary">Chat online</a>
      </div>
    </div>
    <!-- more panels -->
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];

  // Build select + panels
  const selectorDiv = document.createElement('div');
  selectorDiv.className = 'contact-form-selector';

  const label = document.createElement('label');
  label.htmlFor = 'contact-enquiry';
  label.className = 'contact-form-label';
  label.textContent = "What's your enquiry about?";

  const select = document.createElement('select');
  select.id = 'contact-enquiry';
  select.className = 'contact-form-select';

  const defaultOption = document.createElement('option');
  defaultOption.value = '';
  defaultOption.textContent = 'Select an option...';
  select.append(defaultOption);

  const resultsDiv = document.createElement('div');
  resultsDiv.className = 'contact-form-results';
  resultsDiv.setAttribute('aria-live', 'polite');

  rows.forEach((row) => {
    const cells = [...row.querySelectorAll(':scope > div')];
    const [catCell, phoneCell, hoursCell, ctaCell] = cells;

    const categoryName = catCell.textContent.trim();
    const categorySlug = categoryName.toLowerCase().replace(/\s+/g, '-');

    // Add to select
    const option = document.createElement('option');
    option.value = categorySlug;
    option.textContent = categoryName;
    select.append(option);

    // Build panel
    const panel = document.createElement('div');
    panel.className = 'contact-form-panel';
    panel.dataset.category = categorySlug;
    panel.hidden = true;

    const phoneDiv = document.createElement('div');
    phoneDiv.className = 'contact-form-phone';

    // Convert "Call 13 22 21" to a tel: link
    const phoneText = phoneCell.textContent.trim();
    const phoneNumber = phoneText.replace(/[^0-9\s]/g, '').trim();
    const phoneP = document.createElement('p');
    phoneP.className = 'contact-form-phone-number';
    phoneP.innerHTML = `${phoneText.includes('Call') ? 'Call ' : ''}<a href="tel:${phoneNumber.replace(/\s/g, '')}">${phoneNumber}</a>`;
    phoneDiv.append(phoneP);

    if (hoursCell) {
      const hoursP = document.createElement('p');
      hoursP.className = 'contact-form-hours';
      hoursP.textContent = hoursCell.textContent.trim();
      phoneDiv.append(hoursP);
    }

    panel.append(phoneDiv);

    const ctaLink = ctaCell?.querySelector('a');
    if (ctaLink) {
      const ctaDiv = document.createElement('div');
      ctaDiv.className = 'contact-form-secondary';
      ctaLink.className = 'button secondary';
      ctaDiv.append(ctaLink);
      panel.append(ctaDiv);
    }

    resultsDiv.append(panel);
  });

  selectorDiv.append(label, select);

  // Show/hide panels on change
  select.addEventListener('change', () => {
    [...resultsDiv.querySelectorAll('.contact-form-panel')].forEach((panel) => {
      panel.hidden = panel.dataset.category !== select.value;
    });
  });

  block.replaceChildren(selectorDiv, resultsDiv);
}
```

---

## CSS Structure

```css
main .contact-form {
  max-width: 600px;
  margin-inline: auto;
  padding-inline: var(--inline-section-padding);
  padding-block: 48px;
}

main .contact-form-label {
  display: block;
  font-weight: 700;
  font-size: var(--body-font-size-m);
  margin-bottom: 12px;
}

main .contact-form-select {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: var(--body-font-size-m);
  font-family: var(--cba-font-sans);
  background: var(--clr-white);
  cursor: pointer;
  appearance: auto;
}

main .contact-form-results {
  margin-top: 32px;
}

main .contact-form-panel {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

main .contact-form-panel[hidden] {
  display: none;
}

main .contact-form-phone-number {
  font-size: var(--heading-font-size-s);
  font-weight: 700;
  margin: 0 0 8px;
}

main .contact-form-phone-number a {
  color: var(--cba-black);
  text-decoration: none;
}

main .contact-form-hours {
  font-size: var(--body-font-size-s);
  color: #666;
  margin: 0;
}
```

---

## Universal Editor Fields

```json
{
  "id": "contact-form",
  "fields": []
}
```

---

## Accessibility

- `<label for="contact-enquiry">` properly linked to `<select>` — no `aria-label` needed
- `aria-live="polite"` on results container — screen reader announces when panel changes
- Phone links use `tel:` protocol — mobile users can tap to call
- Panel visibility: `hidden` attribute (not CSS `display:none`) — screen readers respect it

---

## CBA-Specific Notes

- **Privacy collection statement**: if this block is enhanced to include a text input (future), a privacy disclosure must appear beneath: "Your personal information is collected in accordance with CBA's Privacy Policy"
- Australian phone numbers: `13 22 21` format in display, `tel:132221` in href (no spaces)
- "Chat online" CTA opens in the same tab — do not add `target="_blank"` to internal CBA chat
