# Block: `rates-fees-table`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Product & Financial
> **Legal:** Rate values may require footnote links — always pair with `footnotes` block

Structured 2–3 column data table for product detail pages. Displays credit card rates & fees, savings account tiers, term deposit rates, and home loan fee schedules. Renders as a visual table but uses `<dl>` or `<table>` markup depending on content type.

---

## Variants

| Variant class | Usage | Markup |
|---|---|---|
| *(no variant)* | Definition list style — label / value / note | `<dl>` |
| `tabular` | True HTML table with column headers | `<table>` |

---

## Content Authoring

**Standard (definition list):**
```
| Rates Fees Table |
|-----------------|
| Monthly Fee | $19 | Waived if $2,000+ monthly spend |
| Purchase Rate | 20.99% p.a.[*] | Standard purchase rate |
| Cash Advance Rate | 21.99% p.a. | — |
| International Fee | 0% | No overseas transaction fees |
| Late Payment Fee | $10 | Charged if minimum payment missed |
```

**Tabular:**
```
| Rates Fees Table (Tabular) |
|---------------------------|
| Term | Interest Rate | Comparison Rate |
| 1 Year Fixed | 5.59% p.a. | 6.12% p.a.[*] |
| 2 Year Fixed | 5.49% p.a. | 6.02% p.a.[*] |
| 3 Year Fixed | 5.69% p.a. | 6.18% p.a.[*] |
```

In tabular variant, the first authored row becomes the `<thead>`.

---

## Initial DOM (before JS) — Standard

```html
<div class="rates-fees-table block" data-block-name="rates-fees-table" data-block-status="initialized">
  <div>
    <div><p>Monthly Fee</p></div>
    <div><p>$19</p></div>
    <div><p>Waived if $2,000+ monthly spend</p></div>
  </div>
  <div>
    <div><p>Purchase Rate</p></div>
    <div><p>20.99% p.a.<sup><a href="#fn-comparison-rate">*</a></sup></p></div>
    <div><p>Standard purchase rate</p></div>
  </div>
  <!-- More rows -->
</div>
```

---

## Decorated DOM (after JS) — Standard

```html
<div class="rates-fees-table block" data-block-name="rates-fees-table" data-block-status="loaded">
  <dl class="rates-fees-table-list">
    <div class="rates-fees-table-row">
      <dt class="rates-fees-table-label">Monthly Fee</dt>
      <dd class="rates-fees-table-value">$19</dd>
      <dd class="rates-fees-table-note">Waived if $2,000+ monthly spend</dd>
    </div>
    <div class="rates-fees-table-row">
      <dt class="rates-fees-table-label">Purchase Rate</dt>
      <dd class="rates-fees-table-value">
        20.99% p.a.<sup><a href="#fn-comparison-rate">*</a></sup>
      </dd>
      <dd class="rates-fees-table-note">Standard purchase rate</dd>
    </div>
  </dl>
</div>
```

## Decorated DOM (after JS) — Tabular

