# Grove

Project page for **NW Timmerman Rd — Grove Vineyard Access & Infrastructure**.

Served at `grove.lucassommer.com` (local file behind a Cloudflare Tunnel).

## Contents

- `index.html` — the full single-file frontend (styles + JS inline). No build step.

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

Serve `index.html` from the same origin as the `/api/*` backend, and expose
that origin through the Cloudflare Tunnel bound to `grove.lucassommer.com`.
