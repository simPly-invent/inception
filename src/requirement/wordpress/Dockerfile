FROM debian:bookworm

RUN apt-get update && \
    apt-get install php php-cli -y && \
    apt-get install curl && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir /var/my_inception && cd /var/my_inception && wp core download --allow-root

RUN cd /var/my_inception && wp config create --dbname=votre_base --dbuser=votre_utilisateur --dbpass=votre_mot_de_passe --dbhost=localhost --allow-root

RUN cat /var/my_inception/wp-config.php