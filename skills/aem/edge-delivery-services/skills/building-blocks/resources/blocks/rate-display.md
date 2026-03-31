# Block: `rate-display`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Product & Financial
> **Legal:** Always paired with `footnotes` block — comparison rate disclaimer is legally required

Displays interest rate + comparison rate pairs for CBA home loan, credit card, and savings products. Values are fetched from the rates JSON feed at runtime — never hardcoded. Supports single-product and multi-product comparison layouts.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Single product — hero rate display |
| `comparison` | Side-by-side 2–3 product comparison row |
| `inline` | Small rate badge inside another block (product card) |

---

## Content Authoring

**Single product:**
```
| Rate Display |
|-------------|
| product | digi-home-loan |
| label   | DigiHome Loan  |
```

**Comparison (multiple products side by side):**
```
| Rate Display (Comparison) |
|--------------------------|
| product | digi-home-loan | standard-variable | fixed-2yr |
| label   | DigiHome Loan  | Standard Variable | 2 Year Fixed |
```

Configuration-pattern block — no rate values authored directly. The `product` key maps to the rates JSON.

---

## Initial DOM (before JS)

```html
<div class="rate-display block" data-block-name="rate-display" data-block-status="initialized">
  <!-- Configuration rows -->
  <div><div><p>product</p></div><div><p>digi-home-loan</p></div></div>
  <div><div><p>label</p></div><div><p>DigiHome Loan</p></div></div>
</div>
```

---

## Decorated DOM (after JS — single product)

```html
<div class="rate-display block" data-block-name="rate-display" data-block-status="loaded">
  <div class="rate-display-card">
    <p class="rate-display-product-name">DigiHome Loan</p>
    <div class="rate-display-rates">
      <div class="rate-display-rate">
        <span class="rate-display-value">5.89<span class="rate-display-unit">% p.a.</span></span>
        <span class="rate-display-label">Interest rate</span>
      </div>
      <div class="rate-display-rate">
        <span class="rate-display-value">6.02<span class="rate-display-unit">% p.a.</span></span>
        <span class="rate-display-label">
          Comparison rate<sup><a href="#fn-comparison-rate">*</a></sup>
        </span>
      </div>
    </div>
    <p class="rate-display-footnote-ref">
      *Comparison rate is based on a $150,000 loan over 25 years.
    </p>
  </div>
</div>
```

## Decorated DOM (after JS — comparison variant)

```html
<div class="rate-display comparison block" data-block-name="rate-display" data-block-status="loaded">
  <div class="rate-display-comparison-grid">
    <div class="rate-display-card">
      <p class="rate-display-product-name">DigiHome Loan</p>
      <div class="rate-display-rates">
        <div class="rate-display-rate">
          <span class="rate-display-value">5.89<span class="rate-display-unit">% p.a.</span></span>
          <span class="rate-display-label">Interest rate</span>
        </div>
        <div class="rate-display-rate">
          <span class="rate-display-value">6.02<span class="rate-display-unit">% p.a.</span></span>
          <span class="rate-display-label">Comparison rate<sup><a href="#fn-comparison">*</a></sup></span>
        </div>
      </div>
    </div>
    <!-- More cards ... -->
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
const RATES_ENDPOINT = '/content/cba/rates/home-loans.json';

export default async function decorate(block) {
  // Parse configuration rows
  const config = {};
  const rows = [...block.querySelectorAll(':scope > div')];

  rows.forEach((row) => {
    const [keyCell, ...valueCells] = [...row.querySelectorAll(':scope > div')];
    const key = keyCell.textContent.trim().toLowerCase();
    // Support multiple values for comparison variant
    config[key] = valueCells.map((c) => c.textContent.trim());
  });

  const products = config.product || [];
  const labels = config.label || products;

  // Fetch rates
  let rates = [];
  try {
    const resp = await fetch(RATES_ENDPOINT);
    const { data } = await resp.json();
    rates = data;
  } catch {
    block.textContent = ''; // Silently hide if rates unavailable
    return;
  }

  const isComparison = block.classList.contains('comparison') || products.length > 1;

  const outerDiv = isComparison
    ? Object.assign(document.createElement('div'), { className: 'rate-display-comparison-grid' })
    : null;

  products.forEach((productKey, i) => {
    const rateData = rates.find((r) => r.product === productKey);
    if (!rateData) return;

    const card = buildRateCard(rateData, labels[i] || productKey);

    if (outerDiv) {
      outerDiv.append(card);
    } else {
      block.append(card);
    }
  });

  block.replaceChildren(outerDiv || block.firstElementChild);
}

function buildRateCard(rateData, label) {
  const card = document.createElement('div');
  card.className = 'rate-display-card';

  const name = document.createElement('p');
  name.className = 'rate-display-product-name';
  name.textContent = label;
  card.append(name);

  const ratesDiv = document.createElement('div');
  ratesDiv.className = 'rate-display-rates';

  const rateEntries = [
    { value: rateData['interest-rate'], label: 'Interest rate' },
    { value: rateData['comparison-rate'], label: 'Comparison rate', footnote: true },
  ];

  rateEntries.forEach(({ value, label: rateLabel, footnote }) => {
    if (!value) return;
    const rateDiv = document.createElement('div');
    rateDiv.className = 'rate-display-rate';

    // Split "5.89% p.a." into number + unit
    const match = value.match(/^([\d.]+)(%\s*p\.a\.?)(.*)$/i);
    const valueSpan = document.createElement('span');
    valueSpan.className = 'rate-display-value';

    if (match) {
      valueSpan.textContent = match[1];
      const unit = document.createElement('span');
      unit.className = 'rate-display-unit';
      unit.textContent = `${match[2]}${match[3]}`;
      valueSpan.append(unit);
    } else {
      valueSpan.textContent = value;
    }

    const labelSpan = document.createElement('span');
    labelSpan.className = 'rate-display-label';
    labelSpan.textContent = rateLabel;

    if (footnote) {
      const sup = document.createElement('sup');
      const footnoteLink = document.createElement('a');
      footnoteLink.href = '#fn-comparison-rate';
      footnoteLink.textContent = '*';
      footnoteLink.setAttribute('aria-label', 'Comparison rate footnote');
      sup.append(footnoteLink);
      labelSpan.append(sup);
    }

    rateDiv.append(valueSpan, labelSpan);
    ratesDiv.append(rateDiv);
  });

  card.append(ratesDiv);
  return card;
}
```

