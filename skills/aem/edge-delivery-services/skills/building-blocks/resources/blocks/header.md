# Block: `header`

> **Status:** Exists in boilerplate — must be enhanced for CBA
> **Loading phase:** LAZY (loaded in phase 2 after LCP)
> **Category:** Layout & Navigation
> **Legal:** None

Global navigation for commbank.com.au. Includes logo, mega-menu (7 primary sections), authentication navigation (NetBank / CommBiz / CommSec), utility navigation (Locate us, Help & support), and search trigger. Navigation content is authored in a `/nav` document in SharePoint/Google Drive.

---

## CBA Navigation Structure

```
header
├── Logo (CBA yellow diamond + "CommBank" wordmark)
├── Primary nav (7 items with mega-menus)
│   ├── Banking
│   ├── Home Buying
│   ├── Personal Loans
│   ├── Credit Cards
│   ├── Insurance
│   ├── Investing & Super
│   └── Business
├── Utility nav
│   ├── Locate us
│   └── Help & support
├── Auth nav (toggled based on session state)
│   ├── NetBank (existing customers)
│   ├── CommBiz (business banking)
│   └── CommSec (investing)
└── Search button (triggers search overlay)
```

---

## Nav Document Structure (`/nav`)

The `/nav` document in SharePoint/Google Drive drives the header content. EDS fetches `/nav.plain.html` at runtime.

```
(Section 1 — Logo)
[CBA Logo image link](/)

(Section 2 — Navigation)
- Banking
  - Accounts
  - Savings
  - Term deposits
- Home Buying
  - Home loans
  - Investment home loans
  - Refinancing
(... 5 more top-level items)

(Section 3 — Tools / Utility nav)
- [Locate us](/branch-locator)
- [Help & support](/support)

(Section 4 — Auth nav)
- [NetBank](https://www.netbank.com.au/)
- [CommBiz](https://www.commbiz.com.au/)
- [CommSec](https://www.commsec.com.au/)
```

---

## Decorated DOM Structure

```html
<header>
  <div class="header block" data-block-name="header" data-block-status="loaded">
    <nav class="header-nav" aria-label="Main navigation">

      <!-- Logo -->
      <a href="/" class="header-logo" aria-label="CommBank home">
        <img src="/icons/cba-logo.svg" alt="CommBank" width="120" height="40">
      </a>

      <!-- Hamburger (mobile) -->
      <button class="header-nav-toggle" aria-expanded="false" aria-controls="header-nav-menu"
              aria-label="Open navigation menu" type="button">
        <span class="header-nav-toggle-icon" aria-hidden="true"></span>
      </button>

      <!-- Primary navigation -->
      <ul id="header-nav-menu" class="header-nav-list" aria-hidden="false">
        <li class="header-nav-item has-dropdown">
          <button class="header-nav-link" aria-expanded="false" aria-haspopup="true" type="button">
            Banking
            <span class="header-nav-chevron" aria-hidden="true"></span>
          </button>
          <div class="header-nav-dropdown" hidden>
            <ul class="header-nav-sub-list">
              <li><a href="/banking/accounts">Accounts</a></li>
              <li><a href="/banking/savings">Savings</a></li>
            </ul>
          </div>
        </li>
        <!-- 6 more top-level items -->
      </ul>

      <!-- Utility nav -->
      <div class="header-utility">
        <a href="/branch-locator" class="header-utility-link">Locate us</a>
        <a href="/support" class="header-utility-link">Help &amp; support</a>
      </div>

      <!-- Auth nav -->
      <div class="header-auth">
        <a href="https://www.netbank.com.au/" class="header-auth-link header-auth-netbank"
           target="_blank" rel="noopener noreferrer">NetBank</a>
        <a href="https://www.commbiz.com.au/" class="header-auth-link header-auth-commbiz"
           target="_blank" rel="noopener noreferrer">CommBiz</a>
        <a href="https://www.commsec.com.au/" class="header-auth-link header-auth-commsec"
           target="_blank" rel="noopener noreferrer">CommSec</a>
      </div>

      <!-- Search trigger -->
      <button class="header-search-trigger" aria-label="Open search" type="button">
        <span class="icon-search" aria-hidden="true"></span>
      </button>
    </nav>
  </div>
</header>
```

---

## Key JavaScript Behaviours

```javascript
// 1. Fetch /nav and build the DOM structure above
const navHTML = await fetch('/nav.plain.html').then(r => r.text());

// 2. Mega-menu: toggle dropdown on button click + close on outside click / Escape
// 3. Mobile hamburger: toggle aria-expanded + body scroll lock
// 4. Search trigger: dispatch custom event that the search block listens to
headerSearchBtn.addEventListener('click', () => {
  document.dispatchEvent(new CustomEvent('cba:search:open'));
});

// 5. Auth state: check for auth cookie — show/hide CommBiz/CommSec
function checkAuthState() {
  const isAuth = document.cookie.includes('NetBankIdentityToken');
  document.querySelector('.header-auth').classList.toggle('authenticated', isAuth);
}
```

---

## CSS Key Patterns

```css
header {
  position: sticky;
  top: 0;
  z-index: 200;
  background: var(--clr-white);
  border-bottom: 1px solid #e0e0e0;
}

main .header-nav {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 64px;
  max-width: var(--max-content-width);
  margin-inline: auto;
  padding-inline: var(--inline-section-padding);
}

/* Mobile: collapse nav list */
@media (width < 900px) {
  main .header-nav-list {
    position: fixed;
    inset: 64px 0 0;
    background: var(--clr-white);
    overflow-y: auto;
    transform: translateX(-100%);
    transition: transform 0.3s;
  }

  main .header-nav-list.open {
    transform: translateX(0);
  }
}

/* Dropdown */
main .header-nav-dropdown {
  position: absolute;
  top: 64px;
  left: 0;
  background: var(--clr-white);
  box-shadow: 0 8px 24px rgb(0 0 0 / 12%);
  padding: 24px;
  min-width: 200px;
  border-top: 3px solid var(--cba-yellow);
}
```

---

## Universal Editor Fields

The header is a fragment — it has no editable UE fields on individual pages. It is edited via the `/nav` document directly in SharePoint/Google Drive.

---

## CBA-Specific Notes

- Logo: CBA "yellow diamond" SVG + "CommBank" wordmark — stored at `icons/cba-logo.svg`
- Sticky header: `position: sticky; top: 0` — interacts with `in-page-nav` block's own sticky behaviour
- Auth links open in `target="_blank"` — they exit to NetBank, CommBiz, CommSec subdomains
- **Never use `header.classList.add()` from within another block** — header is a global element
- Search is triggered via a custom DOM event (`cba:search:open`) — the `search` block listens for this
- Mobile nav overlay: set `document.body.style.overflow = 'hidden'` when open
