# Block: `article-cards`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** None

3-column grid of image + heading + excerpt + "Read more" link. Used on landing pages for news/guide teasers and in "Related content" sections at the bottom of articles. Supports optional lazy-loading of cards from the query index.

---

## Variants

| Variant class | Usage |
|---|---|
| *(no variant)* | Authored — 3 cards hardcoded in content |
| `dynamic` | Fetches latest articles from `/query-index.json` |

---

## Content Authoring

**Authored variant:**
```
| Article Cards |
|--------------|
| ![thumbnail](img1.png) | ## How to choose the right home loan
|                         | A guide to fixed vs variable rates and what suits your situation.
|                         | [Read more](/articles/home-loan-guide) |
| ![thumbnail](img2.png) | ## Understanding credit card rewards
|                         | Make the most of your points with these tips.
|                         | [Read more](/articles/credit-card-rewards) |
| ![thumbnail](img3.png) | ## Saving for your first home
|                         | How the First Home Owner Grant works and who qualifies.
|                         | [Read more](/articles/first-home-grant) |
```

**Dynamic variant:**
```
| Article Cards (Dynamic) |
|------------------------|
| limit | 3 |
| category | home-loans |
```

---

## Initial DOM (before JS) — Authored

```html
<div class="article-cards block" data-block-name="article-cards" data-block-status="initialized">
  <div>
    <div><picture><img src="img1.png" alt="" width="400" height="225"></picture></div>
    <div>
      <h2>How to choose the right home loan</h2>
      <p>A guide to fixed vs variable rates and what suits your situation.</p>
      <p><a href="/articles/home-loan-guide">Read more</a></p>
    </div>
  </div>
  <!-- 2 more rows -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="article-cards block" data-block-name="article-cards" data-block-status="loaded">
  <ul class="article-cards-list">
    <li class="article-cards-item">
      <article>
        <a href="/articles/home-loan-guide" class="article-cards-image-link" tabindex="-1" aria-hidden="true">
          <div class="article-cards-image">
            <picture><img src="img1.png" alt="" loading="lazy" width="400" height="225"></picture>
          </div>
        </a>
        <div class="article-cards-body">
          <h3 class="article-cards-title">
            <a href="/articles/home-loan-guide">How to choose the right home loan</a>
          </h3>
          <p class="article-cards-excerpt">A guide to fixed vs variable rates and what suits your situation.</p>
          <a href="/articles/home-loan-guide" class="article-cards-cta" aria-label="Read more about How to choose the right home loan">Read more</a>
        </div>
      </article>
    </li>
    <!-- 2 more items -->
  </ul>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const isDynamic = block.classList.contains('dynamic');

  if (isDynamic) {
    await decorateDynamic(block);
  } else {
    decorateAuthored(block);
  }
}

function decorateAuthored(block) {
  const rows = [...block.querySelectorAll(':scope > div')];
  const ul = buildCardList(rows.map((row) => {
    const [imgCell, contentCell] = [...row.querySelectorAll(':scope > div')];
    const img = imgCell.querySelector('img');
    const title = contentCell.querySelector('h2, h3')?.textContent.trim();
    const excerpt = contentCell.querySelector('p:not(:last-child)')?.textContent.trim();
    const link = contentCell.querySelector('a');
    return { img, title, excerpt, href: link?.href, linkText: link?.textContent.trim() };
  }));
  block.replaceChildren(ul);
}

async function decorateDynamic(block) {
  // Parse config
  const rows = [...block.querySelectorAll(':scope > div')];
  const config = {};
  rows.forEach((row) => {
    const [k, v] = [...row.querySelectorAll(':scope > div')];
    config[k.textContent.trim().toLowerCase()] = v.textContent.trim();
  });

  const limit = parseInt(config.limit, 10) || 3;
  const category = config.category || null;

  try {
    const resp = await fetch('/query-index.json');
    const { data } = await resp.json();
    let articles = data.filter((a) => a.template === 'article');
    if (category) articles = articles.filter((a) => a.category === category);
    articles = articles.slice(0, limit);

    const ul = buildCardList(articles.map((a) => ({
      img: null,
      imgSrc: a.image,
      title: a.title,
      excerpt: a.description,
      href: a.path,
      linkText: 'Read more',
    })));
    block.replaceChildren(ul);
  } catch {
    block.textContent = '';
  }
}

function buildCardList(items) {
  const ul = document.createElement('ul');
  ul.className = 'article-cards-list';

  items.forEach(({ img, imgSrc, title, excerpt, href, linkText }) => {
    const li = document.createElement('li');
    li.className = 'article-cards-item';

    const article = document.createElement('article');

    // Image
    const imageDiv = document.createElement('div');
    imageDiv.className = 'article-cards-image';
    if (img) {
      img.loading = 'lazy';
      imageDiv.append(img);
    } else if (imgSrc) {
      const picture = document.createElement('picture');
      const image = document.createElement('img');
      image.src = imgSrc;
      image.alt = '';
      image.loading = 'lazy';
      picture.append(image);
      imageDiv.append(picture);
    }

    const imageLink = document.createElement('a');
    imageLink.href = href;
    imageLink.className = 'article-cards-image-link';
    imageLink.tabIndex = -1;
    imageLink.setAttribute('aria-hidden', 'true');
    imageLink.append(imageDiv);
    article.append(imageLink);

    // Body
    const body = document.createElement('div');
    body.className = 'article-cards-body';

    const h3 = document.createElement('h3');
    h3.className = 'article-cards-title';
    const titleLink = document.createElement('a');
    titleLink.href = href;
    titleLink.textContent = title;
    h3.append(titleLink);
    body.append(h3);

    if (excerpt) {
      const p = document.createElement('p');
      p.className = 'article-cards-excerpt';
      p.textContent = excerpt;
      body.append(p);
    }

    const cta = document.createElement('a');
    cta.href = href;
    cta.className = 'article-cards-cta';
    cta.textContent = linkText || 'Read more';
    cta.setAttribute('aria-label', `Read more about ${title}`);
    body.append(cta);

    article.append(body);
    li.append(article);
    ul.append(li);
  });

  return ul;
}
```

