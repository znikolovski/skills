# Block: `footnotes`

> **Status:** New — must be built
> **Loading phase:** LAZY (bottom of page)
> **Category:** Legal & Support
> **⚠️ LEGAL REQUIREMENT — present on ALL CBA product pages without exception**

The "Things you should know" collapsed section at the bottom of every product page. Contains legally required disclosures, disclaimer text, and explanatory footnotes for all superscript markers (`[1]`, `[*]`, `[+]`, `[##]`, `[~]`) used in body content. Collapsible by default — expands on click.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Standard collapsible — starts collapsed |
| `expanded` | Starts expanded (for regulatory/high-risk pages) |

---

## Content Authoring

```
| Footnotes |
|-----------|
| [*] General advice warning: This information is general in nature and has been prepared without taking your objectives, financial situation or needs into account. |
| [1] The comparison rate is based on a secured loan of $150,000 over 25 years. WARNING: This comparison rate applies only to the example given. |
| [+] Terms, conditions, fees and charges apply. Applications for credit subject to approval. |
| [~] Offer available to new customers only. Offer may be withdrawn at any time. |
```

Each row is one footnote item. The marker character at the start (`[*]`, `[1]`, `[+]`) links back to the `<sup>` elements in body content.

---

## Initial DOM (before JS)

```html
<div class="footnotes block" data-block-name="footnotes" data-block-status="initialized">
  <div><div>
    <p>[*] General advice warning: This information is general in nature...</p>
  </div></div>
  <div><div>
    <p>[1] The comparison rate is based on a secured loan of $150,000 over 25 years...</p>
  </div></div>
  <div><div>
    <p>[+] Terms, conditions, fees and charges apply...</p>
  </div></div>
</div>
```

---

## Decorated DOM (after JS)

```html
<section class="footnotes block" data-block-name="footnotes" data-block-status="loaded"
         aria-label="Things you should know">
  <button
    class="footnotes-toggle"
    aria-expanded="false"
    aria-controls="footnotes-content"
    type="button">
    <span class="footnotes-toggle-label">Things you should know</span>
    <span class="footnotes-toggle-icon" aria-hidden="true">▼</span>
  </button>
  <div
    id="footnotes-content"
    class="footnotes-content"
    hidden>
    <ol class="footnotes-list">
      <li id="fn-comparison-rate" class="footnotes-item">
        <span class="footnotes-marker" aria-hidden="true">[*]</span>
        <span class="footnotes-text">General advice warning: This information is general in nature...</span>
      </li>
      <li id="fn-1" class="footnotes-item">
        <span class="footnotes-marker" aria-hidden="true">[1]</span>
        <span class="footnotes-text">The comparison rate is based on a secured loan...</span>
      </li>
      <li id="fn-plus" class="footnotes-item">
        <span class="footnotes-marker" aria-hidden="true">[+]</span>
        <span class="footnotes-text">Terms, conditions, fees and charges apply...</span>
      </li>
    </ol>
  </div>
</section>
```

---

## JavaScript Decoration

```javascript
// Maps marker characters to semantic IDs used in superscript <sup> elements
const MARKER_TO_ID = {
  '[*]': 'fn-comparison-rate',
  '[1]': 'fn-1',
  '[2]': 'fn-2',
  '[3]': 'fn-3',
  '[+]': 'fn-plus',
  '[~]': 'fn-tilde',
  '[##]': 'fn-hash',
};

export default async function decorate(block) {
  const isExpanded = block.classList.contains('expanded');
  const rows = [...block.querySelectorAll(':scope > div')];

  // Build accessible section wrapper
  const section = document.createElement('section');
  section.setAttribute('aria-label', 'Things you should know');
  section.className = block.className; // Preserve variant classes

  // Toggle button
  const toggle = document.createElement('button');
  toggle.className = 'footnotes-toggle';
  toggle.setAttribute('aria-expanded', isExpanded ? 'true' : 'false');
  toggle.setAttribute('aria-controls', 'footnotes-content');
  toggle.setAttribute('type', 'button');
  toggle.innerHTML = `
    <span class="footnotes-toggle-label">Things you should know</span>
    <span class="footnotes-toggle-icon" aria-hidden="true"></span>
  `;

  // Content panel
  const content = document.createElement('div');
  content.id = 'footnotes-content';
  content.className = 'footnotes-content';
  if (!isExpanded) content.hidden = true;

  // Footnote list
  const ol = document.createElement('ol');
  ol.className = 'footnotes-list';

  rows.forEach((row) => {
    const text = row.textContent.trim();
    const markerMatch = text.match(/^\[([^\]]+)\]/);
    const marker = markerMatch ? `[${markerMatch[1]}]` : null;
    const id = MARKER_TO_ID[marker] || null;

    const li = document.createElement('li');
    li.className = 'footnotes-item';
    if (id) li.id = id;

    if (marker) {
      const markerSpan = document.createElement('span');
      markerSpan.className = 'footnotes-marker';
      markerSpan.setAttribute('aria-hidden', 'true');
      markerSpan.textContent = marker;
      li.append(markerSpan);
    }

    const textSpan = document.createElement('span');
    textSpan.className = 'footnotes-text';
    textSpan.textContent = marker ? text.replace(marker, '').trim() : text;
    li.append(textSpan);

    ol.append(li);
  });

  content.append(ol);

  // Toggle behaviour
  toggle.addEventListener('click', () => {
    const expanded = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', String(!expanded));
    content.hidden = expanded;
  });

  section.append(toggle, content);

  // Replace the original block element
  block.replaceWith(section);
}
```

