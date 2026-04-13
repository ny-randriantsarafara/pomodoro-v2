# Web Deploy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the legacy Next.js pomodoro app at `pomodoro.nyhasinavalona.com` with a Flutter web build served by nginx, with full CI/CD on push to `main`.

**Architecture:** `flutter build web` produces a static bundle baked into an nginx Docker image (`pomodoro-web`). The container replaces the legacy `pomodoro` container at the same VPS deploy dir (`/home/deploy/apps/pomodoro`), so Docker Compose handles the cutover and Caddy routing stays unchanged. The `deploy-web.yml` workflow builds on `ubuntu-latest`, writes `.env` from existing GitHub secrets, and calls the reusable `deploy-compose.yml` from `vps-services`.

**Tech Stack:** Flutter web, nginx:alpine, Docker, GitHub Actions, reusable `vps-services` workflows (`deploy-compose.yml`)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `.github/workflows/ci.yml` | Modify | Add `paths-ignore` — skip iOS/macOS builds for web-only changes |
| `nginx.conf` | Create | Custom nginx config: port 3000, Flutter SPA routing |
| `Dockerfile.web` | Create | Copy pre-built `build/web/` into nginx:alpine |
| `deploy/docker-compose.web.yml` | Create | VPS compose for the nginx container |
| `Makefile` | Modify | Add `build-web` target |
| `.github/workflows/deploy-web.yml` | Create | Full CI/CD: validate → build web → push image → deploy |

---

## Task 1: Guard `ci.yml` against web-only pushes

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Add `paths-ignore` to the push trigger**

Open `.github/workflows/ci.yml`. The current `on:` block is:

```yaml
on:
  push:
    branches: ['**']
```

Replace it with:

```yaml
on:
  push:
    branches: ['**']
    paths-ignore:
      - 'deploy/**'
      - 'Dockerfile.web'
      - 'nginx.conf'
      - '.github/workflows/deploy-web.yml'
      - 'docs/**'
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: skip mobile builds for web-only file changes"
```

---

## Task 2: nginx config + Dockerfile

**Files:**
- Create: `nginx.conf`
- Create: `Dockerfile.web`

- [ ] **Step 1: Create `nginx.conf`**

```nginx
server {
    listen 3000;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

`try_files` serves existing files (JS, CSS, assets), falling back to `index.html` for all Flutter client-side routes (go_router).

- [ ] **Step 2: Create `Dockerfile.web`**

```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
EXPOSE 3000
```

The `build/web` directory is produced by `flutter build web` in CI before `docker build` runs — it is not built inside Docker.

- [ ] **Step 3: Verify locally**

Run from the repo root (requires `.env` with `SUPABASE_URL` and `SUPABASE_ANON_KEY`):

```bash
flutter build web --release --dart-define-from-file=.env
docker build -f Dockerfile.web -t pomodoro-web-test .
docker run --rm -d -p 3000:3000 --name pomodoro-web-test pomodoro-web-test
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

Expected: `200`

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/nonexistent/route
```

Expected: `200` (Flutter SPA fallback — go_router handles 404 client-side)

```bash
docker stop pomodoro-web-test
```

- [ ] **Step 4: Commit**

```bash
git add nginx.conf Dockerfile.web
git commit -m "feat: add nginx config and Dockerfile for Flutter web"
```

---

## Task 3: Compose file + Makefile

**Files:**
- Create: `deploy/docker-compose.web.yml`
- Modify: `Makefile`

- [ ] **Step 1: Create `deploy/docker-compose.web.yml`**

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

Container name `pomodoro` matches the Caddy routing rule (`reverse_proxy pomodoro:3000`) — no Caddy changes needed. Deploying to the same `deploy_dir` as the legacy (`/home/deploy/apps/pomodoro`) lets Docker Compose recognise and replace the old container via its compose labels.

- [ ] **Step 2: Add `build-web` target to `Makefile`**

Open `Makefile`. Add after the `ci:` target:

```makefile
build-web: ## Build Flutter web release
	flutter build web --release --dart-define-from-file=.env
