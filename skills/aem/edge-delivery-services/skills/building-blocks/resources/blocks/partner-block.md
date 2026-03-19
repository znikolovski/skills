# Block: `partner-block`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** Partner relationship must be clearly attributed with "provided by [Partner]" or similar

Co-branded partner integration block. Displays a partner's logo + image + heading + description + CTA. Used for Home-in conveyancing, NBN co, and insurance provider (Hollard, AIA, PetSure, Cover-More) partnerships.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Standard — image left, text right |
| `text-left` | Text left, image right |

---

## Content Authoring

```
| Partner Block |
|--------------|
| ![Home-in banner](homein-banner.png) | ![Home-in logo](homein-logo.png)
|                                       | ## Conveyancing made simple
|                                       | Move through settlement faster with Home-in, CommBank's preferred conveyancing partner.
|                                       | *Provided by Home-in*
|                                       | [Find out more](https://www.home-in.com.au/?utm_source=commbank) |
```

---

## Initial DOM (before JS)

```html
<div class="partner-block block" data-block-name="partner-block" data-block-status="initialized">
  <div>
    <div>
      <picture><img src="homein-banner.png" alt="" width="500" height="300"></picture>
    </div>
    <div>
      <picture><img src="homein-logo.png" alt="Home-in logo" width="120" height="40"></picture>
      <h2>Conveyancing made simple</h2>
      <p>Move through settlement faster with Home-in, CommBank's preferred conveyancing partner.</p>
      <p><em>Provided by Home-in</em></p>
      <p><a href="https://www.home-in.com.au/?utm_source=commbank">Find out more</a></p>
    </div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="partner-block block" data-block-name="partner-block" data-block-status="loaded">
  <div class="partner-block-content">
    <div class="partner-block-image">
      <picture><img src="homein-banner.png" alt="" loading="lazy"></picture>
    </div>
    <div class="partner-block-body">
      <div class="partner-block-logo">
        <img src="homein-logo.png" alt="Home-in" width="120" height="40">
      </div>
      <h2 class="partner-block-title">Conveyancing made simple</h2>
      <p class="partner-block-description">
        Move through settlement faster with Home-in, CommBank's preferred conveyancing partner.
      </p>
      <p class="partner-block-attribution">Provided by Home-in</p>
      <a href="https://www.home-in.com.au/?utm_source=commbank"
         class="button secondary partner-block-cta"
         target="_blank"
         rel="noopener noreferrer"
         data-analytics-event="cta-partner-homein">
        Find out more
      </a>
    </div>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const [row] = block.querySelectorAll(':scope > div');
  const [imageCell, contentCell] = [...row.querySelectorAll(':scope > div')];

  const content = document.createElement('div');
  content.className = 'partner-block-content';

  // Main image
  const imageDiv = document.createElement('div');
  imageDiv.className = 'partner-block-image';
  const mainImg = imageCell?.querySelector('img');
  if (mainImg) { mainImg.loading = 'lazy'; mainImg.alt = ''; imageDiv.append(mainImg); }
  content.append(imageDiv);

  const body = document.createElement('div');
  body.className = 'partner-block-body';

  // Partner logo (first image in content cell)
  const logoImg = contentCell.querySelector('img');
  if (logoImg) {
    const logoDiv = document.createElement('div');
    logoDiv.className = 'partner-block-logo';
    logoDiv.append(logoImg);
    body.append(logoDiv);
  }

  const heading = contentCell.querySelector('h2, h3');
  if (heading) { heading.className = 'partner-block-title'; body.append(heading); }

  // Description (p without em = description; p with em = attribution)
  [...contentCell.querySelectorAll('p:not(:last-child)')].forEach((p) => {
    if (p.querySelector('em')) {
      p.className = 'partner-block-attribution';
      // Remove <em> wrapper, keep text
      p.textContent = p.querySelector('em').textContent;
    } else if (!p.querySelector('img')) {
      p.className = 'partner-block-description';
    }
    body.append(p);
  });

  // CTA — partner links open in new tab
  const ctaLink = contentCell.querySelector('a');
  if (ctaLink) {
    ctaLink.className = 'button secondary partner-block-cta';
    ctaLink.target = '_blank';
    ctaLink.rel = 'noopener noreferrer';
    body.append(ctaLink);
  }

  content.append(body);
  block.replaceChildren(content);
}
```

---

## CSS Structure

```css
main .partner-block-content {
  display: flex;
  flex-direction: column;
  gap: 0;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e0e0e0;
}

@media (width >= 900px) {
  main .partner-block-content {
    flex-direction: row;
    align-items: stretch;
  }

  main .partner-block-image {
    flex: 0 0 45%;
  }

  main .partner-block.text-left .partner-block-content {
    flex-direction: row-reverse;
  }
}

main .partner-block-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

main .partner-block-body {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
}

main .partner-block-logo img {
  height: 40px;
  width: auto;
  object-fit: contain;
}

main .partner-block-title {
  font-size: var(--heading-font-size-s);
  font-weight: 700;
  margin: 0;
}

main .partner-block-description {
  font-size: var(--body-font-size-m);
  color: #444;
  margin: 0;
}

main .partner-block-attribution {
  font-size: var(--body-font-size-xs);
  color: #888;
  margin: 0;
}
```

---

## Universal Editor Fields

```json
{
  "id": "partner-block",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Image position",
      "options": [
        { "name": "Image left (default)", "value": "" },
        { "name": "Image right (text left)", "value": "text-left" }
      ]
    }
  ]
}
```

---

## CBA-Specific Notes

- Partner external links **always** open in `target="_blank"` with `rel="noopener noreferrer"`
- UTM params on partner URLs (`?utm_source=commbank`) must be preserved — never strip them
- CBA partners on commbank.com.au: Home-in (conveyancing), NBN co (internet), Hollard (home/contents insurance), AIA (life insurance), PetSure (pet insurance), Cover-More (travel insurance)
- Attribution text ("Provided by [Partner]") is a legal/transparency requirement — never remove
