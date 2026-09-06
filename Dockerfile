# Renovate tracks this against caddyserver/caddy releases; a merged bump
# triggers the auto-tag workflow, and the tag builds the release.
ARG CADDY_VERSION=2.11.4
# Dependency floors raised at build time because the pinned caddy release and
# the crowdsec bouncer plugin drag in vulnerable versions: x/text v0.37.0
# carries GO-2026-5970 (fixed v0.39.0), grpc v1.81.0 carries
# GHSA-hrxh-6v49-42gf (fixed v1.82.1). Renovate keeps both current, same as
# gocryptfs-docker's XCRYPTO_VERSION.
ARG XTEXT_VERSION=v0.41.0
ARG GRPC_VERSION=v1.83.2

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG XTEXT_VERSION
ARG GRPC_VERSION
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http \
    --with github.com/hslatman/caddy-crowdsec-bouncer/crowdsec \
    --with github.com/porech/caddy-maxmind-geolocation \
    --with golang.org/x/text@${XTEXT_VERSION} \
    --with google.golang.org/grpc@${GRPC_VERSION}

FROM caddy:${CADDY_VERSION}

# The caddy base image (Alpine) lags on package security fixes (curl, libcurl,
# libssl3, c-ares have all been behind at some point); upgrade everything so
# the image clears the vulnerability gate instead of chasing package names.
RUN apk --no-cache -U upgrade

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

LABEL org.opencontainers.image.source="https://github.com/mac-lucky/caddy-cloudflare"
LABEL org.opencontainers.image.description="Caddy with Cloudflare DNS and security plugins"
