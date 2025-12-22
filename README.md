# Caddy with Cloudflare DNS & Security Plugins

[![Docker Pulls](https://img.shields.io/docker/pulls/maclucky/caddy-cloudflare)](https://hub.docker.com/r/maclucky/caddy-cloudflare)
[![Docker Image Version](https://img.shields.io/docker/v/maclucky/caddy-cloudflare/latest)](https://hub.docker.com/r/maclucky/caddy-cloudflare/tags)
[![GitHub Actions Workflow Status](https://github.com/mac-lucky/caddy-cloudflare/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mac-lucky/caddy-cloudflare/actions/workflows/docker-image.yml)
[![Platform](https://img.shields.io/badge/platform-amd64%20%7C%20arm64-blue)](https://github.com/mac-lucky/caddy-cloudflare/pkgs/container/caddy-cloudflare)

This Docker image extends the official Caddy server with Cloudflare DNS plugin and comprehensive security plugins for protection against hackers, bots, and malicious traffic.

## Features

- Based on official Caddy server
- Multi-architecture support (linux/amd64, linux/arm64)
- **Cloudflare DNS** - Automated DNS-01 challenge for wildcard certificates
- **Rate Limiting** - Protection against brute force and DDoS attacks
- **CrowdSec Bouncer** - Community-driven threat intelligence
- **GeoIP Blocking** - Block requests by country
- **AI/Cloud Defender** - Block AI scrapers and cloud service IPs

## Included Plugins

| Plugin | Purpose |
|--------|---------|
| [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) | DNS-01 ACME challenge via Cloudflare |
| [mholt/caddy-ratelimit](https://github.com/mholt/caddy-ratelimit) | Sliding window rate limiting |
| [hslatman/caddy-crowdsec-bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) | CrowdSec integration |
| [porech/caddy-maxmind-geolocation](https://github.com/porech/caddy-maxmind-geolocation) | GeoIP-based filtering |
| [JasonLovesDoggo/caddy-defender](https://github.com/JasonLovesDoggo/caddy-defender) | AI/cloud IP blocking |

## Usage

### Pull the Image

```bash
docker pull ghcr.io/mac-lucky/caddy-cloudflare:latest
# or
docker pull maclucky/caddy-cloudflare:latest
```

### Running the Container

```bash
docker run -d \
  --name caddy \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  -v caddy_data:/data \
  -v caddy_config:/config \
  -e CF_API_TOKEN=your_cloudflare_token \
  ghcr.io/mac-lucky/caddy-cloudflare:latest
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CF_API_TOKEN` | Cloudflare API token with DNS edit permissions |
| `CROWDSEC_API_KEY` | CrowdSec bouncer API key |

## Security Configuration Examples

### Basic Caddyfile with Cloudflare DNS

```caddyfile
example.com {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }
    reverse_proxy backend:8080
}
```

### Rate Limiting

Protect against brute force attacks with per-IP rate limits:

```caddyfile
(rate_limits) {
    rate_limit {
        zone dynamic_per_ip {
            key    {remote_host}
            events 100
            window 1m
        }
        zone login_protection {
            match {
                path /login* /api/auth*
            }
            key    {remote_host}
            events 5
            window 1m
        }
    }
}

example.com {
    import rate_limits
    reverse_proxy backend:8080
}
```

### CrowdSec Integration

Block malicious IPs using community threat intelligence:

```caddyfile
{
    crowdsec {
        api_url http://crowdsec:8080
        api_key {env.CROWDSEC_API_KEY}
        ticker_interval 15s
    }
}

example.com {
    route {
        crowdsec
        reverse_proxy backend:8080
    }
}
```

### GeoIP Blocking

Block requests from specific countries (requires MaxMind GeoLite2 database):

```caddyfile
(geoip_block) {
    @blocked_geo {
        maxmind_geolocation {
            db_path "/usr/share/GeoIP/GeoLite2-Country.mmdb"
            deny_countries RU CN KP IR
        }
    }
    handle @blocked_geo {
        respond "Access Denied" 403
    }
}

example.com {
    import geoip_block
    reverse_proxy backend:8080
}
```

### AI/Cloud Defender

Block AI scrapers and cloud service IPs:

```caddyfile
example.com {
    defender block {
        ranges openai deepseek githubcopilot aws gcloud azurepubliccloud
    }
    reverse_proxy backend:8080
}
```

Available ranges: `openai`, `deepseek`, `githubcopilot`, `aws`, `gcloud`, `azurepubliccloud`, and more.

### Complete Security Stack Example

```caddyfile
{
    crowdsec {
        api_url http://crowdsec:8080
        api_key {env.CROWDSEC_API_KEY}
        ticker_interval 15s
    }
}

(security_headers) {
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
        -X-Powered-By
    }
}

(rate_limits) {
    rate_limit {
        zone per_ip {
            key    {remote_host}
            events 100
            window 1m
        }
    }
}

(geoip_block) {
    @blocked_geo {
        maxmind_geolocation {
            db_path "/usr/share/GeoIP/GeoLite2-Country.mmdb"
            deny_countries RU CN KP IR
        }
    }
    handle @blocked_geo {
        respond "Access Denied" 403
    }
}

example.com {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }
    import security_headers
    import rate_limits
    import geoip_block

    defender block {
        ranges openai deepseek
    }

    route {
        crowdsec
        reverse_proxy backend:8080
    }
}
```

## CrowdSec Setup

CrowdSec provides community-driven threat intelligence. To use it:

### 1. Run CrowdSec Container

```bash
docker run -d \
  --name crowdsec \
  -v crowdsec_data:/var/lib/crowdsec/data \
  -v crowdsec_config:/etc/crowdsec \
  -e COLLECTIONS="crowdsecurity/caddy crowdsecurity/http-cve crowdsecurity/whitelist-good-actors" \
  crowdsecurity/crowdsec:latest
```

### 2. Create Bouncer API Key

```bash
docker exec crowdsec cscli bouncers add caddy-bouncer
```

Copy the generated API key and set it as `CROWDSEC_API_KEY` environment variable.

### 3. Install Additional Collections (Optional)

```bash
docker exec crowdsec cscli collections install crowdsecurity/http-cve
docker exec crowdsec cscli collections install crowdsecurity/whitelist-good-actors
```

## GeoIP Database Setup

GeoIP blocking requires a MaxMind GeoLite2 database:

1. Register for free at [maxmind.com](https://www.maxmind.com/en/geolite2/signup)
2. Download `GeoLite2-Country.mmdb`
3. Mount the database file into the container:

```bash
docker run -d \
  --name caddy \
  -v ./GeoLite2-Country.mmdb:/usr/share/GeoIP/GeoLite2-Country.mmdb:ro \
  ...
```

## Automated Builds

This image is automatically built and pushed to Docker Hub and GitHub Container Registry daily at midnight UTC.

## Tags

- `latest`: Latest stable build
- `x.y.z`: Version tagged releases

## License

This project is licensed under the MIT License.
