FROM --platform=$BUILDPLATFORM node:22-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends git openssh-client && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json* .
COPY quartz/ ./quartz/
COPY quartz.lock.json .
RUN npm ci
RUN git clone --depth 1 https://github.com/quartz-community/alias-redirects.git /tmp/plugin-diag && rm -rf /tmp/plugin-diag
RUN npx quartz plugin install

FROM node:22-slim
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/ /usr/src/app/
COPY . .
ENV QUARTZ_PAGE_TITLE="Second Brain"
ENV QUARTZ_SHORT_NAME="Vault"
ENV QUARTZ_BASE_URL="vault.home"
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