---

## CSS Structure

```css
main .rate-display .rate-display-card {
  background: var(--cba-grey);
  border-radius: 8px;
  padding: 24px;
  text-align: center;
}

main .rate-display .rate-display-product-name {
  font-weight: 700;
  font-size: var(--body-font-size-m);
  margin-bottom: 16px;
}

main .rate-display .rate-display-rates {
  display: flex;
  gap: 32px;
  justify-content: center;
  flex-wrap: wrap;
}

main .rate-display .rate-display-rate {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

main .rate-display .rate-display-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--cba-black);
  line-height: 1;
}

main .rate-display .rate-display-unit {
  font-size: 1rem;
  font-weight: 400;
}

main .rate-display .rate-display-label {
  font-size: var(--body-font-size-xs);
  color: #666;
  text-align: center;
}

main .rate-display .rate-display-label sup a {
  color: #666;
  font-size: 0.75em;
}

/* Comparison variant */
main .rate-display.comparison .rate-display-comparison-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  max-width: var(--max-content-width);
  margin-inline: auto;
}

/* Inline variant */
main .rate-display.inline .rate-display-card {
  padding: 12px 16px;
  background: none;
  border: 1px solid #e0e0e0;
}

main .rate-display.inline .rate-display-value {
  font-size: 1.5rem;
}
```

---

## Universal Editor Fields

```json
{
  "id": "rate-display",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Display style",
      "options": [
        { "name": "Single product", "value": "" },
        { "name": "Comparison (side by side)", "value": "comparison" },
        { "name": "Inline badge", "value": "inline" }
      ]
    },
    {
      "component": "text",
      "name": "products",
      "label": "Product key(s) from rates feed (comma-separated for comparison)"
    },
    {
      "component": "text",
      "name": "labels",
      "label": "Display label(s) (comma-separated, matches products order)"
    }
  ]
}
```

---

## Accessibility

- Rate values use `<span>` not `<p>` — screen readers read them inline with labels
- Footnote link: `aria-label="Comparison rate footnote"` on `<sup><a>` to clarify purpose
- Do not rely on colour alone to distinguish interest vs comparison rate — use labels
- Comparison grid: use `aria-label` on the grid if 3+ products to announce count

---

## CBA-Specific Notes

- **Rates JSON feed** at `/content/cba/rates/home-loans.json` provides: `product`, `interest-rate`, `comparison-rate`, `effective-date`
- **Comparison rate disclaimer** (legal): "*The comparison rate is based on a secured loan of $150,000 over 25 years." — this text must appear in the `footnotes` block, not in `rate-display`
- Rate values include unit: `"5.89% p.a."` — the JS splits the number from the unit for large-number display
- When rates fetch fails: hide the block silently — do not show `—` or error state to users (legal risk of showing stale rates)
- `effective-date` field in rates JSON should be displayed near the rate display as "Rates current as at [date]"
