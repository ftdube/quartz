# quartz-builder

Fork of jackyzha0/quartz. Serves an Obsidian vault as a static site via a k3s CronJob.

## Hard rules

- Never commit vault content — injected at build time by CronJob mounting `/quartz/content`
- Never hardcode personal domains, IPs, hostnames, or usernames in any committed file
- Never commit NAS URLs, SSH keys, or Tailscale hostnames — injected via K8s secrets/env vars at runtime
- Use `build-image.yml` and `ci.yaml`; all other upstream workflows have been deleted (they were no-ops gated to `jackyzha0/quartz`)

## Non-obvious gotchas

- Config is `quartz.config.default.yaml` (YAML), not a TypeScript file
- `Dockerfile` has no `CMD` — the CronJob provides the build command (`npx quartz build --output /site`)
- TS errors in `Head.tsx` on cold checkout are expected; they resolve after `npm install` + a build (missing generated `.quartz/plugins` module)
- `pageTitle` and `baseUrl` in the config use `${QUARTZ_PAGE_TITLE}` / `${QUARTZ_BASE_URL}` placeholders — substituted at container startup via `docker-entrypoint.sh` using `envsubst`; defaults are set as `ENV` in the Dockerfile; override via CronJob env vars
- `baseUrl` default is `vault.home` — override with actual Tailscale hostname once known
- `npx quartz plugin install` runs in the CI workflow on the ubuntu-latest runner (where git is available), not inside Docker — plugins land in `.quartz/plugins/` and enter the image via `COPY . .` in the final stage; the Dockerfile itself has no git dependency
- Upstream's Dockerfile also runs `npx quartz plugin install` but silently fails because `node:22-slim` ships without git; errors are swallowed in the catch block of `plugin-git-handlers.js`
- `.quartz/plugins/` is gitignored — it is populated by the CI runner and passed into Docker via the build context
