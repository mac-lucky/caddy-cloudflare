cd /caddy
docker build --platform linux/amd64 -t maclucky/caddy-cloudflare .
docker push maclucky/caddy-cloudflare
