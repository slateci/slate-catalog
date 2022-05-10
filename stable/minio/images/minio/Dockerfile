FROM minio/minio:latest

LABEL maintainer="MinIO Inc <dev@min.io>"

COPY dockerscripts/docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
