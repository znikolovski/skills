# CBA Block Specifications Index

Individual block specifications for every CBA block in the commbank.com.au migration. Each spec contains:
- DOM structure before and after JS decoration
- JavaScript decoration logic
- CSS class names and responsive patterns
- Universal Editor field schema
- Accessibility requirements
- CBA-specific notes

---

## Sprint 1 — Core Page Structure

| File | Block | Status | Phase |
|------|-------|--------|-------|
| [hero.md](hero.md) | `hero` | Enhance existing | EAGER |
| [announcement-banner.md](announcement-banner.md) | `announcement-banner` | New | EAGER |
| [anchor-tile-nav.md](anchor-tile-nav.md) | `anchor-tile-nav` | New | LAZY |
| [header.md](header.md) | `header` | Enhance existing | LAZY |
| [footer.md](footer.md) | `footer` | Enhance existing | LAZY |

## Sprint 2 — Product Listing Pages (highest traffic)

| File | Block | Status | Phase |
|------|-------|--------|-------|
| [product-card.md](product-card.md) | `product-card` | New | LAZY |
| [rate-display.md](rate-display.md) | `rate-display` | New | LAZY |
| [feature-grid.md](feature-grid.md) | `feature-grid` | New | LAZY |
| [modal-apply.md](modal-apply.md) | `modal-apply` | New | DELAYED |
| [footnotes.md](footnotes.md) | `footnotes` ⚠️ Legal | New | LAZY |

## Sprint 3 — Product Detail Pages

| File | Block | Status | Phase |
|------|-------|--------|-------|
| [in-page-nav.md](in-page-nav.md) | `in-page-nav` | New | LAZY |
| [tabs.md](tabs.md) | `tabs` | Enhance existing | LAZY |
| [accordion.md](accordion.md) | `accordion` | Enhance existing | LAZY |
| [step-process.md](step-process.md) | `step-process` | New | LAZY |
| [rates-fees-table.md](rates-fees-table.md) | `rates-fees-table` | New | LAZY |

## Sprint 4 — Content & Discovery

| File | Block | Status | Phase |
|------|-------|--------|-------|
| [article-cards.md](article-cards.md) | `article-cards` | New | LAZY |
| [promo-offer-banner.md](promo-offer-banner.md) | `promo-offer-banner` | New | LAZY |
| [partner-block.md](partner-block.md) | `partner-block` | New | LAZY |
| [support-cards.md](support-cards.md) | `support-cards` | New | LAZY |
| [app-download.md](app-download.md) | `app-download` | New | LAZY |
| [featured-content.md](featured-content.md) | `featured-content` | New | LAZY |

## Sprint 5 — Section-Specific

| File | Block | Status | Phase |
|------|-------|--------|-------|
| [rate-calculator.md](rate-calculator.md) | `rate-calculator` | New | LAZY + IntersectionObserver |
| [newsroom-listing.md](newsroom-listing.md) | `newsroom-listing` | New | LAZY |
| [loyalty-tiers.md](loyalty-tiers.md) | `loyalty-tiers` | New | LAZY |
| [contact-form.md](contact-form.md) | `contact-form` | New | LAZY |

---

## ⚠️ Legal Flags

- `footnotes` — Required on ALL CBA product pages (home loans, credit cards, savings, insurance, investing)
- `rate-display` — Always paired with comparison rate footnote in `footnotes` block
- `rates-fees-table` — Rate values with `[*]` must resolve to footnote definitions
- `partner-block` — "Provided by [Partner]" attribution required
- `modal-apply` — `mobile-app-redirect.commbank.com.au` URLs must not be modified
- `footer` — Acknowledgement of Country is mandatory

---

## DOM Structure Quick Reference

### EDS Table → HTML mapping

When EDS converts an authored table to HTML, the structure is:

```
Author table:
| Block Name [variant] |
|---------------------|
| cell (0,0) | cell (0,1) |
| cell (1,0) | cell (1,1) |

Resulting HTML:
<div class="block-name variant block">
  <div>  ← row 0
    <div>cell (0,0)</div>
    <div>cell (0,1)</div>
  </div>
  <div>  ← row 1
    <div>cell (1,0)</div>
    <div>cell (1,1)</div>
  </div>
</div>
```

Cell content is wrapped in appropriate inline elements:
- Text → `<p>`
- Headings → `<h1>–<h6>`
- Lists → `<ul>/<ol>/<li>`
- Images → `<picture><source><img>`
- Links → `<a>` (CTA-looking links also get `.button` class from `decorateButtons()`)
