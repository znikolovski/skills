# Block: `anchor-tile-nav`

> **Status:** New — must be built
> **Loading phase:** LAZY (below hero, above fold on desktop)
> **Category:** Layout & Navigation
> **Legal:** None

Horizontal scrollable row of icon + label tiles. CBA's primary in-page navigation pattern on category and product listing pages. Links to `#hash` section anchors or sub-page URLs. Typically 6–10 tiles per row.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Standard — icon above label |
| `compact` | Smaller tiles, icon left of label (used on narrow pages) |

---

## Content Authoring

```
| Anchor Tile Nav |
|-----------------|
| ![home-loan icon](/icons/cba-home-loan.svg) | [Rates](#rates) |
| ![fixed icon](/icons/cba-fixed-rate.svg)    | [Fixed Rate](#fixed) |
| ![variable icon](/icons/cba-variable.svg)   | [Variable Rate](#variable) |
| ![refinance icon](/icons/cba-refinance.svg) | [Refinancing](#refinancing) |
| ![invest icon](/icons/cba-invest.svg)       | [Investment](#investment) |
| ![construction icon](/icons/cba-construction.svg) | [Construction](#construction) |
```

Each row = one tile. Cell 1 = icon `<img>` or SVG. Cell 2 = link (becomes the tile label + anchor target).

---

## Initial DOM (before JS)

```html
<div class="anchor-tile-nav block" data-block-name="anchor-tile-nav" data-block-status="initialized">
  <!-- Each row is one tile -->
  <div>
    <div>
      <picture>
        <img src="/icons/cba-home-loan.svg" alt="home-loan icon" width="48" height="48">
      </picture>
    </div>
    <div>
      <p><a href="#rates">Rates</a></p>
    </div>
  </div>
  <div>
    <div>
      <picture>
        <img src="/icons/cba-fixed-rate.svg" alt="fixed icon" width="48" height="48">
      </picture>
    </div>
    <div>
      <p><a href="#fixed">Fixed Rate</a></p>
    </div>
  </div>
  <!-- ... more rows ... -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="anchor-tile-nav block" data-block-name="anchor-tile-nav" data-block-status="loaded">
  <nav aria-label="Section navigation">
    <ul class="anchor-tile-nav-list">
      <li class="anchor-tile-nav-item">
        <a href="#rates" class="anchor-tile-nav-link">
          <span class="anchor-tile-nav-icon" aria-hidden="true">
            <img src="/icons/cba-home-loan.svg" alt="" width="48" height="48">
          </span>
          <span class="anchor-tile-nav-label">Rates</span>
        </a>
      </li>
      <li class="anchor-tile-nav-item">
        <a href="#fixed" class="anchor-tile-nav-link">
          <span class="anchor-tile-nav-icon" aria-hidden="true">
            <img src="/icons/cba-fixed-rate.svg" alt="" width="48" height="48">
          </span>
          <span class="anchor-tile-nav-label">Fixed Rate</span>
        </a>
      </li>
      <!-- ... more items ... -->
    </ul>
  </nav>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];

  const nav = document.createElement('nav');
  nav.setAttribute('aria-label', 'Section navigation');

  const ul = document.createElement('ul');
  ul.className = 'anchor-tile-nav-list';

  rows.forEach((row) => {
    const [iconCell, linkCell] = [...row.querySelectorAll(':scope > div')];
    const link = linkCell?.querySelector('a');
    const img = iconCell?.querySelector('img');

    if (!link) return;

    const li = document.createElement('li');
    li.className = 'anchor-tile-nav-item';

    const a = document.createElement('a');
    a.href = link.href;
    a.className = 'anchor-tile-nav-link';

    // Icon span (aria-hidden — label text provides accessible name)
    if (img) {
      const iconSpan = document.createElement('span');
      iconSpan.className = 'anchor-tile-nav-icon';
      iconSpan.setAttribute('aria-hidden', 'true');
      img.alt = ''; // Decorative — label provides meaning
      iconSpan.append(img);
      a.append(iconSpan);
    }

    // Label span
    const labelSpan = document.createElement('span');
    labelSpan.className = 'anchor-tile-nav-label';
    labelSpan.textContent = link.textContent.trim();
    a.append(labelSpan);

    li.append(a);
    ul.append(li);
  });

  nav.append(ul);
  block.replaceChildren(nav);

  // Highlight active tile based on scroll position
  if (block.querySelector('a[href^="#"]')) {
    highlightActiveSection(block);
  }
}

function highlightActiveSection(block) {
  const links = [...block.querySelectorAll('a[href^="#"]')];

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const id = entry.target.id;
      const link = block.querySelector(`a[href="#${id}"]`);
      if (link) {
        link.closest('li').classList.toggle('active', entry.isIntersecting);
      }
    });
  }, { threshold: 0.3 });

  links.forEach((link) => {
    const target = document.getElementById(link.hash.slice(1));
    if (target) observer.observe(target);
  });
}
```

