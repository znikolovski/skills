# Block: `in-page-nav`

> **Status:** New — must be built
> **Loading phase:** LAZY (becomes sticky on scroll)
> **Category:** Layout & Navigation
> **Legal:** None

Sticky horizontal anchor link navigation for product detail pages. Contains 4–6 text links to sections within the same page: "At a glance", "Awards program", "Rates & fees", "FAQs", "Support". Sticks to the top of the viewport when scrolled past.

---

## Content Authoring

```
| In Page Nav |
|------------|
| [At a glance](#glance) | [Awards program](#awards) | [Rates & fees](#rates) | [FAQs](#faqs) | [Support](#support) |
```

Single row, multiple cells — each cell is one nav link. Unlike `anchor-tile-nav`, no icons are used.

---

## Initial DOM (before JS)

```html
<div class="in-page-nav block" data-block-name="in-page-nav" data-block-status="initialized">
  <div>
    <div><p><a href="#glance">At a glance</a></p></div>
    <div><p><a href="#awards">Awards program</a></p></div>
    <div><p><a href="#rates">Rates &amp; fees</a></p></div>
    <div><p><a href="#faqs">FAQs</a></p></div>
    <div><p><a href="#support">Support</a></p></div>
  </div>
</div>
```

---

## Decorated DOM (after JS)

```html
<div class="in-page-nav block" data-block-name="in-page-nav" data-block-status="loaded">
  <nav class="in-page-nav-inner" aria-label="On this page">
    <ul class="in-page-nav-list">
      <li><a href="#glance" class="in-page-nav-link active" aria-current="true">At a glance</a></li>
      <li><a href="#awards" class="in-page-nav-link">Awards program</a></li>
      <li><a href="#rates" class="in-page-nav-link">Rates &amp; fees</a></li>
      <li><a href="#faqs" class="in-page-nav-link">FAQs</a></li>
      <li><a href="#support" class="in-page-nav-link">Support</a></li>
    </ul>
  </nav>
</div>
```

When scrolled past: `block.classList.add('sticky')`

---

## JavaScript Decoration

```javascript
export default async function decorate(block) {
  const [row] = block.querySelectorAll(':scope > div');
  const cells = [...row.querySelectorAll(':scope > div')];

  const nav = document.createElement('nav');
  nav.className = 'in-page-nav-inner';
  nav.setAttribute('aria-label', 'On this page');

  const ul = document.createElement('ul');
  ul.className = 'in-page-nav-list';

  cells.forEach((cell) => {
    const link = cell.querySelector('a');
    if (!link) return;
    const li = document.createElement('li');
    link.className = 'in-page-nav-link';
    li.append(link);
    ul.append(li);
  });

  nav.append(ul);
  block.replaceChildren(nav);

  // Sticky behaviour
  const navOffset = block.offsetTop;
  window.addEventListener('scroll', () => {
    block.classList.toggle('sticky', window.scrollY > navOffset);
  }, { passive: true });

  // Active link tracking via IntersectionObserver
  const links = [...ul.querySelectorAll('a[href^="#"]')];
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const id = entry.target.id;
      const link = ul.querySelector(`a[href="#${id}"]`);
      if (!link) return;
      if (entry.isIntersecting) {
        links.forEach((l) => {
          l.classList.remove('active');
          l.removeAttribute('aria-current');
        });
        link.classList.add('active');
        link.setAttribute('aria-current', 'true');
      }
    });
  }, { threshold: 0.4 });

  links.forEach((link) => {
    const target = document.getElementById(link.hash.slice(1));
    if (target) observer.observe(target);
  });
}
```

---

## CSS Structure

```css
main .in-page-nav {
  background: var(--clr-white);
  border-bottom: 1px solid #e0e0e0;
  z-index: 100;
}

main .in-page-nav.sticky {
  position: sticky;
  top: 0;
  box-shadow: 0 2px 8px rgb(0 0 0 / 12%);
}

main .in-page-nav-inner {
  max-width: var(--max-content-width);
  margin-inline: auto;
  padding-inline: var(--inline-section-padding);
  overflow-x: auto;
  scrollbar-width: none;
}

main .in-page-nav-inner::-webkit-scrollbar {
  display: none;
}

main .in-page-nav-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 0;
  white-space: nowrap;
}

main .in-page-nav-link {
  display: block;
  padding: 16px 20px;
  color: var(--cba-black);
  text-decoration: none;
  font-size: var(--body-font-size-s);
  border-bottom: 3px solid transparent;
  transition: border-color 0.2s, color 0.2s;
}

main .in-page-nav-link:hover {
  color: var(--cba-link);
  border-bottom-color: var(--cba-yellow);
}

main .in-page-nav-link.active {
  font-weight: 700;
  border-bottom-color: var(--cba-yellow);
}
```

---

## Universal Editor Fields

```json
{
  "id": "in-page-nav",
  "fields": []
}
```

Note: All nav items are authored as cells in the single content row. No separate UE field schema needed — the table structure drives the links.

---

## Accessibility

- `<nav aria-label="On this page">` creates a navigable landmark distinct from the global `<header>` nav
- `aria-current="true"` on the active link (updated by JS as user scrolls)
- Keyboard: Tab through links, Enter to activate
- Horizontal scroll on mobile: keyboard-accessible via arrow keys if `tabindex` set on scroll container
