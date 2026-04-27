FROM alpine:3.19

LABEL maintainer="traffic-host" \
      description="Traffic generator container for the Docker security lab"

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    bind-tools \
    netcat-openbsd \
    socat \
    iproute2 \
    iputils \
    jq \
    coreutils

WORKDIR /traffic-host
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["normal"]
