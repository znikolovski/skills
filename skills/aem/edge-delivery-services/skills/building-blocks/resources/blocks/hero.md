# Block: `hero`

> **Status:** Exists in boilerplate — must be enhanced with 4 CBA variants
> **Loading phase:** EAGER (is the LCP element — loads in phase 1)
> **Category:** Hero & Promotional
> **Legal:** None

The first block on every CBA page. Drives LCP. Must render without JS for performance.

---

## Variants

| Variant class | Usage | Visual |
|---|---|---|
| *(no variant)* | Standard — H1 + text + CTAs on yellow/white | Homepage, product listing |
| `image-right` | H1 + text + CTAs left, product image right | Credit cards, savings |
| `full-bleed` | Full-width background image with overlaid text | Hub pages, campaign |
| `editorial` | Category tag + H1 + publish date, no CTAs | Newsroom article pages |

---

## Content Authoring (SharePoint / Google Drive table)

**Standard / image-right:**
```
| Hero [image-right] |
|--------------------|
| [product image]    | ## Heading line one
|                    | Subheading or descriptor text.
|                    | [Primary CTA](url) [Secondary CTA](url) |
```

**Full-bleed:**
```
| Hero (Full Bleed) |
|-------------------|
| [background image] | ## Hub heading
|                    | Short descriptor line.
|                    | [CTA button](url) |
```

**Editorial:**
```
| Hero (Editorial) |
|------------------|
| News             |
| ## Article headline here spanning up to two lines |
| 19 March 2026    |
```

---

## Initial DOM (before JS — what EDS delivers)

```html
<!-- Standard or image-right -->
<div class="hero block [image-right]" data-block-name="hero" data-block-status="initialized">
  <div>
    <div>
      <picture>
        <source type="image/webp" srcset="...?width=2000&format=webply&optimize=medium">
        <img loading="eager" alt="Product description" src="...?width=750&format=png&optimize=medium"
             width="1200" height="600">
      </picture>
    </div>
    <div>
      <h1>Heading line one</h1>
      <p>Subheading or descriptor text.</p>
      <p>
        <a href="/apply" class="button primary" title="Primary CTA">Primary CTA</a>
        <a href="/learn-more" class="button secondary" title="Secondary CTA">Secondary CTA</a>
      </p>
    </div>
  </div>
</div>

<!-- Editorial variant — 3 cells in 3 rows -->
<div class="hero editorial block" data-block-name="hero" data-block-status="initialized">
  <div><div><p>News</p></div></div>
  <div><div><h1>Article headline here spanning up to two lines</h1></div></div>
  <div><div><p>19 March 2026</p></div></div>
</div>
```

---

## Decorated DOM (after `decorate(block)` runs)

```html
<!-- Standard -->
<div class="hero block" data-block-name="hero" data-block-status="loaded">
  <div class="hero-content">
    <div class="hero-text">
      <h1>Heading line one</h1>
      <p class="hero-description">Subheading or descriptor text.</p>
      <div class="hero-actions">
        <a href="/apply" class="button primary">Primary CTA</a>
        <a href="/learn-more" class="button secondary">Secondary CTA</a>
      </div>
    </div>
  </div>
</div>

<!-- image-right -->
<div class="hero image-right block" data-block-name="hero" data-block-status="loaded">
  <div class="hero-content">
    <div class="hero-text">
      <h1>Heading</h1>
      <p class="hero-description">Text.</p>
      <div class="hero-actions">
        <a href="/apply" class="button primary">Apply now</a>
      </div>
    </div>
    <div class="hero-image">
      <picture>...</picture>
    </div>
  </div>
</div>

<!-- editorial -->
<div class="hero editorial block" data-block-name="hero" data-block-status="loaded">
  <div class="hero-content">
    <p class="hero-category">News</p>
    <h1>Article headline</h1>
    <p class="hero-date">
      <time datetime="2026-03-19">19 March 2026</time>
    </p>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const isEditorial = block.classList.contains('editorial');
  const isImageRight = block.classList.contains('image-right');
  const isFullBleed = block.classList.contains('full-bleed');

  const rows = [...block.querySelectorAll(':scope > div')];

  if (isEditorial) {
    // Row 0: category tag, Row 1: H1, Row 2: date
    const [categoryRow, headlineRow, dateRow] = rows;
    const content = document.createElement('div');
    content.className = 'hero-content';

    const category = categoryRow.querySelector('p');
    if (category) category.className = 'hero-category';

    const date = dateRow?.querySelector('p');
    if (date) {
      date.className = 'hero-date';
      // Wrap text in <time> element
      const dateText = date.textContent.trim();
      const time = document.createElement('time');
      // Parse "19 March 2026" → "2026-03-19"
      time.setAttribute('datetime', parseDateToISO(dateText));
      time.textContent = dateText;
      date.replaceChildren(time);
    }

    content.append(...[category?.closest('div'), headlineRow?.querySelector('h1'), date].filter(Boolean));
    block.replaceChildren(content);
    return;
  }

  // Standard, image-right, full-bleed
  const [row] = rows;
  const cells = [...row.querySelectorAll(':scope > div')];
  const [imageCell, textCell] = isImageRight ? cells : [null, cells[0]];

  const content = document.createElement('div');
  content.className = 'hero-content';

  const textDiv = document.createElement('div');
  textDiv.className = 'hero-text';

  const h1 = textCell.querySelector('h1, h2');
  const desc = textCell.querySelector('p:not(:last-child)');
  const actions = textCell.querySelector('p:last-child');

  if (h1) textDiv.append(h1);
  if (desc) textDiv.append(desc);

  if (actions) {
    actions.className = 'hero-actions';
    textDiv.append(actions);
  }

  content.append(textDiv);

  if (imageCell) {
    const imageDiv = document.createElement('div');
    imageDiv.className = 'hero-image';
    imageDiv.append(...imageCell.children);
    content.append(imageDiv);
  }

  if (isFullBleed && imageCell) {
    // Full-bleed: set background image via CSS custom property
    const img = imageCell.querySelector('img');
    if (img) {
      block.style.setProperty('--hero-bg-image', `url(${img.src})`);
      imageCell.remove();
    }
  }

  block.replaceChildren(content);
}
```

