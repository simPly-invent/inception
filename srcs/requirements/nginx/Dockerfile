FROM debian:bookworm

RUN apt-get update && sudo apt-get install nginx -y

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

ENTRYPOINT ["/usr/local/bin/script.sh"]