```

(Indentation must be a tab, not spaces.)

- [ ] **Step 3: Commit**

```bash
git add deploy/docker-compose.web.yml Makefile
git commit -m "feat: add web compose file and Makefile target"
```

---

## Task 4: `deploy-web.yml` workflow

**Files:**
- Create: `.github/workflows/deploy-web.yml`

- [ ] **Step 1: Create `.github/workflows/deploy-web.yml`**

```yaml
name: Deploy Web

on:
  push:
    branches: [main]

permissions:
  contents: read
  packages: write

jobs:
  validate:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Get dependencies
        run: flutter pub get

      - name: Analyze & Test
        run: make ci

  build-and-push:
    name: Build web & push image
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Get dependencies
        run: flutter pub get

      - name: Write .env
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
        run: |
          printf '%s\n' \
            "SUPABASE_URL=$SUPABASE_URL" \
            "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" \
            > .env

      - name: Build Flutter web
        run: flutter build web --release --dart-define-from-file=.env

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build & push image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: Dockerfile.web
          push: true
          tags: |
            ghcr.io/ny-randriantsarafara/pomodoro-web:sha-${{ github.sha }}
            ghcr.io/ny-randriantsarafara/pomodoro-web:latest

  deploy:
    name: Deploy to VPS
    needs: build-and-push
    uses: ny-randriantsarafara/vps-services/.github/workflows/deploy-compose.yml@main
    with:
      deploy_dir: /home/deploy/apps/pomodoro
      compose_file: deploy/docker-compose.web.yml
      services: pomodoro
      runtime_env: "APP_ENV=production"
      health_retries: 15
      health_interval: 5
    secrets:
      vps_user_secret: ${{ secrets.VPS_USER }}
      vps_host_secret: ${{ secrets.VPS_HOST }}
      vps_ssh_key: ${{ secrets.VPS_SSH_KEY }}
      vps_host_key: ${{ secrets.VPS_HOST_KEY }}
```

**Notes:**
- `runtime_env: "APP_ENV=production"` is required because `deploy-compose.yml` fails if `.env` would be empty. The nginx container ignores it. This **overwrites** the legacy NextAuth `.env` at `/home/deploy/apps/pomodoro/.env` — that's intentional, the legacy is being decommissioned.
- `deploy_dir: /home/deploy/apps/pomodoro` is the same as the legacy — Docker Compose uses project labels to recognise and replace the old container cleanly.
- `sha-${{ github.sha }}` produces a unique immutable tag per commit alongside `latest`.

- [ ] **Step 2: Commit and push to trigger first deploy**

```bash
git add .github/workflows/deploy-web.yml
git commit -m "feat: add web deploy workflow"
git push
```

- [ ] **Step 3: Watch the Actions run**

Open `https://github.com/ny-randriantsarafara/pomodoro/actions` and confirm:
1. `validate` passes (flutter analyze + test)
2. `build-and-push` passes (image pushed to GHCR)
3. `deploy` passes (container healthy on VPS)

- [ ] **Step 4: Smoke-test the live site**

```bash
curl -s -o /dev/null -w "%{http_code}" https://pomodoro.nyhasinavalona.com
```

Expected: `200`

```bash
curl -s -o /dev/null -w "%{http_code}" https://pomodoro.nyhasinavalona.com/nonexistent
```

Expected: `200` (Flutter SPA fallback)

---

## Task 5: Manual steps

These are done once, outside CI.

- [ ] **Step 1: Add redirect URL in Supabase Cloud**

1. Go to [supabase.com](https://supabase.com) → project `wijowuzerbujsfzcezcl`
2. Navigate to **Authentication → URL Configuration**
3. Under **Redirect URLs**, add: `https://pomodoro.nyhasinavalona.com/**`
4. Save

This allows OAuth sign-in flows (GitHub, Google) to redirect back to the web app.

- [ ] **Step 2: Archive the legacy repo**

1. Go to `https://github.com/ny-randriantsarafara/pomodoro-legacy`
2. **Settings → Danger Zone → Archive this repository**
3. Confirm

The legacy container was already replaced by the deploy in Task 4. The Postgres `pomodoro` database stays on the VPS untouched.