---

## CSS Structure

```css
/* ── Base ─────────────────────────────────────────── */
main .hero {
  background-color: var(--cba-yellow);
  padding-block: 48px;
  padding-inline: var(--inline-section-padding);
}

main .hero .hero-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
  max-width: var(--max-content-width);
  margin-inline: auto;
}

main .hero h1 {
  font-family: var(--cba-font-sans);
  font-size: var(--heading-font-size-xl);
  font-weight: 700;
  color: var(--cba-black);
  margin: 0;
}

main .hero .hero-description {
  font-size: var(--body-font-size-l);
  color: var(--cba-black);
}

main .hero .hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

/* ── image-right variant ──────────────────────────── */
@media (width >= 900px) {
  main .hero.image-right .hero-content {
    flex-direction: row;
    align-items: center;
  }

  main .hero.image-right .hero-text {
    flex: 1;
  }

  main .hero.image-right .hero-image {
    flex: 1;
    text-align: right;
  }

  main .hero.image-right .hero-image picture img {
    max-width: 100%;
    height: auto;
  }
}

/* ── full-bleed variant ───────────────────────────── */
main .hero.full-bleed {
  background-image: var(--hero-bg-image);
  background-size: cover;
  background-position: center;
  min-height: 400px;
}

main .hero.full-bleed h1,
main .hero.full-bleed .hero-description {
  color: var(--clr-white);
  text-shadow: 0 1px 3px rgb(0 0 0 / 40%);
}

/* ── editorial variant ────────────────────────────── */
main .hero.editorial {
  background-color: var(--cba-dark-blue);
  padding-block: 64px;
}

main .hero.editorial .hero-category {
  color: var(--cba-yellow);
  font-size: var(--body-font-size-s);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 16px;
}

main .hero.editorial h1 {
  color: var(--clr-white);
}

main .hero.editorial .hero-date {
  color: rgb(255 255 255 / 70%);
  font-size: var(--body-font-size-s);
}

/* ── Responsive ───────────────────────────────────── */
@media (width >= 600px) {
  main .hero {
    padding-block: 64px;
  }
}

@media (width >= 900px) {
  main .hero {
    padding-block: 80px;
  }
}
```

---

## Universal Editor Fields (`component-models.json`)

```json
{
  "id": "hero",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Variant",
      "options": [
        { "name": "Standard", "value": "" },
        { "name": "Image Right", "value": "image-right" },
        { "name": "Full Bleed", "value": "full-bleed" },
        { "name": "Editorial", "value": "editorial" }
      ]
    },
    { "component": "aem-content", "name": "image", "label": "Hero Image" },
    { "component": "richtext",    "name": "heading", "label": "Heading (H1)" },
    { "component": "richtext",    "name": "text",    "label": "Description" },
    { "component": "aem-content", "name": "cta1",   "label": "Primary CTA link" },
    { "component": "text",        "name": "cta1Label", "label": "Primary CTA label" },
    { "component": "aem-content", "name": "cta2",   "label": "Secondary CTA link", "required": false },
    { "component": "text",        "name": "cta2Label", "label": "Secondary CTA label", "required": false }
  ]
}
```

---

## Accessibility

- H1 must be the first heading on the page — do not use H2 inside hero
- `<picture>` `alt` text must describe the image meaningfully (not empty)
- Full-bleed background images set via CSS must have a separate visually-hidden description if decorative
- CTA buttons: `aria-label` if button text alone is ambiguous (e.g., "Learn more" → `aria-label="Learn more about home loans"`)
- Colour contrast: dark text on CBA yellow must meet 4.5:1 — test before deploying

---

## Performance Notes

- `loading="eager"` must remain on the `<img>` inside hero — this is the LCP element
- No `decorate()` function should `fetch()` data — hero is in Phase 1 (eager)
- Full-bleed background image: preload with `<link rel="preload">` via `head.html` if the image is known ahead of time
- Keep hero JS minimal — any heavy transformation delays LCP
