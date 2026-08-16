FROM debian:bookworm

RUN apt-get update && apt-get install nginx openssl -y \
    && rm -rf /var/lib/apt/lists/*

run mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
    -newkey rsa:4096  \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=Rhone/L=Lyon/O=42/OU=42/CN=mobenais.42.fr"

ENTRYPOINT ["nginx", "-g", "daemon off;"]