FROM debian:bookworm

RUN apt-get update && \
    apt-get install php php-fpm php-mysql php-cli -y && \
    apt-get install curl -y && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    rm -rf /var/lib/apt/lists/*

COPY script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh


ENTRYPOINT ["/usr/local/bin/script.sh"]