---

## CSS Structure

```css
main .anchor-tile-nav {
  background-color: var(--clr-white);
  border-bottom: 1px solid #e0e0e0;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none; /* Firefox */
}

main .anchor-tile-nav::-webkit-scrollbar {
  display: none;
}

main .anchor-tile-nav nav {
  max-width: var(--max-content-width);
  margin-inline: auto;
  padding-inline: var(--inline-section-padding);
}

main .anchor-tile-nav-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 8px;
  /* Don't wrap — horizontal scroll on mobile */
  flex-wrap: nowrap;
  min-width: max-content;
}

main .anchor-tile-nav-item {
  flex-shrink: 0;
}

main .anchor-tile-nav-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 12px;
  text-decoration: none;
  color: var(--cba-black);
  font-size: var(--body-font-size-xs);
  font-weight: 500;
  border-bottom: 3px solid transparent;
  transition: border-color 0.2s;
  white-space: nowrap;
}

main .anchor-tile-nav-link:hover {
  border-bottom-color: var(--cba-yellow);
  color: var(--cba-black);
}

main .anchor-tile-nav-item.active .anchor-tile-nav-link {
  border-bottom-color: var(--cba-yellow);
  font-weight: 700;
}

main .anchor-tile-nav-icon img {
  width: 40px;
  height: 40px;
  object-fit: contain;
}

/* compact variant */
main .anchor-tile-nav.compact .anchor-tile-nav-link {
  flex-direction: row;
  gap: 8px;
  padding: 12px;
}

main .anchor-tile-nav.compact .anchor-tile-nav-icon img {
  width: 24px;
  height: 24px;
}

@media (width >= 900px) {
  main .anchor-tile-nav-list {
    flex-wrap: wrap;
    min-width: unset;
    justify-content: center;
  }
}
```

---

## Universal Editor Fields

```json
{
  "id": "anchor-tile-nav",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Layout",
      "options": [
        { "name": "Standard (icon above label)", "value": "" },
        { "name": "Compact (icon beside label)", "value": "compact" }
      ]
    }
  ]
}
```

Note: Individual tiles are authored as rows in the content table — UE will show them as repeatable items. Each item has icon + link fields.

---

## Accessibility

- Wrap entire block in `<nav aria-label="Section navigation">` — this is a landmark region
- Icon images are decorative (`alt=""`) — the label text provides the accessible name
- Active tile: add `aria-current="true"` to the active link (not just a CSS class)
- Horizontal scroll container: keyboard-navigable via Tab key across tiles

---

## CBA-Specific Notes

- Icon SVGs are stored in `icons/cba-[name].svg` in the repository root
- Typical tile count per page type:
  - Home Loans: 8 tiles (Rates, Fixed, Variable, Refinancing, Investment, Construction, Low Deposit, First Home Buyer)
  - Credit Cards: 5 tiles (All cards, Low rate, Rewards, No annual fee, Business)
  - Savings: 4 tiles (All accounts, High interest, Term deposits, Kids savings)
- The active tile highlight changes as the user scrolls through page sections — driven by `IntersectionObserver`
