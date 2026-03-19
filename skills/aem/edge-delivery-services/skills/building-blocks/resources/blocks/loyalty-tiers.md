# Block: `loyalty-tiers`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** CommBank Yello benefit eligibility requires accurate tier thresholds — verify with CBA digital team before publishing

4-tier card display for CommBank Yello loyalty programme. Cards show tier name, eligibility criteria (monthly spend threshold), and benefit categories. Paired with a retailer logo grid (Ampol, Coles, Myer, JB Hi-Fi, DoorDash). Used on the CommBank Yello page only.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Full 4-tier display |
| `compact` | 2-column display with reduced tier detail |

---

## Content Authoring

```
| Loyalty Tiers |
|--------------|
| ## Yello | No spend requirement | Cashback at Everyday Offers | 5% off at partner retailers |
| ## Yello Plus | $1,000+ monthly spend | All Yello benefits | 10% off at partner retailers | Priority customer service |
| ## Yello Gold | $3,000+ monthly spend | All Yello Plus benefits | 15% off | Airport lounge passes | Dedicated relationship manager |
| ## Yello Diamond | $10,000+ monthly spend | All Yello Gold benefits | 20% off | Unlimited lounge access | Private banking |
```

Each row = one tier. Cell 1 = tier name (H2). Remaining cells = benefit/eligibility text items.

---

## Initial DOM (before JS)

```html
<div class="loyalty-tiers block" data-block-name="loyalty-tiers" data-block-status="initialized">
  <div>
    <div><h2>Yello</h2></div>
    <div><p>No spend requirement</p></div>
    <div><p>Cashback at Everyday Offers</p></div>
    <div><p>5% off at partner retailers</p></div>
  </div>
  <div>
    <div><h2>Yello Plus</h2></div>
    <div><p>$1,000+ monthly spend</p></div>
    <div><p>All Yello benefits</p></div>
    <div><p>10% off at partner retailers</p></div>
    <div><p>Priority customer service</p></div>
  </div>
  <!-- 2 more tiers -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="loyalty-tiers block" data-block-name="loyalty-tiers" data-block-status="loaded">
  <ul class="loyalty-tiers-list">
    <li class="loyalty-tiers-item loyalty-tiers-item--yello">
      <div class="loyalty-tiers-badge" aria-hidden="true">Y</div>
      <h3 class="loyalty-tiers-name">Yello</h3>
      <p class="loyalty-tiers-threshold">No spend requirement</p>
      <ul class="loyalty-tiers-benefits">
        <li>Cashback at Everyday Offers</li>
        <li>5% off at partner retailers</li>
      </ul>
    </li>
    <li class="loyalty-tiers-item loyalty-tiers-item--yello-plus">
      <div class="loyalty-tiers-badge" aria-hidden="true">Y+</div>
      <h3 class="loyalty-tiers-name">Yello Plus</h3>
      <p class="loyalty-tiers-threshold">$1,000+ monthly spend</p>
      <ul class="loyalty-tiers-benefits">
        <li>All Yello benefits</li>
        <li>10% off at partner retailers</li>
        <li>Priority customer service</li>
      </ul>
    </li>
    <!-- Yello Gold, Yello Diamond -->
  </ul>
</div>
```

---

## JavaScript Decoration

