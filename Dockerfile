FROM alpine:3.7

RUN apk --no-cache add bash \
                       curl
RUN curl  https://dl.minio.io/client/mc/release/linux-amd64/mc -o /usr/bin/mc && \
    chmod +x /usr/bin/mc

ADD sync.sh /
RUN chmod a+x /sync.sh

ENTRYPOINT ["/sync.sh"]
