FROM nginxinc/nginx-unprivileged:alpine
USER root
RUN apk upgrade --no-cache
USER nginx
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
