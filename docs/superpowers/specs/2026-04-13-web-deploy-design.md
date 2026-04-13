# Web Deployment Design — Replace Legacy Pomodoro

**Date:** 2026-04-13
**Goal:** Decommission `pomodoro-legacy` (Next.js) hosted at `pomodoro.nyhasinavalona.com` and replace it with the Flutter web build of the current app.

---

## Context

- **Legacy app** (`pomodoro-legacy`): Next.js, Docker container named `pomodoro` on port 3000, Postgres DB on shared VPS Supabase Postgres, NextAuth with GitHub + Google OAuth.
- **New app** (`pomodoro`): Flutter (named "rhythm"), uses Supabase Cloud (`wijowuzerbujsfzcezcl.supabase.co`) for auth and data. Config baked in at build time via dart-defines.
- **Infrastructure**: VPS, Caddy in `vps-services` routes `pomodoro.nyhasinavalona.com → pomodoro:3000`. Reusable `build-image.yml` and `deploy-compose.yml` workflows in `vps-services`.

---

## Architecture

### Static build + nginx container

Flutter web produces a static bundle (`build/web/`). It is served by an nginx container that replaces the legacy Node.js container under the **same container name** (`pomodoro`) and **same port** (3000). This makes the swap transparent to Caddy — no changes to `vps-services`.

### Why not the reusable `build-image.yml`

The reusable workflow does not support Docker `--build-arg`, so dart-defines (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) cannot be injected at image build time through it. The web deploy workflow builds and pushes the image inline instead.

---

## New files in `pomodoro` repo

### `Dockerfile.web`

Multi-stage is unnecessary — Flutter web is built in CI, not in Docker. The Dockerfile simply copies the pre-built `build/web/` into nginx.

```
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
EXPOSE 3000
```

### `nginx.conf`

Listens on port 3000 (matching Caddy's expectation). `try_files` handles Flutter's client-side routing via go_router.

```
server {
    listen 3000;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### `deploy/docker-compose.web.yml`

Same structure as the legacy compose. Container name `pomodoro` ensures Caddy routing is unchanged.

```yaml
services:
  pomodoro:
    container_name: pomodoro
    image: ghcr.io/ny-randriantsarafara/pomodoro-web:latest
    restart: unless-stopped
    networks:
      - vps-net
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:3000 || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 15s

networks:
  vps-net:
    external: true
```

### `.github/workflows/deploy-web.yml`

Triggers on push to `main`. Runs on `ubuntu-latest`.

**Jobs:**

1. **validate** — `flutter pub get && make ci` (`flutter analyze && flutter test`)
2. **build-and-push** (needs validate) — single job: `flutter pub get`, `flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`, then inline `docker/build-push-action` using `Dockerfile.web`. Flutter build and Docker build must be in the same job because `docker build` needs the `build/web/` output on the same runner. Image: `ghcr.io/ny-randriantsarafara/pomodoro-web`, tags `latest` + `sha-<short>`.
3. **deploy** (needs build-and-push) — calls `ny-randriantsarafara/vps-services/.github/workflows/deploy-compose.yml@main` with `compose_file: deploy/docker-compose.web.yml`, `services: pomodoro`

**Required GitHub secrets (new):**
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

**Existing secrets reused:**
- `VPS_USER`, `VPS_HOST`, `VPS_SSH_KEY`, `VPS_HOST_KEY`

### `Makefile` — new target

```makefile
build-web: ## Build Flutter web release
    flutter build web --release --dart-define-from-file=.env
```

---

## Decommission steps

1. **Legacy container** — removed automatically when the new deploy runs (same container name `pomodoro` causes the old one to be stopped and replaced).
2. **Legacy Postgres DB** — left intact on the shared Supabase Postgres as a backup. Do not drop.
3. **Legacy GitHub repo** (`pomodoro-legacy`) — archive (read-only).
4. **Legacy secrets** — `AUTH_SECRET`, `AUTH_GITHUB_ID/SECRET`, `AUTH_GOOGLE_ID/SECRET`, `GH_CONNECTIONS_CLIENT_ID/SECRET`, `DATABASE_URL` in `pomodoro-legacy` repo can be removed when archiving.

---

## Manual steps (outside CI)

1. **Supabase Cloud dashboard** — add `https://pomodoro.nyhasinavalona.com` as an allowed redirect URL under Authentication → URL Configuration.
2. **GitHub** — add secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY` to the `pomodoro` repo.
3. **GitHub** — archive the `pomodoro-legacy` repo.

---

## What does NOT change

- `vps-services` Caddyfile — unchanged (`{$POMODORO_DOMAIN} { reverse_proxy pomodoro:3000 }`)
- `vps-services` docker-compose.yml — unchanged
- `ci.yml` in `pomodoro` repo — mobile CI unchanged, runs independently on `macos-15`
- Supabase Cloud project — no schema or data changes
