# SoShop — Multi-tenant SaaS for online bag sellers

A Ruby on Rails 8 + React application where each **Seller** runs an isolated store
with their own Customers, Orders, Payments and Invoices. Customers sign in with
**Facebook Connect**; sellers and administrators use email/password.

## Stack

| Concern            | Choice                                                        |
| ------------------ | ------------------------------------------------------------- |
| Framework          | Ruby on Rails 8.1 (SQLite, Propshaft, esbuild)                 |
| Frontend           | React 19 components mounted in Rails views + Hotwire/Stimulus |
| Auth (Seller/Admin)| Devise (database auth, lockable, trackable, recoverable)      |
| Auth (Customer)    | Devise + `omniauth-facebook` + `omniauth-rails_csrf_protection` |
| Multi-tenancy      | `acts_as_tenant` — row-level scoping by `seller_id`           |
| Authorization      | Pundit                                                        |
| Hardening          | `rack-attack` (throttling), strict CSP, Brakeman, bundler-audit |

## Getting started

```bash
bundle install
npm install
bin/rails db:prepare db:seed
bin/dev          # starts Rails + esbuild --watch (or: npm run build && bin/rails s)
```

### Demo accounts (from `db/seeds.rb`)

| Role   | Email             | Password    |
| ------ | ----------------- | ----------- |
| Admin  | admin@soshop.test | password123 |
| Seller | bella@soshop.test | password123 |
| Seller | urban@soshop.test | password123 |

Customers sign in with Facebook from a storefront, e.g. `http://localhost:3000/s/bella-bags`.

### Facebook Connect (real OAuth)

On every Facebook login the app captures the **Facebook user ID (`uid`)**,
**name**, **email** and **profile picture URL** into the tenant-scoped
`customers` table (`Customer.from_omniauth`).

To enable real Facebook OAuth:

1. Go to <https://developers.facebook.com> → **My Apps → Create App** and add
   the **Facebook Login** product (choose *Web*).
2. In **App settings → Basic**, copy the **App ID** and **App Secret** into
   `.env`:
   ```
   FACEBOOK_APP_ID=1234567890
   FACEBOOK_APP_SECRET=abcdef123456
   ```
3. In **Facebook Login → Settings**, enable *Client OAuth login* and
   *Web OAuth login*, and add the redirect URI:
   ```
   https://your-domain.com/customers/auth/facebook/callback
   ```
   While the Facebook app is in **Development mode**, `http://localhost:3000`
   redirects work automatically without registering them — but only Facebook
   accounts listed under **App roles** (admins/developers/testers) can log in.
   Switch the app to **Live mode** to let anyone log in.
4. Restart the server. The "Continue with Facebook" button now performs the
   real OAuth dialog; `email` and `public_profile` are default permissions and
   need no App Review.

Notes for production: Facebook requires **HTTPS** for redirect URIs in Live
mode, and users can decline the email permission — the app handles a missing
email (the column is nullable) and asks again on the next login
(`auth_type: rerequest`).

**Development without credentials:** if `FACEBOOK_APP_ID` is blank, OmniAuth runs
in mock mode — the "Continue with Facebook" button completes the full login flow
with a simulated Facebook user, so you can demo end-to-end locally.

## Multi-tenancy model

`Seller` is the tenant. `Customer`, `Order`, `Payment`, `Invoice`, `Address` and
`Product` all carry `seller_id` and are guarded by `acts_as_tenant`:

- **Seller area** (`/seller/…`) — tenant set from `current_seller`; every query is
  automatically scoped to their rows.
- **Customer portal** (`/portal/…`) — tenant set from `current_customer.seller`.
- **Storefront** (`/s/:slug`) — public; tenant resolved from the URL slug and the
  slug is threaded through the OmniAuth request phase so the Facebook login lands
  the customer in the right tenant. The same Facebook user gets a separate
  customer record per shop.
- **Admin area** (`/admin/…`) — cross-tenant by design (uses explicit
  `ActsAsTenant.with_tenant` / unscoped queries).

## Feature map

- **Sellers**: email/password sign-in & registration → pending until approved;
  dashboard (new orders, new customers, revenue chart); customers list;
  orders list with payment status; order detail with payments & invoice.
- **Customers**: Facebook Connect (captures uid, name, email, profile picture);
  order history; address book with default address.
- **Admin**: dashboard (latest sellers, active sellers, approval queue,
  platform revenue); sellers list with per-tenant customers; approve /
  enable / disable sellers (disabled sellers are locked out by Devise's
  `active_for_authentication?`).

## Security notes

- OmniAuth request phase is POST-only with CSRF protection
  (`omniauth-rails_csrf_protection`).
- `Rack::Attack` throttles general traffic, login attempts (per IP and per
  email) and password resets.
- Strict Content Security Policy (no inline scripts; see
  `config/initializers/content_security_policy.rb`).
- Devise `lockable` on sellers & admins; disabled sellers can't authenticate.
- Run `bin/brakeman` and `bundle exec bundler-audit check --update` in CI —
  both are clean at the time of writing.
