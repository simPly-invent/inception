# Developer documentation

## Set up the environment from scratch

### Prerequisites

- A Linux virtual machine (Debian recommended).
- Docker Engine and the Docker Compose plugin (`docker compose version`).
- `make` and `bash` (the TLS certificate is generated inside the nginx image,
  so `openssl` is not needed on the host).
- The domain mapped to the VM:

  ```sh
  echo "127.0.0.1 mobenais.42.fr" | sudo tee -a /etc/hosts
  ```

- The data directories for the volumes:

  ```sh
  mkdir -p /home/mobenais/data/mariadb /home/mobenais/data/wordpress
  ```

### Configuration files and secrets

`make secrets` creates everything that must never be committed:

- `secrets/db_root_password.txt`, `secrets/db_password.txt`,
  `secrets/user_password.txt`, `secrets/wp_password.txt`: random 32-character
  passwords (`/dev/urandom | base32`).
- `srcs/.env` with the following variables:

| Variable                      | Used by            | Meaning                              |
|-------------------------------|--------------------|--------------------------------------|
| `DB_ROOT_USER`                | -                  | MariaDB root user name               |
| `DB_ROOT_PASSWORD`            | mariadb            | MariaDB root password                |
| `NAME_DATABASE`               | mariadb, wordpress | WordPress database name              |
| `DB_USER` / `DB_PASSWORD`     | mariadb, wordpress | WordPress database account           |
| `WP_ADMIN_USER/EMAIL/PASSWORD`| wordpress          | WordPress administrator              |
| `WP_USER_USERNAME/EMAIL/PASSWORD` | wordpress      | WordPress author account             |
| `PATH_ENV`                    | compose            | absolute path of `srcs/.env`         |
| `PATH_SECRETS_DB_PASS`        | compose            | file for the `db_password` secret    |
| `PATH_SECRETS_DB_ROOT_PASS`   | compose            | file for the `db_root_password` secret |

The script asks for a configuration mode:

- `0` (default): reads names and emails, one per line, from
  `~/secrets/.default_conf.txt` (database name, DB user, admin user, admin
  email, user name, user email);
- `1` (custom): asks for each value interactively.

The administrator name must not contain `admin` or `administrator`.

`.env.example` at the root lists the expected keys without values.

## Build and launch

| Command           | Effect                                                         |
|-------------------|----------------------------------------------------------------|
| `make secrets`    | generate `secrets/` and `srcs/.env`                            |
| `make build`      | generate secrets if missing, then `docker compose up --build`  |
| `make clean`      | delete `secrets/`, `srcs/.env` and reset `.env.example`        |
| `make secret_re`  | `clean` + `secrets`                                            |

`make build` runs Compose from `srcs/`, so `srcs/.env` is loaded automatically
for variable substitution in `docker-compose.yml`.

Startup order: `mariadb` → `wordpress` (waits with `mysqladmin ping`) →
`nginx`.

## Managing containers and volumes

```sh
cd srcs
docker compose ps                    # status
docker compose logs -f wordpress     # follow logs of one service
docker compose up -d --build nginx   # rebuild/restart one service
docker compose down                  # stop and remove containers + network
docker compose down -v               # same, and remove the named volumes

docker exec -it wordpress bash       # shell in a container
docker exec -it wordpress wp user list --allow-root
docker exec -it mariadb sh -c 'mysql -uroot -p"$(cat /run/secrets/db_root_password)"'

docker volume ls                     # srcs_mariadb_data, srcs_wordpress_data
docker volume inspect srcs_wordpress_data
docker network inspect srcs_inception
```

## Where data is stored and how it persists

| Volume           | Mounted in                         | Host location                   |
|------------------|------------------------------------|---------------------------------|
| `mariadb_data`   | `mariadb:/var/lib/mysql`           | `/home/mobenais/data/mariadb`   |
| `wordpress_data` | `wordpress:/var/www/html`, `nginx:/var/www/html` | `/home/mobenais/data/wordpress` |

Both are Docker named volumes (local driver) whose data lives in
`/home/mobenais/data`. They survive `docker compose down` and container
rebuilds; they are only removed by `docker compose down -v` /
`docker volume rm`.

Initialisation happens only on an empty volume:

- MariaDB creates `/var/lib/mysql/.initialized` after setting up users and the
  database;
- WordPress is installed only if `/var/www/html/wp-config.php` does not exist.

To start from a clean state (e.g. after `make secret_re`, since the old
passwords are stored in the database):

```sh
cd srcs && docker compose down -v
sudo rm -rf /home/mobenais/data/mariadb/* /home/mobenais/data/wordpress/*
```