```html
<div class="rates-fees-table tabular block" data-block-name="rates-fees-table" data-block-status="loaded">
  <div class="rates-fees-table-scroll">
    <table class="rates-fees-table-element">
      <thead>
        <tr>
          <th scope="col">Term</th>
          <th scope="col">Interest Rate</th>
          <th scope="col">Comparison Rate</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>1 Year Fixed</td>
          <td>5.59% p.a.</td>
          <td>6.12% p.a.<sup><a href="#fn-comparison-rate">*</a></sup></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const isTabular = block.classList.contains('tabular');
  const rows = [...block.querySelectorAll(':scope > div')];

  if (isTabular) {
    decorateTabular(block, rows);
  } else {
    decorateDefinitionList(block, rows);
  }
}

function decorateDefinitionList(block, rows) {
  const dl = document.createElement('dl');
  dl.className = 'rates-fees-table-list';

  rows.forEach((row) => {
    const cells = [...row.querySelectorAll(':scope > div')];
    const [labelCell, valueCell, noteCell] = cells;

    const div = document.createElement('div');
    div.className = 'rates-fees-table-row';

    const dt = document.createElement('dt');
    dt.className = 'rates-fees-table-label';
    dt.innerHTML = labelCell.innerHTML;

    const ddValue = document.createElement('dd');
    ddValue.className = 'rates-fees-table-value';
    ddValue.innerHTML = valueCell.innerHTML;

    div.append(dt, ddValue);

    if (noteCell && noteCell.textContent.trim() !== '—') {
      const ddNote = document.createElement('dd');
      ddNote.className = 'rates-fees-table-note';
      ddNote.innerHTML = noteCell.innerHTML;
      div.append(ddNote);
    }

    dl.append(div);
  });

  block.replaceChildren(dl);
}

function decorateTabular(block, rows) {
  const [headerRow, ...bodyRows] = rows;
  const headerCells = [...headerRow.querySelectorAll(':scope > div')];

  const table = document.createElement('table');
  table.className = 'rates-fees-table-element';

  const thead = document.createElement('thead');
  const headerTr = document.createElement('tr');
  headerCells.forEach((cell) => {
    const th = document.createElement('th');
    th.scope = 'col';
    th.innerHTML = cell.innerHTML;
    headerTr.append(th);
  });
  thead.append(headerTr);
  table.append(thead);

  const tbody = document.createElement('tbody');
  bodyRows.forEach((row) => {
    const tr = document.createElement('tr');
    [...row.querySelectorAll(':scope > div')].forEach((cell) => {
      const td = document.createElement('td');
      td.innerHTML = cell.innerHTML;
      tr.append(td);
    });
    tbody.append(tr);
  });
  table.append(tbody);

  // Scroll wrapper for mobile
  const scrollDiv = document.createElement('div');
  scrollDiv.className = 'rates-fees-table-scroll';
  scrollDiv.append(table);

  block.replaceChildren(scrollDiv);
}
```

---

## CSS Structure

```css
/* ── Definition list style ────────────────────────── */
main .rates-fees-table-list {
  margin: 0;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

main .rates-fees-table-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 16px;
  padding: 14px 20px;
  border-bottom: 1px solid #f0f0f0;
  align-items: start;
}

main .rates-fees-table-row:last-child {
  border-bottom: none;
}

main .rates-fees-table-row:nth-child(even) {
  background: var(--cba-grey);
}

main .rates-fees-table-label {
  font-size: var(--body-font-size-s);
  color: #555;
  font-weight: 400;
}

main .rates-fees-table-value {
  font-weight: 700;
  font-size: var(--body-font-size-s);
  margin: 0;
  color: var(--cba-black);
}

main .rates-fees-table-note {
  grid-column: 1 / -1;
  font-size: var(--body-font-size-xs);
  color: #888;
  margin: 4px 0 0;
}

@media (width >= 600px) {
  main .rates-fees-table-row {
    grid-template-columns: 1fr 1fr auto;
  }

  main .rates-fees-table-note {
    grid-column: unset;
    margin: 0;
  }
}

/* ── Tabular variant ──────────────────────────────── */
main .rates-fees-table-scroll {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

main .rates-fees-table-element {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--body-font-size-s);
}

main .rates-fees-table-element th {
  background: var(--cba-dark-blue);
  color: var(--clr-white);
  padding: 12px 16px;
  text-align: start;
  font-weight: 600;
}

main .rates-fees-table-element td {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
}

main .rates-fees-table-element tbody tr:nth-child(even) td {
  background: var(--cba-grey);
}
```

---

## Universal Editor Fields

```json
{
  "id": "rates-fees-table",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Table style",
      "options": [
        { "name": "Definition list (label / value / note)", "value": "" },
        { "name": "Tabular (with column headers)", "value": "tabular" }
      ]
    }
  ]
}
```

---

## Accessibility

- Definition list (`<dl>/<dt>/<dd>`) correctly marks up the label–value relationship
- Tabular variant: `<th scope="col">` on all column headers
- Mobile horizontal scroll: wrap `<table>` in a scrollable `<div>` — do not allow the table to overflow viewport
- Rate values with footnote superscripts: `<sup><a href="#fn-*" aria-label="Footnote">*</a></sup>`
