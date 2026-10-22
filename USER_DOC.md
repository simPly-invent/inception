# User documentation

## Services provided

| Service     | Role                                              | Reachable from          |
|-------------|---------------------------------------------------|-------------------------|
| `nginx`     | HTTPS web server, the only entry point (port 443) | `https://mobenais.42.fr` |
| `wordpress` | WordPress website, executed by php-fpm            | nginx only (internal)   |
| `mariadb`   | Database holding the WordPress content            | wordpress only (internal) |

## Start and stop

From the root of the repository:

```sh
make secrets   # first time only: generates passwords and srcs/.env
make build     # builds and starts all containers (foreground)
```

To stop the stack, press `Ctrl+C` in the terminal running `make build`, or
from another terminal:

```sh
cd srcs && docker compose down
```

Data (database and website files) is kept between restarts.

## Access the website

1. Make sure `mobenais.42.fr` points to the machine (`/etc/hosts` contains
   `127.0.0.1 mobenais.42.fr`).
2. Open `https://mobenais.42.fr`. The certificate is self-signed: accept the
   browser warning.
3. The administration panel is at `https://mobenais.42.fr/wp-admin`. Log in
   with the administrator account (see below).

Two WordPress accounts exist:

- an **administrator** (`WP_ADMIN_USER`);
- a regular **author** (`WP_USER_USERNAME`).

## Credentials

Credentials are generated locally by `make secrets` and are never committed:

| File                              | Content                                   |
|-----------------------------------|-------------------------------------------|
| `srcs/.env`                       | usernames, emails, database name, passwords |
| `secrets/db_root_password.txt`    | MariaDB root password                     |
| `secrets/db_password.txt`         | MariaDB WordPress user password           |
| `secrets/user_password.txt`       | WordPress admin / user password           |

To display the WordPress logins:

```sh
grep -E '^WP_' srcs/.env
```

To regenerate all credentials (this requires a fresh database, see
[DEV_DOC.md](DEV_DOC.md)):

```sh
make secret_re
```

## Check that everything runs

```sh
docker ps                                  # nginx, wordpress, mariadb are "Up"
docker logs nginx                          # per-service logs
docker logs wordpress
docker logs mariadb
curl -kI https://mobenais.42.fr            # HTTP/1.1 200 OK (or 302)
curl -I  http://mobenais.42.fr             # must fail: only 443 is open
```

Check the database from inside the container:

```sh
docker exec -it mariadb sh -c 'mysql -uroot -p"$(cat /run/secrets/db_root_password)" -e "SHOW DATABASES;"'
```