```javascript
// Tier name → CSS modifier + badge abbreviation
const TIER_MAP = {
  'yello':   { mod: 'yello',        badge: 'Y' },
  'yello plus': { mod: 'yello-plus', badge: 'Y+' },
  'yello gold': { mod: 'yello-gold', badge: 'YG' },
  'yello diamond': { mod: 'yello-diamond', badge: 'YD' },
};

export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];

  const ul = document.createElement('ul');
  ul.className = 'loyalty-tiers-list';

  rows.forEach((row) => {
    const cells = [...row.querySelectorAll(':scope > div')];
    const [nameCell, thresholdCell, ...benefitCells] = cells;

    const tierName = nameCell.querySelector('h2, h3')?.textContent.trim() || '';
    const tierKey = tierName.toLowerCase();
    const tier = TIER_MAP[tierKey] || { mod: 'default', badge: tierName[0] };

    const li = document.createElement('li');
    li.className = `loyalty-tiers-item loyalty-tiers-item--${tier.mod}`;

    const badge = document.createElement('div');
    badge.className = 'loyalty-tiers-badge';
    badge.setAttribute('aria-hidden', 'true');
    badge.textContent = tier.badge;
    li.append(badge);

    const h3 = document.createElement('h3');
    h3.className = 'loyalty-tiers-name';
    h3.textContent = tierName;
    li.append(h3);

    const threshold = document.createElement('p');
    threshold.className = 'loyalty-tiers-threshold';
    threshold.textContent = thresholdCell.textContent.trim();
    li.append(threshold);

    const benefitUl = document.createElement('ul');
    benefitUl.className = 'loyalty-tiers-benefits';
    benefitCells.forEach((cell) => {
      const benefitLi = document.createElement('li');
      benefitLi.textContent = cell.textContent.trim();
      benefitUl.append(benefitLi);
    });
    li.append(benefitUl);

    ul.append(li);
  });

  block.replaceChildren(ul);
}
```

---

## CSS Structure

```css
main .loyalty-tiers-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  list-style: none;
  padding: 0;
  margin: 0 auto;
  max-width: var(--max-content-width);
}

@media (width >= 900px) {
  main .loyalty-tiers-list {
    grid-template-columns: repeat(4, 1fr);
  }
}

main .loyalty-tiers-item {
  border-radius: 12px;
  padding: 24px 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Tier colour theming */
main .loyalty-tiers-item--yello         { background: #fff9d6; border: 2px solid #ffcc00; }
main .loyalty-tiers-item--yello-plus    { background: #f0f8ff; border: 2px solid #4a90d9; }
main .loyalty-tiers-item--yello-gold    { background: #fff8f0; border: 2px solid #d4a017; }
main .loyalty-tiers-item--yello-diamond { background: #f5f0ff; border: 2px solid #7c3aed; }

main .loyalty-tiers-badge {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  font-size: 0.875rem;
}

main .loyalty-tiers-item--yello         .loyalty-tiers-badge { background: #ffcc00; color: #000; }
main .loyalty-tiers-item--yello-plus    .loyalty-tiers-badge { background: #4a90d9; color: #fff; }
main .loyalty-tiers-item--yello-gold    .loyalty-tiers-badge { background: #d4a017; color: #fff; }
main .loyalty-tiers-item--yello-diamond .loyalty-tiers-badge { background: #7c3aed; color: #fff; }

main .loyalty-tiers-name {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  margin: 0;
}

main .loyalty-tiers-threshold {
  font-size: var(--body-font-size-s);
  font-weight: 600;
  margin: 0;
  color: #555;
}

main .loyalty-tiers-benefits {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: var(--body-font-size-xs);
  display: flex;
  flex-direction: column;
  gap: 6px;
}

main .loyalty-tiers-benefits li::before {
  content: '✓ ';
  color: var(--cba-link);
  font-weight: 700;
}
```

---

## Universal Editor Fields

```json
{
  "id": "loyalty-tiers",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Layout",
      "options": [
        { "name": "Full (4-tier)", "value": "" },
        { "name": "Compact (2-col)", "value": "compact" }
      ]
    }
  ]
}
```

---

## CBA-Specific Notes

- **This block is used exclusively on the CommBank Yello page** — do not add to other page templates
- Tier colours are branded: Yello = yellow, Plus = blue, Gold = gold, Diamond = purple
- Spend thresholds change periodically — verify with the CBA digital team before publishing
- Retailer logo grid (Ampol, Coles, Myer, JB Hi-Fi, DoorDash) is a separate block or auto-block pattern
