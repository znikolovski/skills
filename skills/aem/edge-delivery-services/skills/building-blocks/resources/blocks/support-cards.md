# Block: `support-cards`

> **Status:** New — must be built
> **Loading phase:** LAZY
> **Category:** Legal & Support
> **Legal:** None

3-column grid of icon + heading + link list. Used on the homepage, product pages, and support pages for "Support & FAQs", "Contact us", and "Locate us" sections.

---

## Content Authoring

```
| Support Cards |
|--------------|
| ![support icon](/icons/cba-support.svg) | ## Support & FAQs
|                                          | [Find answers to common questions](/help)
|                                          | [Security & scams](/security)
|                                          | [Financial hardship assistance](/hardship) |
| ![contact icon](/icons/cba-contact.svg) | ## Contact us
|                                          | [Call 13 22 21](/contact/phone)
|                                          | [Chat online](/chat)
|                                          | [Book an appointment](/appointments) |
| ![locate icon](/icons/cba-locate.svg)   | ## Locate us
|                                          | [Find a branch](/branch-locator)
|                                          | [Find an ATM](/atm-locator) |
```

---

## Initial DOM (before JS)

```html
<div class="support-cards block" data-block-name="support-cards" data-block-status="initialized">
  <div>
    <div><picture><img src="/icons/cba-support.svg" alt="" width="48" height="48"></picture></div>
    <div>
      <h2>Support &amp; FAQs</h2>
      <p><a href="/help">Find answers to common questions</a></p>
      <p><a href="/security">Security &amp; scams</a></p>
      <p><a href="/hardship">Financial hardship assistance</a></p>
    </div>
  </div>
  <!-- 2 more rows -->
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="support-cards block" data-block-name="support-cards" data-block-status="loaded">
  <ul class="support-cards-list">
    <li class="support-cards-item">
      <div class="support-cards-icon" aria-hidden="true">
        <img src="/icons/cba-support.svg" alt="" width="48" height="48">
      </div>
      <div class="support-cards-content">
        <h3 class="support-cards-title">Support &amp; FAQs</h3>
        <ul class="support-cards-links">
          <li><a href="/help">Find answers to common questions</a></li>
          <li><a href="/security">Security &amp; scams</a></li>
          <li><a href="/hardship">Financial hardship assistance</a></li>
        </ul>
      </div>
    </li>
    <!-- 2 more items -->
  </ul>
</div>
```

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const rows = [...block.querySelectorAll(':scope > div')];

  const outerUl = document.createElement('ul');
  outerUl.className = 'support-cards-list';

  rows.forEach((row) => {
    const [iconCell, contentCell] = [...row.querySelectorAll(':scope > div')];
    const li = document.createElement('li');
    li.className = 'support-cards-item';

    // Icon
    const img = iconCell?.querySelector('img');
    if (img) {
      img.alt = '';
      const iconDiv = document.createElement('div');
      iconDiv.className = 'support-cards-icon';
      iconDiv.setAttribute('aria-hidden', 'true');
      iconDiv.append(img);
      li.append(iconDiv);
    }

    const contentDiv = document.createElement('div');
    contentDiv.className = 'support-cards-content';

    const heading = contentCell.querySelector('h2, h3');
    if (heading) {
      const h3 = document.createElement('h3');
      h3.className = 'support-cards-title';
      h3.innerHTML = heading.innerHTML;
      contentDiv.append(h3);
    }

    // Convert <p><a> links to a <ul>
    const links = [...contentCell.querySelectorAll('a')];
    if (links.length) {
      const linkUl = document.createElement('ul');
      linkUl.className = 'support-cards-links';
      links.forEach((link) => {
        const linkLi = document.createElement('li');
        linkLi.append(link);
        linkUl.append(linkLi);
      });
      contentDiv.append(linkUl);
    }

    li.append(contentDiv);
    outerUl.append(li);
  });

  block.replaceChildren(outerUl);
}
```

---

## CSS Structure

```css
main .support-cards {
  padding-inline: var(--inline-section-padding);
  padding-block: 48px;
}

main .support-cards-list {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
  list-style: none;
  margin: 0 auto;
  padding: 0;
  max-width: var(--max-content-width);
}

@media (width >= 600px) {
  main .support-cards-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

main .support-cards-item {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 24px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: var(--clr-white);
}

main .support-cards-icon img {
  width: 48px;
  height: 48px;
  object-fit: contain;
}

main .support-cards-title {
  font-size: var(--body-font-size-m);
  font-weight: 700;
  margin: 0;
  color: var(--cba-black);
}

main .support-cards-links {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

main .support-cards-links a {
  color: var(--cba-link);
  text-decoration: none;
  font-size: var(--body-font-size-s);
}

main .support-cards-links a:hover {
  text-decoration: underline;
}
```

---

## Universal Editor Fields

```json
{
  "id": "support-cards",
  "fields": []
}
```

---

## Accessibility

- Outer `<ul>` + inner `<ul>` nesting is valid for this use case (list of cards, each with a list of links)
- Icons are `aria-hidden="true"` + `alt=""` — card heading provides context
- H3 inside cards (sub-headings under page H2 sections)
