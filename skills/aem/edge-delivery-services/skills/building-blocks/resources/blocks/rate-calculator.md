# Block: `rate-calculator`

> **Status:** New — must be built (complex, Sprint 5)
> **Loading phase:** LAZY + IntersectionObserver (heavy JS deferred until visible)
> **Category:** Product & Financial
> **Legal:** Calculator results are indicative only — disclaimer required in `footnotes`

Interactive rate calculator with form inputs (loan amount slider), toggle button groups (Owner Occupied / Investment, P&I / IO, fixed rate terms), and dynamically updated rate results. Used on the interest rates page and home loan comparison pages.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Home loan calculator |
| `personal-loan` | Personal loan repayments calculator |
| `savings` | Savings growth calculator |

---

## Content Authoring

Configuration-pattern block. No rate values authored directly.

```
| Rate Calculator |
|----------------|
| loan-type | home |
| default-amount | 500000 |
| min-amount | 50000 |
| max-amount | 3000000 |
| default-term | 30 |
| repayment-types | principal-and-interest,interest-only |
| purpose-types | owner-occupied,investment |
| rates-source | /content/cba/rates/home-loans.json |
```

---

## Initial DOM (before JS)

```html
<div class="rate-calculator block" data-block-name="rate-calculator" data-block-status="initialized">
  <div><div><p>loan-type</p></div><div><p>home</p></div></div>
  <div><div><p>default-amount</p></div><div><p>500000</p></div></div>
  <div><div><p>min-amount</p></div><div><p>50000</p></div></div>
  <!-- ... config rows ... -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="rate-calculator block" data-block-name="rate-calculator" data-block-status="loaded">
  <form class="rate-calculator-form" novalidate>
    <!-- Loan amount slider -->
    <div class="rate-calculator-field">
      <label for="calc-amount" class="rate-calculator-label">Loan amount</label>
      <div class="rate-calculator-slider-group">
        <output class="rate-calculator-amount-display" id="calc-amount-display">$500,000</output>
        <input type="range" id="calc-amount" name="amount"
               min="50000" max="3000000" step="10000" value="500000"
               aria-describedby="calc-amount-display">
        <div class="rate-calculator-slider-bounds">
          <span>$50k</span>
          <span>$3m</span>
        </div>
      </div>
    </div>

    <!-- Purpose toggle -->
    <div class="rate-calculator-field">
      <span class="rate-calculator-label" id="purpose-label">Purpose</span>
      <div class="rate-calculator-toggle-group" role="radiogroup" aria-labelledby="purpose-label">
        <button type="button" class="rate-calculator-toggle active"
                data-value="owner-occupied" aria-pressed="true">Owner Occupied</button>
        <button type="button" class="rate-calculator-toggle"
                data-value="investment" aria-pressed="false">Investment</button>
      </div>
    </div>

    <!-- Repayment type toggle -->
    <div class="rate-calculator-field">
      <span class="rate-calculator-label" id="repayment-label">Repayment type</span>
      <div class="rate-calculator-toggle-group" role="radiogroup" aria-labelledby="repayment-label">
        <button type="button" class="rate-calculator-toggle active"
                data-value="principal-and-interest" aria-pressed="true">Principal & Interest</button>
        <button type="button" class="rate-calculator-toggle"
                data-value="interest-only" aria-pressed="false">Interest Only</button>
      </div>
    </div>
  </form>

  <!-- Results -->
  <div class="rate-calculator-results" aria-live="polite" aria-label="Calculated rates">
    <div class="rate-calculator-result-card">
      <p class="rate-calculator-product-name">DigiHome Loan</p>
      <div class="rate-calculator-rate-pair">
        <span class="rate-calculator-rate">5.89<span class="rate-calculator-unit">% p.a.</span></span>
        <span class="rate-calculator-rate-label">Interest rate</span>
      </div>
      <div class="rate-calculator-rate-pair">
        <span class="rate-calculator-rate">6.02<span class="rate-calculator-unit">% p.a.</span></span>
        <span class="rate-calculator-rate-label">Comparison rate<sup><a href="#fn-comparison-rate">*</a></sup></span>
      </div>
      <a href="#modal-apply" class="button primary">Get started</a>
    </div>
  </div>
</div>
```

---

## JavaScript Decoration (outline)

