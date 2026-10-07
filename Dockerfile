# WSOK634 static site — generic Alpine image + nginx serving the site files.
FROM alpine:3.20

RUN apk add --no-cache nginx \
    && mkdir -p /run/nginx /var/www/wsok634 \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY index.html style.css /var/www/wsok634/
COPY assets/ /var/www/wsok634/assets/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
