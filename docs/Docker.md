# Stringer on Docker

## Production ready setup using docker-compose

Create a local environment file named `.env`, e.g. via `touch .env`.

Download [docker-compose.yml](../docker-compose.yml) and run:

```sh
touch .env && docker compose up -d
```

Give it a second and visit `localhost`!

## Production ready manual setup

The following steps can be used to setup Stringer on Docker, using a Postgres database also running on Docker.

1. Setup a Docker network so the two containers we're going to create can communicate:

```Sh
docker network create --driver bridge stringer-network
```

2. Setup a Postgres Docker container:

```Sh
docker run --detach \
    --name stringer-postgres \
    --restart always \
    --volume /srv/stringer/data:/var/lib/postgresql \
    --net stringer-network \
    -e POSTGRES_PASSWORD=myPassword \
    -e POSTGRES_DB=stringer \
    postgres:18-alpine
```

3. Run the Stringer Docker image:

```sh
docker run --detach \
    --name stringer \
    --net stringer-network \
    --restart always \
    -e PORT=8080 \
    -e DATABASE_URL=postgres://postgres:myPassword@stringer-postgres/stringer \
    -e SECRET_KEY_BASE=$(openssl rand -hex 64) \
    -e ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 64) \
    -e ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 64) \
    -e ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 64) \
    -e FETCH_FEEDS_CRON="*/5 * * * *" \ # optional
    -e CLEANUP_CRON="0 0 * * *" \ # optional
    -p 127.0.0.1:8080:8080 \
    stringerrss/stringer:latest
```

That's it! You now have a fully working Stringer instance up and running!

## Upgrading Postgres

The setup above moved from Postgres 16 to Postgres 18. Two things changed:

- A Postgres major version cannot read data files written by an older one.
- The official 18+ image expects a single mount at `/var/lib/postgresql` (not `/var/lib/postgresql/data`) and stores the database in a version-named subdirectory inside it.

If you start the 18 image against an existing 16 data directory it refuses to start and prints an explanation, so nothing is lost. But you do need to migrate by hand. Stringer databases are small, so the simplest route is to dump and restore.

1. With the old container still running, dump everything:

```sh
docker compose exec stringer-postgres sh -c 'pg_dumpall -U "$POSTGRES_USER"' > stringer-pg16.sql
```

2. Stop the stack and move the old data directory aside:

```sh
docker compose down
sudo mv /srv/stringer/data /srv/stringer/data-pg16
```

3. Update `docker-compose.yml` (or re-download it): change the image to `postgres:18-alpine` and the volume to `/srv/stringer/data:/var/lib/postgresql`.

4. Start only the database and wait for it to accept connections:

```sh
docker compose up -d stringer-postgres
until docker compose exec stringer-postgres pg_isready -h localhost; do sleep 1; done
```

5. Restore the dump. Errors saying a role or database "already exists" are expected and harmless, because the fresh container already created them:

```sh
docker compose exec -T stringer-postgres sh -c 'psql -U "$POSTGRES_USER" -d postgres' < stringer-pg16.sql
```

6. Start the rest of the stack and check that your feeds and stories are there:

```sh
docker compose up -d
```

7. Once you are happy, delete `/srv/stringer/data-pg16` and `stringer-pg16.sql`.

If you used the manual setup instead of docker-compose, run the same commands with `docker exec stringer-postgres` in place of `docker compose exec stringer-postgres`, and recreate the Postgres container with the new image and volume path in step 3.

For production use it's recommended to put a reverse proxy in front of Stringer.

Caddy (https://caddyserver.com/):

```
stringer.example.org {
	proxy / localhost:8080 {
      transparent
	}
}
```

Nginx (https://nginx.org/):

```
server {
        listen      [::]:80;
        listen      80;
        server_name stringer.example.org;
        access_log  /var/log/nginx/stringer.example.org-access.log;
        error_log   /var/log/nginx/stringer.example.org-error.log;

        return 301 https://$host:443$request_uri;
}

server {
        server_name stringer.example.org;

        access_log  /var/log/nginx/stringer.example.org-access.log;
        error_log   /var/log/nginx/stringer.example.org-error.log;

        listen      [::]:443 ssl http2;
        listen      443 ssl http2;

        # see https://mozilla.github.io/server-side-tls/ssl-config-generator/
        # for ssl best practices.
        # Or use Letsencrypt, with certbot.
        ssl_certificate ssl/fullchain.pem;;
        ssl_certificate_key ssl/privatekey.pem;
		

        location    / {
                gzip on;
                gzip_min_length  1100;
                gzip_buffers  4 32k;
                gzip_types    text/css text/javascript text/xml text/plain text/x-component application/javascript application/x-javascript application/json application/xml  application/rss+xml font/truetype application/x-font-ttf font/opentype application/vnd.ms-fontobject image/svg+xml;
                gzip_vary on;
                gzip_comp_level  6;

                proxy_pass  http://localhost:8080;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header X-Forwarded-Port $server_port;
                proxy_set_header X-Request-Start $msec;
        }
}
```
