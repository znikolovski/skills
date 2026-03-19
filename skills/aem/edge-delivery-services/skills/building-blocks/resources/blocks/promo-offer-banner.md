# Block: `promo-offer-banner`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Hero & Promotional
> **Legal:** Offer end dates and T&Cs must link to `footnotes` block

Inline time-limited promotional offer with bold headline, offer details, deadline, and dual CTA. Used between product sections on landing pages. Common for Qantas Points bonuses, cashback offers, and rate specials.

---

## Variants

| Variant class | Usage | Background |
|---|---|---|
| *(no variant)* | Yellow — CBA brand promo | `var(--cba-yellow)` |
| `dark` | Dark blue — CommBank Yello / loyalty promo | `var(--cba-dark-blue)` |
| `image-left` | Offer text right, image left | `var(--cba-grey)` |

---

## Content Authoring

```
| Promo Offer Banner |
|-------------------|
| ## Home loan today. Holiday tomorrow. |
| Earn up to 300,000 Qantas Points when you take out an eligible CommBank home loan. Offer ends 30 June 2026.[~] |
| [Get started](#modal-apply) | [Terms apply](#footnotes) |
```

```
| Promo Offer Banner (Image Left) |
|---------------------------------|
| ![Qantas plane](qantas.png) | ## Earn Qantas Points on your home loan
|                              | Up to 300,000 Qantas Points. Offer ends 30 June 2026.[~]
|                              | [Get started](#modal-apply) [Terms apply](#footnotes) |
```

---

## Initial DOM (before JS) — Standard

```html
<div class="promo-offer-banner block" data-block-name="promo-offer-banner" data-block-status="initialized">
  <div><div><h2>Home loan today. Holiday tomorrow.</h2></div></div>
  <div><div><p>Earn up to 300,000 Qantas Points... Offer ends 30 June 2026.<sup><a href="#fn-tilde">~</a></sup></p></div></div>
  <div>
    <div><p><a href="#modal-apply" class="button primary">Get started</a></p></div>
    <div><p><a href="#footnotes">Terms apply</a></p></div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="promo-offer-banner block" data-block-name="promo-offer-banner" data-block-status="loaded">
  <div class="promo-offer-banner-content">
    <div class="promo-offer-banner-text">
      <h2 class="promo-offer-banner-heading">Home loan today. Holiday tomorrow.</h2>
      <p class="promo-offer-banner-description">
        Earn up to 300,000 Qantas Points...
        <sup><a href="#fn-tilde">~</a></sup>
      </p>
      <div class="promo-offer-banner-actions">
        <a href="#modal-apply" class="button primary" data-analytics-event="cta-promobanner-getstarted">Get started</a>
        <a href="#footnotes" class="promo-offer-banner-terms" data-analytics-event="cta-promobanner-terms">Terms apply</a>
      </div>
    </div>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const isImageLeft = block.classList.contains('image-left');
  const rows = [...block.querySelectorAll(':scope > div')];

  const content = document.createElement('div');
  content.className = 'promo-offer-banner-content';

  let imageDiv = null;

  if (isImageLeft && rows[0].querySelectorAll(':scope > div').length > 1) {
    // Image-left layout: Row 0 = [image | text + CTAs]
    const [imgCell, textCell] = [...rows[0].querySelectorAll(':scope > div')];
    imageDiv = document.createElement('div');
    imageDiv.className = 'promo-offer-banner-image';
    imageDiv.append(...imgCell.children);
    const textDiv = buildTextContent(textCell);
    content.append(imageDiv, textDiv);
  } else {
    // Standard layout: rows are heading, description, CTAs
    const [headingRow, descRow, ctaRow] = rows;
    const textDiv = document.createElement('div');
    textDiv.className = 'promo-offer-banner-text';

    const heading = headingRow.querySelector('h1, h2, h3');
    if (heading) { heading.className = 'promo-offer-banner-heading'; textDiv.append(heading); }

    const desc = descRow?.querySelector('p');
    if (desc) { desc.className = 'promo-offer-banner-description'; textDiv.append(desc); }

    if (ctaRow) {
      const actions = document.createElement('div');
      actions.className = 'promo-offer-banner-actions';
      const links = [...ctaRow.querySelectorAll('a')];
      links.forEach((link, i) => {
        if (i === 0) link.className = 'button primary';
        else link.className = 'promo-offer-banner-terms';
        actions.append(link);
      });
      textDiv.append(actions);
    }

    content.append(textDiv);
  }

  block.replaceChildren(content);
}

function buildTextContent(cell) {
  const textDiv = document.createElement('div');
  textDiv.className = 'promo-offer-banner-text';
  const heading = cell.querySelector('h1, h2, h3');
  const desc = cell.querySelector('p:not(:last-child)');
  const ctaP = cell.querySelector('p:last-child');
  if (heading) { heading.className = 'promo-offer-banner-heading'; textDiv.append(heading); }
  if (desc) { desc.className = 'promo-offer-banner-description'; textDiv.append(desc); }
  if (ctaP) {
    ctaP.className = 'promo-offer-banner-actions';
    textDiv.append(ctaP);
  }
  return textDiv;
}
```

---

## CSS Structure

```css
main .promo-offer-banner {
  background: var(--cba-yellow);
  padding-block: 48px;
  padding-inline: var(--inline-section-padding);
}

main .promo-offer-banner-content {
  max-width: var(--max-content-width);
  margin-inline: auto;
  display: flex;
  flex-direction: column;
  gap: 24px;
  align-items: flex-start;
}

@media (width >= 900px) {
  main .promo-offer-banner-content {
    flex-direction: row;
    align-items: center;
  }

  main .promo-offer-banner.image-left .promo-offer-banner-image {
    flex-shrink: 0;
    width: 40%;
  }
}

main .promo-offer-banner-heading {
  font-size: var(--heading-font-size-l);
  font-weight: 700;
  margin: 0 0 16px;
  color: var(--cba-black);
}

main .promo-offer-banner-description {
  font-size: var(--body-font-size-m);
  color: var(--cba-black);
  margin-bottom: 24px;
}

main .promo-offer-banner-actions {
  display: flex;
  gap: 20px;
  align-items: center;
  flex-wrap: wrap;
}

main .promo-offer-banner-terms {
  font-size: var(--body-font-size-s);
  color: var(--cba-black);
  text-decoration: underline;
}

/* dark variant */
main .promo-offer-banner.dark {
  background: var(--cba-dark-blue);
}

main .promo-offer-banner.dark .promo-offer-banner-heading,
main .promo-offer-banner.dark .promo-offer-banner-description,
main .promo-offer-banner.dark .promo-offer-banner-terms {
  color: var(--clr-white);
}
```

---

## Universal Editor Fields

```json
{
  "id": "promo-offer-banner",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Style",
      "options": [
        { "name": "Yellow (default)", "value": "" },
        { "name": "Dark blue", "value": "dark" },
        { "name": "Image left", "value": "image-left" }
      ]
    }
  ]
}
```

---

## CBA-Specific Notes

- Qantas Points offers: always include offer end date and `[~]` footnote marker
- "Terms apply" link must always point to `#footnotes` — never to an external URL
- "Get started" CTA points to `#modal-apply` on product pages — not directly to an application URL
