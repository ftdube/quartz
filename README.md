# quartz-builder

Fork of [jackyzha0/quartz](https://github.com/jackyzha0/quartz) configured to serve an Obsidian vault as a static site via a Kubernetes CronJob.

See the [upstream documentation](https://quartz.jzhao.xyz/) for Quartz configuration reference.

## Architecture

The image is built by the `build-image.yml` CI workflow and published to GHCR. A CronJob mounts the vault at `/quartz/content` and runs:

```
npx quartz build --output /site
```

The generated site is written to a shared volume served by a web server sidecar.

## Container environment variables

| Variable | Default | Description |
|---|---|---|
| `QUARTZ_PAGE_TITLE` | `Second Brain` | Site title and PWA name |
| `QUARTZ_SHORT_NAME` | `Vault` | PWA short name |
| `QUARTZ_BASE_URL` | `vault.home` | Base URL (no protocol) — set to your actual hostname |

These are substituted into `quartz.config.default.yaml` and `quartz/static/manifest.json` at container startup by `docker-entrypoint.sh`. Override them via CronJob env vars or a Kubernetes Secret.

## How plugin install works

`npx quartz plugin install` runs in the CI workflow on the `ubuntu-latest` runner (where git is available). Plugins are installed to `.quartz/plugins/` and bundled into the image via `COPY . .` in the final Docker stage. The Dockerfile itself has no git dependency.

## Differences from upstream

- No `CMD` in the Dockerfile — the CronJob supplies the build command
- `quartz.config.default.yaml` uses env var placeholders instead of hardcoded values
- Plugin install happens on the CI runner, not inside Docker
- Upstream workflows (Cloudflare Pages deploy, cross-platform CI matrix) removed — all no-ops on a fork
