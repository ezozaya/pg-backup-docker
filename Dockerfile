FROM alpine:latest

LABEL maintainer="Matias Pieroboón <mpierobon@qwertysoft.io>"

RUN apk --no-cache update && \
  apk --no-cache add ca-certificates groff less python3 postgresql-client && \
  pip3 --no-cache-dir install awscli && \
  rm -rf /var/cache/apk/*

RUN mkdir -p /backups
ADD backup.sh /usr/bin/backup
RUN chmod +x /usr/bin/backup

RUN ln -s /usr/bin/backup /etc/periodic/daily

ENTRYPOINT "crond"

CMD ["-f", "-d", "8"]