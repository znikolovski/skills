# Block: `footer`

> **Status:** Exists in boilerplate — must be enhanced for CBA structure
> **Loading phase:** LAZY (loaded in phase 2)
> **Category:** Layout & Navigation
> **Legal:** Acknowledgement of Country is mandatory — never remove

Global footer for commbank.com.au. Three-column link grid + secondary nav + legal text + Acknowledgement of Country. Content authored in a `/footer` document in SharePoint/Google Drive.

---

## CBA Footer Structure

```
footer
├── Primary columns (3-col grid, desktop)
│   ├── Col 1: Banking
│   │   ├── Home Loans
│   │   ├── Credit Cards
│   │   ├── Savings
│   │   └── Personal Loans
│   ├── Col 2: Business
│   │   ├── Business accounts
│   │   ├── Business loans
│   │   └── Business credit cards
│   └── Col 3: Help & Support
│       ├── Help Centre
│       ├── Contact us
│       ├── Branch locator
│       └── ATM locator
│
├── Secondary nav (horizontal)
│   ├── Privacy Policy
│   ├── Security
│   ├── Terms of Use
│   ├── Sitemap
│   └── Accessibility
│
├── Legal text
│   └── "Commonwealth Bank of Australia ABN 48 123 123 124 AFSL and Australian credit licence 234945"
│
└── Acknowledgement of Country
    └── "Commonwealth Bank acknowledges the Traditional Custodians of the lands..."
```

---

## Footer Document (`/footer`)

```
(Section 1 — Link columns)
## Banking
- [Home Loans](/home-loans)
- [Credit Cards](/credit-cards)
- [Savings](/savings)

## Business
- [Business accounts](/business/accounts)
- [Business loans](/business/lending)

## Help & Support
- [Help Centre](/support)
- [Contact us](/contact)

(Section 2 — Secondary nav)
- [Privacy Policy](/privacy)
- [Security](/security)
- [Terms of Use](/terms)

(Section 3 — Legal text)
Commonwealth Bank of Australia ABN 48 123 123 124 AFSL and Australian credit licence 234945.

(Section 4 — Acknowledgement of Country)
Commonwealth Bank acknowledges the Traditional Custodians of the lands across Australia on which we work and live. We pay our respects to Elders past and present.
```

---

## Decorated DOM Structure

```html
<footer>
  <div class="footer block" data-block-name="footer" data-block-status="loaded">
    <!-- Primary link columns -->
    <div class="footer-columns">
      <div class="footer-column">
        <h3 class="footer-column-title">Banking</h3>
        <ul class="footer-column-list">
          <li><a href="/home-loans">Home Loans</a></li>
          <li><a href="/credit-cards">Credit Cards</a></li>
        </ul>
      </div>
      <!-- 2 more columns -->
    </div>

    <!-- Secondary nav -->
    <nav class="footer-secondary-nav" aria-label="Legal and policies">
      <ul class="footer-secondary-list">
        <li><a href="/privacy">Privacy Policy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/terms">Terms of Use</a></li>
        <li><a href="/sitemap">Sitemap</a></li>
        <li><a href="/accessibility">Accessibility</a></li>
      </ul>
    </nav>

    <!-- Legal text -->
    <div class="footer-legal">
      <p>Commonwealth Bank of Australia ABN 48 123 123 124 AFSL and Australian credit licence 234945.</p>
    </div>

    <!-- Acknowledgement of Country — MANDATORY, never remove -->
    <div class="footer-acknowledgement" lang="en-AU">
      <p>Commonwealth Bank acknowledges the Traditional Custodians of the lands across Australia on which we work and live. We pay our respects to Elders past and present.</p>
    </div>
  </div>
</footer>
```

---

## CSS Key Patterns

```css
footer {
  background: var(--cba-dark-blue);
  color: var(--clr-white);
  padding-block: 48px;
  padding-inline: var(--inline-section-padding);
}

main .footer-columns {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
  max-width: var(--max-content-width);
  margin-inline: auto;
  margin-bottom: 40px;
}

@media (width >= 600px) {
  main .footer-columns { grid-template-columns: repeat(3, 1fr); }
}

main .footer-column-title {
  font-size: var(--body-font-size-s);
  font-weight: 700;
  color: var(--clr-white);
  margin-bottom: 16px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

main .footer-column-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

main .footer-column-list a {
  color: rgb(255 255 255 / 80%);
  text-decoration: none;
  font-size: var(--body-font-size-s);
}

main .footer-column-list a:hover {
  color: var(--clr-white);
  text-decoration: underline;
}

main .footer-secondary-list {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0 0 24px;
  gap: 0;
  flex-wrap: wrap;
}

main .footer-secondary-list li:not(:last-child)::after {
  content: '|';
  margin-inline: 12px;
  color: rgb(255 255 255 / 40%);
}

main .footer-secondary-list a {
  color: rgb(255 255 255 / 80%);
  font-size: var(--body-font-size-xs);
  text-decoration: none;
}

main .footer-legal p {
  font-size: var(--body-font-size-xs);
  color: rgb(255 255 255 / 60%);
  margin-bottom: 16px;
}

main .footer-acknowledgement {
  border-top: 1px solid rgb(255 255 255 / 20%);
  padding-top: 24px;
  margin-top: 24px;
}

main .footer-acknowledgement p {
  font-size: var(--body-font-size-xs);
  color: rgb(255 255 255 / 60%);
  font-style: italic;
}
```

---

## CBA-Specific Notes

- **Acknowledgement of Country is mandatory** — never remove it, never shorten the text
- Footer background is `var(--cba-dark-blue)` (near-black navy) — not the CBA yellow
- ABN and AFSL number must appear verbatim: "ABN 48 123 123 124 AFSL and Australian credit licence 234945"
- The footer is a fragment — edited via the `/footer` document in SharePoint/Google Drive
- Social media links (LinkedIn, Twitter/X, Facebook, YouTube, Instagram) may appear in a 4th column — these open in `target="_blank"` with `rel="noopener noreferrer"`
