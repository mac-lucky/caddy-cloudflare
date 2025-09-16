# Caddy with Cloudflare DNS Plugin

[![Docker Pulls](https://img.shields.io/docker/pulls/maclucky/caddy-cloudflare)](https://hub.docker.com/r/maclucky/caddy-cloudflare)
[![Docker Image Version](https://img.shields.io/docker/v/maclucky/caddy-cloudflare/latest)](https://hub.docker.com/r/maclucky/caddy-cloudflare/tags)
[![GitHub Actions Workflow Status](https://github.com/mac-lucky/caddy-cloudflare/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mac-lucky/caddy-cloudflare/actions/workflows/docker-image.yml)
[![Platform](https://img.shields.io/badge/platform-amd64%20%7C%20arm64-blue)](https://hub.docker.com/r/maclucky/caddy-cloudflare/tags)

This Docker image extends the official Caddy server with Cloudflare DNS plugin support for automated HTTPS certificate management.

## Features

- Based on official Caddy server
- Includes Cloudflare DNS plugin for automated DNS-01 challenge solving
- Multi-architecture support (linux/amd64, linux/arm64)

## Usage

### Pull the Image

```bash
docker pull maclucky/caddy-cloudflare:latest
# or
docker pull ghcr.io/mac-lucky/caddy-cloudflare:latest
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
  maclucky/caddy-cloudflare:latest
```

### Example Caddyfile with Cloudflare DNS Challenge

```
example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    respond "Hello, world!"
}
```

## Environment Variables

- `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token with DNS edit permissions

## Automated Builds

This image is automatically built and pushed to Docker Hub and GitHub Container Registry daily at midnight UTC.

## Tags

- `latest`: Latest stable build
- `x.y.z`: Version tagged releases

## License

This project is licensed under the MIT License.

