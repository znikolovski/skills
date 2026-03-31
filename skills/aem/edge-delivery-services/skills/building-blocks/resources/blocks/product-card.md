# Block: `product-card`

> **Status:** New — must be built (distinct from generic `cards` block)
> **Loading phase:** LAZY
> **Category:** Product & Financial
> **Legal:** Rate values must never be hardcoded — always fetch from rates JSON feed

The most common block across commbank.com.au. Displays product information in card format. Used in 3-column grids (standard) and standalone (extended with rate data). The extended variant is used for credit cards, savings accounts, and term deposits where structured fee/rate data is shown.

---

## Variants

| Variant class | Usage | Differences |
|---|---|---|
| *(no variant)* | Standard — icon + name + bullets + CTA | Simple feature list |
| `extended` | Credit cards, savings — image + structured rate/fee rows | `<dl>` rate/fee pairs |

---

## Content Authoring

**Standard (3-col home loan / insurance grid):**
```
| Product Card |
|-------------|
| ![product icon](/icons/cba-home-loan.svg) | ## Variable Rate Home Loan
|                                             | - Redraw facility available
|                                             | - No monthly fees
|                                             | - Split loan option
|                                             | [Tell me more](/home-loans/variable) |
```

**Extended (credit card — rates + fees from JS):**
```
| Product Card (Extended) |
|------------------------|
| ![card art](smart-awards-card.png) | ## Smart Awards Credit Card |
| Purchase Rate   | rate:purchase-rate    |
| Monthly Fee     | rate:monthly-fee      |
| Interest Free   | Up to 55 days         |
| Min Credit      | $500                  |
| [Apply now](#modal-apply) | [Learn more](/credit-cards/smart-awards) |
```

In the extended variant, cells with `rate:` prefix are populated from the rates JSON feed at runtime.

---

## Initial DOM (before JS) — Standard

```html
<div class="product-card block" data-block-name="product-card" data-block-status="initialized">
  <div>
    <div>
      <picture>
        <img src="/icons/cba-home-loan.svg" alt="" width="64" height="64">
      </picture>
    </div>
    <div>
      <h2>Variable Rate Home Loan</h2>
      <ul>
        <li>Redraw facility available</li>
        <li>No monthly fees</li>
        <li>Split loan option</li>
      </ul>
      <p><a href="/home-loans/variable">Tell me more</a></p>
    </div>
  </div>
</div>
```

## Initial DOM (before JS) — Extended

```html
<div class="product-card extended block" data-block-name="product-card" data-block-status="initialized">
  <!-- Row 0: image | heading -->
  <div>
    <div><picture><img src="smart-awards-card.png" alt="Smart Awards Credit Card"></picture></div>
    <div><h2>Smart Awards Credit Card</h2></div>
  </div>
  <!-- Rows 1–4: label | value (rate:* prefix = JS-populated) -->
  <div><div><p>Purchase Rate</p></div><div><p>rate:purchase-rate</p></div></div>
  <div><div><p>Monthly Fee</p></div><div><p>rate:monthly-fee</p></div></div>
  <div><div><p>Interest Free</p></div><div><p>Up to 55 days</p></div></div>
  <div><div><p>Min Credit</p></div><div><p>$500</p></div></div>
  <!-- Last row: CTA buttons -->
  <div>
    <div><p><a href="#modal-apply">Apply now</a></p></div>
    <div><p><a href="/credit-cards/smart-awards">Learn more</a></p></div>
  </div>
</div>
```

---

## Decorated DOM (after JS) — Standard

```html
<div class="product-card block" data-block-name="product-card" data-block-status="loaded">
  <article class="product-card-item">
    <div class="product-card-icon">
      <img src="/icons/cba-home-loan.svg" alt="" width="64" height="64">
    </div>
    <div class="product-card-body">
      <h2 class="product-card-title">Variable Rate Home Loan</h2>
      <ul class="product-card-features">
        <li>Redraw facility available</li>
        <li>No monthly fees</li>
        <li>Split loan option</li>
      </ul>
      <div class="product-card-actions">
        <a href="/home-loans/variable" class="button secondary">Tell me more</a>
      </div>
    </div>
  </article>
</div>
```

## Decorated DOM (after JS) — Extended