---

## CSS Structure

```css
main .article-cards-list {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
  list-style: none;
  margin: 0 auto;
  padding: 0;
  max-width: var(--max-content-width);
}

@media (width >= 600px) {
  main .article-cards-list {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (width >= 900px) {
  main .article-cards-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

main .article-cards-item article {
  display: flex;
  flex-direction: column;
  height: 100%;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e0e0e0;
}

main .article-cards-image-link {
  display: block;
}

main .article-cards-image img {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
  display: block;
}

main .article-cards-body {
  display: flex;
  flex-direction: column;
  padding: 20px;
  flex: 1;
}

main .article-cards-title {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  margin: 0 0 8px;
}

main .article-cards-title a {
  color: var(--cba-black);
  text-decoration: none;
}

main .article-cards-title a:hover {
  color: var(--cba-link);
  text-decoration: underline;
}

main .article-cards-excerpt {
  font-size: var(--body-font-size-s);
  color: #555;
  flex: 1;
  margin-bottom: 16px;
}

main .article-cards-cta {
  font-size: var(--body-font-size-s);
  font-weight: 600;
  color: var(--cba-link);
  text-decoration: none;
}

main .article-cards-cta:hover {
  text-decoration: underline;
}
```

---

## Universal Editor Fields

```json
{
  "id": "article-cards",
  "fields": [
    {
      "component": "select",
      "name": "variant",
      "label": "Source",
      "options": [
        { "name": "Authored (hardcoded cards)", "value": "" },
        { "name": "Dynamic (from query index)", "value": "dynamic" }
      ]
    }
  ]
}
```

---

## Accessibility

- `<ul>` / `<li>` / `<article>` semantic structure
- Image link is `tabindex="-1"` + `aria-hidden="true"` — title link provides the tab stop
- `aria-label="Read more about [title]"` on CTA — disambiguates multiple "Read more" links
- Images: `loading="lazy"` for below-fold performance; `alt=""` for decorative thumbnails
