# Block: `featured-content`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** None

Single large editorial card (780×416px image) with heading, description, and CTA. Often leads a content section on the homepage (followed by a row of 4 smaller thumbnail cards). Used for "More from CommBank" / promotional editorial sections.

---

## Content Authoring

```
| Featured Content |
|----------------|
| ![hero image](featured-img.png) | ## Home loan today. Holiday tomorrow.
|                                  | Earn up to 300,000 Qantas Points on eligible home loans.
|                                  | [Find out more](/home-loans/qantas-points) |
```

---

## Initial DOM (before JS)

```html
<div class="featured-content block" data-block-name="featured-content" data-block-status="initialized">
  <div>
    <div>
      <picture><img src="featured-img.png" alt="" width="780" height="416"></picture>
    </div>
    <div>
      <h2>Home loan today. Holiday tomorrow.</h2>
      <p>Earn up to 300,000 Qantas Points on eligible home loans.</p>
      <p><a href="/home-loans/qantas-points">Find out more</a></p>
    </div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="featured-content block" data-block-name="featured-content" data-block-status="loaded">
  <article class="featured-content-card">
    <a href="/home-loans/qantas-points" class="featured-content-image-link" aria-hidden="true" tabindex="-1">
      <div class="featured-content-image">
        <picture><img src="featured-img.png" alt="" width="780" height="416" loading="lazy"></picture>
      </div>
    </a>
    <div class="featured-content-body">
      <h2 class="featured-content-title">
        <a href="/home-loans/qantas-points">Home loan today. Holiday tomorrow.</a>
      </h2>
      <p class="featured-content-description">Earn up to 300,000 Qantas Points on eligible home loans.</p>
      <a href="/home-loans/qantas-points" class="button secondary featured-content-cta"
         aria-label="Find out more about Home loan today. Holiday tomorrow.">
        Find out more
      </a>
    </div>
  </article>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const [row] = block.querySelectorAll(':scope > div');
  const [imageCell, contentCell] = [...row.querySelectorAll(':scope > div')];

  const link = contentCell.querySelector('a');
  const href = link?.href || '#';

  const article = document.createElement('article');
  article.className = 'featured-content-card';

  // Image — wrapped in same link as title
  const imageLink = document.createElement('a');
  imageLink.href = href;
  imageLink.className = 'featured-content-image-link';
  imageLink.tabIndex = -1;
  imageLink.setAttribute('aria-hidden', 'true');
  const imageDiv = document.createElement('div');
  imageDiv.className = 'featured-content-image';
  const img = imageCell.querySelector('img');
  if (img) { img.loading = 'lazy'; img.alt = ''; imageDiv.append(img); }
  imageLink.append(imageDiv);
  article.append(imageLink);

  // Body
  const body = document.createElement('div');
  body.className = 'featured-content-body';

  const heading = contentCell.querySelector('h2, h3');
  if (heading) {
    const h2 = document.createElement('h2');
    h2.className = 'featured-content-title';
    const titleLink = document.createElement('a');
    titleLink.href = href;
    titleLink.innerHTML = heading.innerHTML;
    h2.append(titleLink);
    body.append(h2);
  }

  const desc = contentCell.querySelector('p:not(:last-child)');
  if (desc) { desc.className = 'featured-content-description'; body.append(desc); }

  if (link) {
    link.className = 'button secondary featured-content-cta';
    link.setAttribute('aria-label', `Find out more about ${heading?.textContent.trim() || ''}`);
    body.append(link.closest('p') || link);
  }

  article.append(body);
  block.replaceChildren(article);
}
```

---

## CSS Structure

```css
main .featured-content-card {
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e0e0e0;
}

@media (width >= 900px) {
  main .featured-content-card {
    flex-direction: row;
  }

  main .featured-content-image {
    flex: 0 0 55%;
  }

  main .featured-content-body {
    flex: 1;
    padding: 40px;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }
}

main .featured-content-image img {
  width: 100%;
  aspect-ratio: 780 / 416;
  object-fit: cover;
  display: block;
}

main .featured-content-body {
  padding: 24px;
}

main .featured-content-title {
  font-size: var(--heading-font-size-m);
  font-weight: 700;
  margin: 0 0 16px;
}

main .featured-content-title a {
  color: var(--cba-black);
  text-decoration: none;
}

main .featured-content-title a:hover {
  color: var(--cba-link);
  text-decoration: underline;
}

main .featured-content-description {
  font-size: var(--body-font-size-m);
  color: #444;
  margin-bottom: 24px;
}
```

---

## Universal Editor Fields

```json
{
  "id": "featured-content",
  "fields": [
    { "component": "aem-content", "name": "image", "label": "Feature image (780×416px)" },
    { "component": "richtext", "name": "text", "label": "Heading, description and CTA" }
  ]
}
```

---

## CBA-Specific Notes

- Image aspect ratio: 780×416 (approx 16:9) — use `aspect-ratio: 780 / 416` CSS to enforce
- Typically appears as the lead card in a "More from CommBank" section, followed by a `article-cards` block with 3 smaller cards
- The same link appears three times: image, title, and CTA — only title link is in the tab order
