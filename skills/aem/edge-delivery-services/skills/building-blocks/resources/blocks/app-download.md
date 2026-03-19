# Block: `app-download`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** App Store / Google Play badge usage must follow Apple/Google brand guidelines

App store badge pair (Apple App Store + Google Play) with optional device mockup image. Used on digital banking pages to promote CommBank App download.

---

## Content Authoring

```
| App Download |
|-------------|
| ![CommBank App mockup](app-mockup.png) | ## Bank anywhere with the CommBank App
|                                         | Pay, transfer, invest and more — all from your phone.
|                                         | [Download on the App Store](https://apps.apple.com/au/app/commbank/id310251202)
|                                         | [Get it on Google Play](https://play.google.com/store/apps/details?id=com.commbank.netbank) |
```

---

## Initial DOM (before JS)

```html
<div class="app-download block" data-block-name="app-download" data-block-status="initialized">
  <div>
    <div>
      <picture><img src="app-mockup.png" alt="CommBank App on iPhone" width="300" height="500"></picture>
    </div>
    <div>
      <h2>Bank anywhere with the CommBank App</h2>
      <p>Pay, transfer, invest and more — all from your phone.</p>
      <p><a href="https://apps.apple.com/au/app/commbank/id310251202">Download on the App Store</a></p>
      <p><a href="https://play.google.com/store/apps/details?id=com.commbank.netbank">Get it on Google Play</a></p>
    </div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="app-download block" data-block-name="app-download" data-block-status="loaded">
  <div class="app-download-content">
    <div class="app-download-image">
      <img src="app-mockup.png" alt="CommBank App on iPhone" width="300" height="500">
    </div>
    <div class="app-download-text">
      <h2 class="app-download-title">Bank anywhere with the CommBank App</h2>
      <p class="app-download-description">Pay, transfer, invest and more — all from your phone.</p>
      <div class="app-download-badges">
        <a href="https://apps.apple.com/au/app/commbank/id310251202"
           class="app-download-badge app-download-badge-apple"
           target="_blank"
           rel="noopener noreferrer"
           aria-label="Download CommBank on the App Store">
          <img src="/icons/badge-app-store.svg" alt="Download on the App Store" width="135" height="40">
        </a>
        <a href="https://play.google.com/store/apps/details?id=com.commbank.netbank"
           class="app-download-badge app-download-badge-google"
           target="_blank"
           rel="noopener noreferrer"
           aria-label="Get CommBank on Google Play">
          <img src="/icons/badge-google-play.svg" alt="Get it on Google Play" width="135" height="40">
        </a>
      </div>
    </div>
  </div>
</div>
```

---

## JavaScript Decoration

```javascript
const APPLE_URL = 'https://apps.apple.com/au/app/commbank/id310251202';
const GOOGLE_URL = 'https://play.google.com/store/apps/details?id=com.commbank.netbank';

// Map link text patterns to badge types
const BADGE_MAP = [
  { pattern: /app store/i, type: 'apple', icon: '/icons/badge-app-store.svg', alt: 'Download on the App Store', ariaLabel: 'Download CommBank on the App Store', href: APPLE_URL },
  { pattern: /google play/i, type: 'google', icon: '/icons/badge-google-play.svg', alt: 'Get it on Google Play', ariaLabel: 'Get CommBank on Google Play', href: GOOGLE_URL },
];

export default async function decorate(block) {
  const [row] = block.querySelectorAll(':scope > div');
  const cells = [...row.querySelectorAll(':scope > div')];
  const [imageCell, contentCell] = cells.length > 1 ? cells : [null, cells[0]];

  const content = document.createElement('div');
  content.className = 'app-download-content';

  if (imageCell) {
    const imageDiv = document.createElement('div');
    imageDiv.className = 'app-download-image';
    imageDiv.append(...imageCell.children);
    content.append(imageDiv);
  }

  const textDiv = document.createElement('div');
  textDiv.className = 'app-download-text';

  const heading = contentCell.querySelector('h2, h3');
  if (heading) { heading.className = 'app-download-title'; textDiv.append(heading); }

  const desc = contentCell.querySelector('p:not(:has(a))');
  if (desc) { desc.className = 'app-download-description'; textDiv.append(desc); }

  const badgesDiv = document.createElement('div');
  badgesDiv.className = 'app-download-badges';

  const appLinks = [...contentCell.querySelectorAll('a')];
  appLinks.forEach((link) => {
    const badge = BADGE_MAP.find((b) => b.pattern.test(link.textContent));
    if (!badge) return;

    const a = document.createElement('a');
    a.href = badge.href;
    a.className = `app-download-badge app-download-badge-${badge.type}`;
    a.target = '_blank';
    a.rel = 'noopener noreferrer';
    a.setAttribute('aria-label', badge.ariaLabel);

    const img = document.createElement('img');
    img.src = badge.icon;
    img.alt = badge.alt;
    img.width = 135;
    img.height = 40;

    a.append(img);
    badgesDiv.append(a);
  });

  textDiv.append(badgesDiv);
  content.append(textDiv);
  block.replaceChildren(content);
}
```

---

## CSS Structure

```css
main .app-download {
  padding-inline: var(--inline-section-padding);
  padding-block: 48px;
}

main .app-download-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
  align-items: center;
  max-width: var(--max-content-width);
  margin-inline: auto;
}

@media (width >= 900px) {
  main .app-download-content {
    flex-direction: row;
    gap: 64px;
  }

  main .app-download-image {
    flex-shrink: 0;
  }
}

main .app-download-image img {
  max-width: 240px;
  height: auto;
  display: block;
}

main .app-download-title {
  font-size: var(--heading-font-size-m);
  font-weight: 700;
  margin: 0 0 16px;
}

main .app-download-description {
  font-size: var(--body-font-size-m);
  color: #444;
  margin-bottom: 24px;
}

main .app-download-badges {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

main .app-download-badge img {
  height: 40px;
  width: auto;
}
```

---

## Universal Editor Fields

```json
{
  "id": "app-download",
  "fields": [
    { "component": "aem-content", "name": "image", "label": "App mockup image" },
    { "component": "richtext", "name": "text", "label": "Heading and description" }
  ]
}
```

---

## CBA-Specific Notes

- **App Store link**: `https://apps.apple.com/au/app/commbank/id310251202` — CommBank App (4.8★, 2M+ ratings)
- **Google Play link**: `https://play.google.com/store/apps/details?id=com.commbank.netbank`
- Badge SVGs must be the official Apple/Google badge assets — stored in `icons/badge-app-store.svg` and `icons/badge-google-play.svg`
- Both badge links open in `target="_blank"` — these exit the CBA website
- Device mockup image: use the latest CommBank App screenshot — update when major app UI changes
