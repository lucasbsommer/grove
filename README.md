# Grove

Project page for **NW Timmerman Rd — Grove Vineyard Access & Infrastructure**.

Served at `grove.lucassommer.com` (local file behind a Cloudflare Tunnel).

## Contents

- `index.html` — **public marketing site** for investors and partners (static,
  no build step, no backend required). Light wine-estate design.
- `ops.html` — the internal project dashboard (permits, checklist, meeting prep,
  county contacts). Gated behind the email magic-code sign-in; links to `/api/*`.

> **Security note on `ops.html`:** the sign-in gate is **client-side only** — it
> hides the content visually but the HTML is still present in the page source
> (View Source / devtools reveal it). For real privacy, the server must refuse to
> serve `ops.html` without a valid `grove_session`, or the sensitive content
> should move behind an authenticated `/api/*` fetch. Treat the current gate as a
> deterrent, not a lock, until the backend enforces it.

## How it runs

`index.html` is a static page, but it calls a **same-origin backend** for its
dynamic features. The Cloudflare Tunnel points `grove.lucassommer.com` at a local
server that serves this page **and** answers the `/api/*` routes below. That
backend is a separate service and is **not** in this repo.

### Backend API the page expects

| Method | Path                 | Purpose                                  |
|--------|----------------------|------------------------------------------|
| POST   | `/api/auth/request`  | Email a 6-digit magic code `{ email }`   |
| POST   | `/api/auth/verify`   | Verify code → `{ token, email }`         |
| GET    | `/api/tasks`         | Checklist / task tracker                 |
| POST   | `/api/*` (writes)    | Authenticated writes, header `X-Grove-Session: <token>` |

Auth is email magic-code; the session token is stored in `localStorage`
(`grove_session`, `grove_email`) — nothing is hardcoded in the page.

### External dependencies (CDN / services)

- Leaflet 1.9.4 + esri-leaflet 3.0.12 (unpkg)
- Google Maps embed
- USGS 3DEP elevation ImageServer
- Washington County, OR GIS (Natural Features) + property records

## Deploy

Architecture is unchanged: the local server serves `index.html` **and** the
`/api/*` backend from one origin, exposed through the Cloudflare Tunnel bound to
`grove.lucassommer.com`. This repo is the source of truth for the **page**; the
server just tracks it with git.

### One-time server setup

Replace the standalone HTML file with a checkout of this repo, and point the
server at the checkout's `index.html`:

```bash
git clone https://github.com/lucasbsommer/grove.git /path/to/grove
cd /path/to/grove
```

### Updating

- **Manual:** `./deploy.sh` — fast-forwards to `origin/main`. Only the static
  page changes; the `/api` process is untouched, so no restart.
- **Automatic:** `./scripts/install-autopull.sh [minutes]` (default every 2 min)
  installs a cron job that runs `deploy.sh`, so pushes to `main` roll out on
  their own. Remove with `./scripts/install-autopull.sh --remove`.

`deploy.sh` honors `GROVE_RELOAD_CMD` if the server ever needs a restart hook,
and `GROVE_BRANCH` to track a branch other than `main`.

> Push-based deploy (GitHub Action → SSH into the box on push) is also possible
> but needs an SSH key/host as repo secrets — ask if you want it instead of the
> cron poll.