```html
<div class="product-card extended block" data-block-name="product-card" data-block-status="loaded">
  <article class="product-card-item">
    <div class="product-card-image">
      <img src="smart-awards-card.png" alt="Smart Awards Credit Card">
    </div>
    <div class="product-card-body">
      <h2 class="product-card-title">Smart Awards Credit Card</h2>
      <dl class="product-card-details">
        <div class="product-card-detail-row">
          <dt>Purchase Rate</dt>
          <dd data-rate-key="purchase-rate">20.99% p.a.</dd>
        </div>
        <div class="product-card-detail-row">
          <dt>Monthly Fee</dt>
          <dd data-rate-key="monthly-fee">$19 <span class="rate-note">(waived if $2,000+ spend)</span></dd>
        </div>
        <div class="product-card-detail-row">
          <dt>Interest Free</dt>
          <dd>Up to 55 days</dd>
        </div>
        <div class="product-card-detail-row">
          <dt>Min Credit</dt>
          <dd>$500</dd>
        </div>
      </dl>
      <div class="product-card-actions">
        <a href="#modal-apply" class="button primary" data-analytics-event="cta-productcard-apply">Apply now</a>
        <a href="/credit-cards/smart-awards" class="button secondary" data-analytics-event="cta-productcard-learn">Learn more</a>
      </div>
    </div>
  </article>
</div>
```

---

## JavaScript Decoration

```javascript
const RATES_ENDPOINT = '/content/cba/rates/products.json';
let ratesCache = null;

async function getRates() {
  if (ratesCache) return ratesCache;
  try {
    const resp = await fetch(RATES_ENDPOINT);
    const { data } = await resp.json();
    ratesCache = data;
    return data;
  } catch {
    return [];
  }
}

export default async function decorate(block) {
  const isExtended = block.classList.contains('extended');
  const rows = [...block.querySelectorAll(':scope > div')];

  if (isExtended) {
    await decorateExtended(block, rows);
  } else {
    decorateStandard(block, rows);
  }
}

function decorateStandard(block, rows) {
  const [row] = rows;
  const [iconCell, contentCell] = [...row.querySelectorAll(':scope > div')];

  const article = document.createElement('article');
  article.className = 'product-card-item';

  if (iconCell) {
    const iconDiv = document.createElement('div');
    iconDiv.className = 'product-card-icon';
    const img = iconCell.querySelector('img');
    if (img) { img.alt = ''; iconDiv.append(img); }
    article.append(iconDiv);
  }

  const body = document.createElement('div');
  body.className = 'product-card-body';

  const h2 = contentCell.querySelector('h2, h3');
  if (h2) { h2.className = 'product-card-title'; body.append(h2); }

  const ul = contentCell.querySelector('ul');
  if (ul) { ul.className = 'product-card-features'; body.append(ul); }

  const ctaLink = contentCell.querySelector('a');
  if (ctaLink) {
    const actions = document.createElement('div');
    actions.className = 'product-card-actions';
    ctaLink.className = 'button secondary';
    actions.append(ctaLink.closest('p') || ctaLink);
    body.append(actions);
  }

  article.append(body);
  block.replaceChildren(article);
}

async function decorateExtended(block, rows) {
  const rates = await getRates();
  const [headerRow, ...dataRows] = rows;
  const [imageCell, titleCell] = [...headerRow.querySelectorAll(':scope > div')];

  const article = document.createElement('article');
  article.className = 'product-card-item';

  // Image
  const imageDiv = document.createElement('div');
  imageDiv.className = 'product-card-image';
  imageDiv.append(...imageCell.children);
  article.append(imageDiv);

  const body = document.createElement('div');
  body.className = 'product-card-body';

  const h2 = titleCell.querySelector('h2, h3');
  if (h2) { h2.className = 'product-card-title'; body.append(h2); }

  // Determine if last row is CTAs
  const lastRow = dataRows[dataRows.length - 1];
  const isCtaRow = [...lastRow.querySelectorAll('a')].length > 0;
  const detailRows = isCtaRow ? dataRows.slice(0, -1) : dataRows;
  const ctaRow = isCtaRow ? lastRow : null;

  // Build definition list
  const dl = document.createElement('dl');
  dl.className = 'product-card-details';

  detailRows.forEach((row) => {
    const [labelCell, valueCell] = [...row.querySelectorAll(':scope > div')];
    const dt = document.createElement('dt');
    dt.textContent = labelCell.textContent.trim();

    const dd = document.createElement('dd');
    const valueText = valueCell.textContent.trim();

    if (valueText.startsWith('rate:')) {
      const rateKey = valueText.replace('rate:', '');
      const rateEntry = rates.find((r) => r.key === rateKey);
      dd.textContent = rateEntry?.value || '—';
      dd.dataset.rateKey = rateKey;
    } else {
      dd.textContent = valueText;
    }

    const divRow = document.createElement('div');
    divRow.className = 'product-card-detail-row';
    divRow.append(dt, dd);
    dl.append(divRow);
  });

  body.append(dl);

  // CTAs
  if (ctaRow) {
    const actions = document.createElement('div');
    actions.className = 'product-card-actions';
    const links = [...ctaRow.querySelectorAll('a')];
    links.forEach((link, i) => {
      link.className = i === 0 ? 'button primary' : 'button secondary';
      actions.append(link);
    });
    body.append(actions);
  }

  article.append(body);
  block.replaceChildren(article);
}
```

