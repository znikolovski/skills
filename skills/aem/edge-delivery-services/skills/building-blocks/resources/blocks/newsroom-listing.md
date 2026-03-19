# Block: `newsroom-listing`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Content & Education
> **Legal:** None

Article card grid with category filter navigation and load-more pagination. Used on the main newsroom listing page (`/articles/newsroom/`) and category-filtered views. Fetches articles from `/query-index.json`.

---

## Content Authoring (Configuration pattern)

```
| Newsroom Listing |
|-----------------|
| limit | 12 |
| sort | date-desc |
| categories | Media Releases, Company News, Community, Product Updates |
```

---

## Initial DOM (before JS)

```html
<div class="newsroom-listing block" data-block-name="newsroom-listing" data-block-status="initialized">
  <div><div><p>limit</p></div><div><p>12</p></div></div>
  <div><div><p>sort</p></div><div><p>date-desc</p></div></div>
  <div><div><p>categories</p></div><div><p>Media Releases, Company News, Community, Product Updates</p></div></div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="newsroom-listing block" data-block-name="newsroom-listing" data-block-status="loaded">
  <!-- Category filter nav -->
  <nav class="newsroom-listing-filters" aria-label="Filter by category">
    <ul class="newsroom-listing-filter-list">
      <li><button type="button" class="newsroom-listing-filter active" data-category="all" aria-pressed="true">All</button></li>
      <li><button type="button" class="newsroom-listing-filter" data-category="media-releases" aria-pressed="false">Media Releases</button></li>
      <li><button type="button" class="newsroom-listing-filter" data-category="company-news" aria-pressed="false">Company News</button></li>
      <li><button type="button" class="newsroom-listing-filter" data-category="community" aria-pressed="false">Community</button></li>
      <li><button type="button" class="newsroom-listing-filter" data-category="product-updates" aria-pressed="false">Product Updates</button></li>
    </ul>
  </nav>

  <!-- Article grid -->
  <ul class="newsroom-listing-grid" aria-live="polite">
    <li class="newsroom-listing-item">
      <article>
        <a href="/articles/newsroom/2026/03/commbank-q2-results" class="newsroom-listing-image-link" aria-hidden="true" tabindex="-1">
          <img src="/articles/newsroom/2026/03/commbank-q2-results-thumbnail.jpg" alt="" loading="lazy" width="400" height="225">
        </a>
        <div class="newsroom-listing-body">
          <p class="newsroom-listing-category">Media Releases</p>
          <h3 class="newsroom-listing-title">
            <a href="/articles/newsroom/2026/03/commbank-q2-results">CommBank Q2 Results 2026</a>
          </h3>
          <p class="newsroom-listing-date"><time datetime="2026-03-14">14 March 2026</time></p>
          <p class="newsroom-listing-excerpt">Commonwealth Bank today announced its Q2 2026 results...</p>
        </div>
      </article>
    </li>
    <!-- more items -->
  </ul>

  <!-- Load more -->
  <div class="newsroom-listing-more">
    <button type="button" class="button secondary newsroom-listing-load-more">Load more</button>
    <p class="newsroom-listing-count" aria-live="polite">Showing 12 of 48 articles</p>
  </div>
</div>
```

---

## JavaScript Decoration (outline)

```javascript
export default async function decorate(block) {
  const config = parseConfig(block);
  const limit = parseInt(config.limit, 10) || 12;
  const categories = config.categories?.split(',').map((c) => c.trim()) || [];

  // Check URL for active category filter (?category=media-releases)
  const urlParams = new URLSearchParams(window.location.search);
  let activeCategory = urlParams.get('category') || 'all';

  // Fetch all articles from query index
  let allArticles = [];
  try {
    const { data } = await fetch('/query-index.json').then((r) => r.json());
    allArticles = data
      .filter((a) => a.template === 'article')
      .sort((a, b) => (config.sort === 'date-desc' ? b.date - a.date : a.date - b.date));
  } catch {
    block.textContent = '';
    return;
  }

  // Build filter nav
  const filterNav = buildFilterNav(['all', ...categories], activeCategory, (category) => {
    activeCategory = category;
    // Update URL without reload
    const url = new URL(window.location);
    if (category === 'all') url.searchParams.delete('category');
    else url.searchParams.set('category', category);
    window.history.pushState({}, '', url);
    renderGrid(block, getFilteredArticles(allArticles, activeCategory), limit);
  });

  block.replaceChildren(filterNav);
  renderGrid(block, getFilteredArticles(allArticles, activeCategory), limit);
}

function getFilteredArticles(articles, category) {
  if (category === 'all') return articles;
  return articles.filter((a) => slugify(a.category) === category);
}

function slugify(str) {
  return str.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}
```

---

## CSS Structure

```css
main .newsroom-listing-filter-list {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0 0 32px;
  gap: 8px;
  flex-wrap: wrap;
}

main .newsroom-listing-filter {
  padding: 8px 16px;
  border: 1px solid #ccc;
  border-radius: 100px;
  background: var(--clr-white);
  font-size: var(--body-font-size-s);
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

main .newsroom-listing-filter.active,
main .newsroom-listing-filter[aria-pressed="true"] {
  background: var(--cba-yellow);
  border-color: var(--cba-yellow);
  font-weight: 700;
}

main .newsroom-listing-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
  list-style: none;
  padding: 0;
  margin: 0;
}

@media (width >= 600px) {
  main .newsroom-listing-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (width >= 900px) {
  main .newsroom-listing-grid { grid-template-columns: repeat(3, 1fr); }
}

main .newsroom-listing-image-link img {
  width: 100%;
  aspect-ratio: 16/9;
  object-fit: cover;
  border-radius: 8px 8px 0 0;
}

main .newsroom-listing-body {
  padding: 16px;
}

main .newsroom-listing-category {
  font-size: var(--body-font-size-xs);
  text-transform: uppercase;
  color: var(--cba-link);
  font-weight: 600;
  margin-bottom: 8px;
}

main .newsroom-listing-title {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  margin: 0 0 8px;
}

main .newsroom-listing-date {
  font-size: var(--body-font-size-xs);
  color: #888;
  margin-bottom: 8px;
}

main .newsroom-listing-more {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  margin-top: 40px;
}
```

---

## Universal Editor Fields

```json
{
  "id": "newsroom-listing",
  "fields": [
    { "component": "number", "name": "limit", "label": "Articles per page (default: 12)" },
    { "component": "select", "name": "sort", "label": "Sort order",
      "options": [
        { "name": "Newest first", "value": "date-desc" },
        { "name": "Oldest first", "value": "date-asc" }
      ]
    },
    { "component": "text", "name": "categories", "label": "Category filters (comma-separated)" }
  ]
}
```

---

## CBA-Specific Notes

- URL param `?category=media-releases` is set when a filter is active — share-able URL
- Article page URL pattern: `/articles/newsroom/[year]/[month]/[slug].html`
- Query index must include these fields: `path`, `title`, `description`, `image`, `date`, `category`, `template`
- Load-more appends articles to the grid (no full-page reload) — `aria-live="polite"` announces the count change
