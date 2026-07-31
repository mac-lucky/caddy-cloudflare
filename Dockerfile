# Renovate tracks this against caddyserver/caddy releases; a merged bump
# triggers the auto-tag workflow, and the tag builds the release.
ARG CADDY_VERSION=2.11.4

FROM caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http \
    --with github.com/hslatman/caddy-crowdsec-bouncer/crowdsec \
    --with github.com/porech/caddy-maxmind-geolocation

FROM caddy:${CADDY_VERSION}

# The caddy base image (Alpine) lags on curl/libcurl security fixes; upgrade
# them so the image clears the vulnerability gate (CVE-2026-5773, CVE-2026-6276).
RUN apk --no-cache -U upgrade curl libcurl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

LABEL org.opencontainers.image.source="https://github.com/mac-lucky/caddy-cloudflare"
LABEL org.opencontainers.image.description="Caddy with Cloudflare DNS and security plugins"