---

## CSS Structure

```css
/* ── Standard ─────────────────────────────────────── */
main .product-card .product-card-item {
  display: flex;
  flex-direction: column;
  background: var(--clr-white);
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
  height: 100%;
}

main .product-card .product-card-icon img {
  width: 64px;
  height: 64px;
  object-fit: contain;
  margin-bottom: 16px;
}

main .product-card .product-card-title {
  font-size: var(--heading-font-size-s);
  font-weight: 700;
  margin-block: 0 12px;
}

main .product-card .product-card-features {
  list-style: none;
  padding: 0;
  margin: 0 0 auto;
  font-size: var(--body-font-size-s);
}

main .product-card .product-card-features li {
  padding-block: 4px;
  padding-inline-start: 20px;
  position: relative;
}

main .product-card .product-card-features li::before {
  content: '✓';
  color: var(--cba-link);
  position: absolute;
  inset-inline-start: 0;
  font-weight: 700;
}

main .product-card .product-card-actions {
  margin-top: 20px;
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

/* ── Extended variant ─────────────────────────────── */
main .product-card.extended .product-card-image img {
  width: 100%;
  max-width: 280px;
  height: auto;
  border-radius: 8px;
}

main .product-card.extended .product-card-details {
  margin: 16px 0;
}

main .product-card.extended .product-card-detail-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding-block: 10px;
  border-bottom: 1px solid #f0f0f0;
  font-size: var(--body-font-size-s);
}

main .product-card.extended .product-card-detail-row dt {
  color: var(--cba-text);
  font-weight: 400;
}

main .product-card.extended .product-card-detail-row dd {
  font-weight: 700;
  margin: 0;
  text-align: right;
}

main .product-card.extended .rate-note {
  font-weight: 400;
  font-size: 0.85em;
  display: block;
  color: #666;
}
```

---

## Universal Editor Fields

```json
{
  "id": "product-card",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Card Type",
      "options": [
        { "name": "Standard (icon + features)", "value": "" },
        { "name": "Extended (image + rate data)", "value": "extended" }
      ]
    },
    { "component": "aem-content", "name": "image", "label": "Product image or icon" },
    { "component": "text", "name": "title", "label": "Product name" },
    { "component": "richtext", "name": "features", "label": "Feature bullets (standard only)" },
    { "component": "text", "name": "cta1Label", "label": "Primary CTA label" },
    { "component": "aem-content", "name": "cta1", "label": "Primary CTA link" },
    { "component": "text", "name": "cta2Label", "label": "Secondary CTA label", "required": false },
    { "component": "aem-content", "name": "cta2", "label": "Secondary CTA link", "required": false }
  ]
}
```

---

## Accessibility

- Use `<article>` for each card — it's a self-contained piece of content
- `<dl>` / `<dt>` / `<dd>` structure for rate/fee data (extended variant) — describes the relationship
- Product icon images are decorative — `alt=""`
- Product image (extended) must have descriptive alt text (card art description)
- "Apply now" button: add `aria-label="Apply now for [product name]"` to disambiguate multiple apply buttons on the same page

---

## CBA-Specific Notes

- Rates fetched from `/content/cba/rates/products.json` — never hardcoded
- `rate:` prefix in authored content is the convention for runtime-populated values
- "Apply now" links point to `#modal-apply` which triggers the `modal-apply` block
- Extended cards always appear with `rate-display` block above or below them on product listing pages
- CANSTAR award badges appear as part of the `feature-grid` block — not inside `product-card`
