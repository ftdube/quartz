# quartz-builder

Fork of jackyzha0/quartz. Serves an Obsidian vault as a static site via a k3s CronJob.

## Hard rules

- Never commit vault content — injected at build time by CronJob mounting `/quartz/content`
- Never hardcode personal domains, IPs, hostnames, or usernames in any committed file
- Never commit NAS URLs, SSH keys, or Tailscale hostnames — injected via K8s secrets/env vars at runtime
- Use `build-image.yml` for CI; `docker-build-push.yaml` is gated to the upstream repo owner and will not run on this fork

## Non-obvious gotchas

- Config is `quartz.config.default.yaml` (YAML), not a TypeScript file
- `Dockerfile` has no `CMD` — the CronJob provides the build command (`npx quartz build --output /site`)
- TS errors in `Head.tsx` on cold checkout are expected; they resolve after `npm install` + a build (missing generated `.quartz/plugins` module)
- `pageTitle` and `baseUrl` in the config use `${QUARTZ_PAGE_TITLE}` / `${QUARTZ_BASE_URL}` placeholders — substituted at container startup via `docker-entrypoint.sh` using `envsubst`; defaults are set as `ENV` in the Dockerfile; override via CronJob env vars
- `baseUrl` default is `vault.home` — override with actual Tailscale hostname once known
