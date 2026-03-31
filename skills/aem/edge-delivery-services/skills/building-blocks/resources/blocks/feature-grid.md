# Block: `feature-grid`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Product & Financial
> **Legal:** CANSTAR star ratings must not be modified in size/colour per licence terms

4-column grid of award badge / icon + H3 heading + description. Used for trust signals, USPs, and award recognition sections on product listing and detail pages. Typically appears just below the anchor-tile-nav or after the product card grid.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | 4-col grid — award badges and USPs |
| `highlight` | Dark blue background — product benefits highlight |

---

## Content Authoring

```
| Feature Grid |
|-------------|
| ![CANSTAR 5 Star](canstar-5star.png) | ## Winner of 5 Star CANSTAR Award 2026
|                                       | Recognised for outstanding value in home loans. |
| ![icon](fast.png)  | ## Conditional approval in minutes
|                    | Get a fast online decision. |
| ![icon](support.png) | ## Local Australian support
|                       | Talk to a specialist 7 days a week. |
| ![icon](app.png)  | ## Manage everything in app
|                    | Track your loan progress with CommBank App. |
```

Each row = one grid item. Cell 1 = icon/badge image. Cell 2 = H3 heading + description paragraph.

---

## Initial DOM (before JS)

```html
<div class="feature-grid block" data-block-name="feature-grid" data-block-status="initialized">
  <div>
    <div>
      <picture><img src="canstar-5star.png" alt="CANSTAR 5 Star award" width="80" height="80"></picture>
    </div>
    <div>
      <h3>Winner of 5 Star CANSTAR Award 2026</h3>
      <p>Recognised for outstanding value in home loans.</p>
    </div>
  </div>
  <div>
    <div><picture><img src="fast.png" alt="" width="64" height="64"></picture></div>
    <div>
      <h3>Conditional approval in minutes</h3>
      <p>Get a fast online decision.</p>
    </div>
  </div>
  <!-- 2 more rows ... -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="feature-grid block" data-block-name="feature-grid" data-block-status="loaded">
  <ul class="feature-grid-list">
    <li class="feature-grid-item">
      <div class="feature-grid-icon">
        <img src="canstar-5star.png" alt="CANSTAR 5 Star award 2026" width="80" height="80">
      </div>
      <div class="feature-grid-content">
        <h3 class="feature-grid-title">Winner of 5 Star CANSTAR Award 2026</h3>
        <p class="feature-grid-description">Recognised for outstanding value in home loans.</p>
      </div>
    </li>
    <li class="feature-grid-item">
      <div class="feature-grid-icon">
        <img src="fast.png" alt="" width="64" height="64">
      </div>
      <div class="feature-grid-content">
        <h3 class="feature-grid-title">Conditional approval in minutes</h3>
        <p class="feature-grid-description">Get a fast online decision.</p>
      </div>
    </li>
    <!-- 2 more items -->
  </ul>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];

  const ul = document.createElement('ul');
  ul.className = 'feature-grid-list';

  rows.forEach((row) => {
    const [iconCell, contentCell] = [...row.querySelectorAll(':scope > div')];
    const li = document.createElement('li');
    li.className = 'feature-grid-item';

    // Icon / badge
    const iconDiv = document.createElement('div');
    iconDiv.className = 'feature-grid-icon';
    const img = iconCell?.querySelector('img');
    if (img) {
      // Award badges keep their alt text; decorative icons get alt=""
      if (!img.alt || img.alt.toLowerCase().includes('icon')) img.alt = '';
      iconDiv.append(img);
    }
    li.append(iconDiv);

    // Content
    const contentDiv = document.createElement('div');
    contentDiv.className = 'feature-grid-content';

    const heading = contentCell.querySelector('h2, h3, h4');
    if (heading) {
      heading.className = 'feature-grid-title';
      // Normalise to H3 (these are sub-headings, not page-level)
      if (heading.tagName !== 'H3') {
        const h3 = document.createElement('h3');
        h3.className = 'feature-grid-title';
        h3.innerHTML = heading.innerHTML;
        heading.replaceWith(h3);
        contentDiv.append(h3);
      } else {
        contentDiv.append(heading);
      }
    }

    const desc = contentCell.querySelector('p');
    if (desc) {
      desc.className = 'feature-grid-description';
      contentDiv.append(desc);
    }

    li.append(contentDiv);
    ul.append(li);
  });

  block.replaceChildren(ul);
}
```

---

## CSS Structure

```css
main .feature-grid {
  padding-inline: var(--inline-section-padding);
  padding-block: 48px;
}

main .feature-grid-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px 24px;
  list-style: none;
  margin: 0 auto;
  padding: 0;
  max-width: var(--max-content-width);
}

@media (width >= 900px) {
  main .feature-grid-list {
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }
}

main .feature-grid-item {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 16px;
}

main .feature-grid-icon img {
  width: 64px;
  height: 64px;
  object-fit: contain;
}

/* Award badges are typically larger */
main .feature-grid-icon img[src*="canstar"],
main .feature-grid-icon img[src*="award"] {
  width: 80px;
  height: 80px;
}

main .feature-grid-title {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  margin: 0;
  color: var(--cba-black);
}

main .feature-grid-description {
  font-size: var(--body-font-size-s);
  color: #555;
  margin: 0;
  line-height: 1.5;
}

/* highlight variant — dark background */
main .feature-grid.highlight {
  background-color: var(--cba-dark-blue);
}

main .feature-grid.highlight .feature-grid-title {
  color: var(--clr-white);
}

main .feature-grid.highlight .feature-grid-description {
  color: rgb(255 255 255 / 80%);
}
```

---

## Universal Editor Fields

```json
{
  "id": "feature-grid",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Background",
      "options": [
        { "name": "Light (default)", "value": "" },
        { "name": "Dark blue highlight", "value": "highlight" }
      ]
    }
  ]
}
```

---

## Accessibility

- Use `<ul>` / `<li>` for the grid — screen readers announce count
- CANSTAR award badges must have descriptive `alt` text: e.g., `alt="CANSTAR 5 Star award 2026 for Outstanding Value — Home Loans"`
- Generic icons (speed, support, app): `alt=""` (decorative — heading provides meaning)
- H3 elements inside feature-grid are sub-headings under the page's H2 section title — heading hierarchy must be maintained

---

## CBA-Specific Notes

- CANSTAR badge images are provided by CANSTAR under licence — do not alter colours, aspect ratio, or add CSS filters
- Typical 4-item layouts:
  - Home Loans: CANSTAR badge, fast approval, local support, app management
  - Credit Cards: CANSTAR badge, no foreign fees, rewards earning, app control
  - Savings: CANSTAR badge, no monthly fees, instant access, interest calculation
- When fewer than 4 items are authored, the grid adjusts to fill the available items (auto-fit grid)
