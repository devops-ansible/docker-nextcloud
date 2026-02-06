ARG IMAGE=nextcloud
ARG VERSION=apache

FROM $IMAGE:$VERSION

LABEL org.opencontainers.image.authors="macwinnie <dev@macwinnie.me>"

ENV NC_USER="www-data"
ENV NC_BASE_PATH="/var/www/html"
ENV NC_APPS="calendar contacts"

# copy all relevant files
COPY files/ /

# organise file permissions and run installer
RUN chmod a+x /install.sh && \
    /install.sh && \
    rm -f /install.sh

# run on every (re)start of container
ENTRYPOINT [ "entrypoint" ]
CMD [ "start" ]
