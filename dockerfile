FROM alpine:latest

RUN apk update && apk upgrade --no-cache
RUN apk add --no-cache \
    nginx \
    supervisor \

RUN mkdir -p /run/nginx /var/www/html /var/log/supervisor

# Copier le code PHP
COPY . /var/www/html/
WORKDIR /var/www/html/

# Permissions
RUN chown -R nginx:nginx /var/www/html

# Nginx config
RUN cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Supervisord
RUN cat > /etc/supervisord.conf <<'EOF'
[supervisord]
nodaemon=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true
stdout_logfile=/var/log/supervisor/nginx.log
stderr_logfile=/var/log/supervisor/nginx.log

EOF

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