---

## CSS Structure

```css
main .footnotes {
  border-top: 2px solid var(--cba-yellow);
  padding-inline: var(--inline-section-padding);
  padding-block: 0;
  margin-top: 48px;
}

main .footnotes-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding-block: 20px;
  background: none;
  border: none;
  cursor: pointer;
  text-align: start;
  font-family: var(--cba-font-sans);
}

main .footnotes-toggle-label {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  color: var(--cba-black);
}

main .footnotes-toggle-icon {
  transition: transform 0.25s;
  color: var(--cba-black);
}

main .footnotes-toggle[aria-expanded="true"] .footnotes-toggle-icon {
  transform: rotate(180deg);
}

main .footnotes-content {
  padding-bottom: 32px;
}

main .footnotes-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

main .footnotes-item {
  display: flex;
  gap: 8px;
  padding-block: 8px;
  font-size: var(--body-font-size-xs);
  color: #555;
  line-height: 1.5;
  border-bottom: 1px solid #f0f0f0;
}

main .footnotes-item:last-child {
  border-bottom: none;
}

main .footnotes-marker {
  flex-shrink: 0;
  font-weight: 700;
  min-width: 32px;
  color: var(--cba-black);
}

/* expanded variant */
main .footnotes.expanded .footnotes-toggle {
  cursor: default;
  pointer-events: none;
}

main .footnotes.expanded .footnotes-toggle-icon {
  display: none;
}
```

---

## Universal Editor Fields

```json
{
  "id": "footnotes",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Display",
      "options": [
        { "name": "Collapsible (default)", "value": "" },
        { "name": "Expanded (always visible)", "value": "expanded" }
      ]
    }
  ]
}
```

Note: Footnote items are authored as rows in the content table. Each row is one footnote.

---

## Accessibility

- `<section aria-label="Things you should know">` creates a navigable landmark
- Toggle button: `aria-expanded` / `aria-controls` properly linked to content panel
- Content panel uses `hidden` attribute (not `display:none`) — screen readers respect it
- Each `<li>` has an `id` matching the `href` of the corresponding `<sup><a>` in body content (e.g., `id="fn-comparison-rate"` matches `<sup><a href="#fn-comparison-rate">*</a></sup>`)
- Footnote markers are `aria-hidden="true"` — the `id` linkage provides the semantic connection

---

## CBA-Specific Notes

- **This block is legally required on every product page** — if you import a product page and don't see a footnotes block, add one and flag for legal review
- Standard CBA footnote markers and their IDs:
  - `[*]` → `fn-comparison-rate` (comparison rate disclaimer)
  - `[1]`, `[2]`, `[3]` → `fn-1`, `fn-2`, `fn-3` (numbered general disclosures)
  - `[+]` → `fn-plus` (T&Cs apply)
  - `[~]` → `fn-tilde` (offer-specific conditions)
- The "General Advice Warning" must always be the first footnote item on investment/insurance product pages (ASIC requirement)
- Never render footnotes inside a `<table>` element — this is a common legacy AEM pattern that must be replaced with the list-based structure above