```javascript
export default async function decorate(block) {
  // Parse config
  const config = parseConfig(block);

  // Defer heavy initialisation until block is visible
  const observer = new IntersectionObserver(async (entries) => {
    if (!entries[0].isIntersecting) return;
    observer.disconnect();
    await initCalculator(block, config);
  }, { threshold: 0.1 });

  // Show loading skeleton while waiting
  block.innerHTML = '<div class="rate-calculator-skeleton" aria-label="Loading calculator"></div>';
  observer.observe(block);
}

function parseConfig(block) {
  const config = {};
  [...block.querySelectorAll(':scope > div')].forEach((row) => {
    const [k, v] = [...row.querySelectorAll(':scope > div')];
    config[k.textContent.trim()] = v.textContent.trim();
  });
  return config;
}

async function initCalculator(block, config) {
  // Fetch rates
  const { data: rates } = await fetch(config['rates-source']).then((r) => r.json());

  // Build state
  const state = {
    amount: parseInt(config['default-amount'], 10) || 500000,
    purpose: config['purpose-types']?.split(',')[0] || 'owner-occupied',
    repayment: config['repayment-types']?.split(',')[0] || 'principal-and-interest',
  };

  // Build UI
  const form = buildForm(config, state);
  const results = buildResults(rates, state);

  block.replaceChildren(form, results);

  // Reactivity: update results on any input change
  form.addEventListener('change', () => {
    updateState(form, state);
    updateResults(results, rates, state);
  });
}

// updateResults: filters rates by state.purpose + state.repayment,
// updates displayed rate values in .rate-calculator-result-card elements
```

---

## CSS Structure

```css
main .rate-calculator {
  padding-inline: var(--inline-section-padding);
  padding-block: 48px;
  background: var(--cba-grey);
}

main .rate-calculator-form {
  max-width: 600px;
  margin: 0 auto 40px;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

main .rate-calculator-label {
  font-weight: 700;
  font-size: var(--body-font-size-s);
  display: block;
  margin-bottom: 12px;
}

main .rate-calculator-toggle-group {
  display: flex;
  gap: 0;
  border: 1px solid #ccc;
  border-radius: 4px;
  overflow: hidden;
}

main .rate-calculator-toggle {
  flex: 1;
  padding: 10px 16px;
  background: var(--clr-white);
  border: none;
  cursor: pointer;
  font-size: var(--body-font-size-s);
  border-inline-end: 1px solid #ccc;
  transition: background 0.15s;
}

main .rate-calculator-toggle:last-child {
  border-inline-end: none;
}

main .rate-calculator-toggle.active,
main .rate-calculator-toggle[aria-pressed="true"] {
  background: var(--cba-yellow);
  font-weight: 700;
}

main .rate-calculator-slider-group input[type="range"] {
  width: 100%;
  accent-color: var(--cba-yellow);
}

main .rate-calculator-amount-display {
  font-size: var(--heading-font-size-s);
  font-weight: 700;
  display: block;
  text-align: center;
  margin-bottom: 8px;
}

main .rate-calculator-results {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  max-width: var(--max-content-width);
  margin-inline: auto;
}

main .rate-calculator-result-card {
  background: var(--clr-white);
  border-radius: 8px;
  padding: 24px;
  text-align: center;
}

main .rate-calculator-rate {
  font-size: 2rem;
  font-weight: 700;
}

main .rate-calculator-unit {
  font-size: 1rem;
  font-weight: 400;
}

/* Skeleton loading state */
main .rate-calculator-skeleton {
  height: 400px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s infinite;
  border-radius: 8px;
}

@keyframes skeleton-shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

---

## Universal Editor Fields

```json
{
  "id": "rate-calculator",
  "fields": [
    { "component": "select", "name": "variant", "label": "Calculator type",
      "options": [
        { "name": "Home loan", "value": "" },
        { "name": "Personal loan", "value": "personal-loan" },
        { "name": "Savings", "value": "savings" }
      ]
    },
    { "component": "text", "name": "defaultAmount", "label": "Default loan amount (e.g. 500000)" },
    { "component": "text", "name": "ratesSource", "label": "Rates JSON feed path" }
  ]
}
```

---

## Accessibility

- Toggle buttons use `aria-pressed="true/false"` — acts as a radio group
- `role="radiogroup"` + `aria-labelledby` on each toggle group
- Rate results area: `aria-live="polite"` so screen readers announce updated rates
- Range slider: `aria-describedby` links to the displayed value output
- Skeleton loading: `aria-label="Loading calculator"` on placeholder

---

## CBA-Specific Notes

- Calculator results are indicative only — the `footnotes` block must include: "Calculator results are indicative only. Actual rates may differ."
- `accent-color: var(--cba-yellow)` styles the range slider thumb in CBA yellow
- Use `IntersectionObserver` to defer JS initialisation — this block is complex and should not load until visible
- Rates filter logic: match `state.purpose` and `state.repayment` against the rates JSON `purpose` and `repayment-type` fields
