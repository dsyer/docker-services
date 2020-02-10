FROM nginx

COPY mime.types /etc/nginx/
COPY *.conf /etc/nginx/
COPY run.sh /

ENTRYPOINT [ "/run.sh" ]