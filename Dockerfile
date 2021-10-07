FROM alpine:3.14
ARG TRACK=stable
ARG ARCH=amd64

WORKDIR tailscale
RUN apk add --no-cache ca-certificates jq curl iptables iproute2 bash
RUN curl -L "https://pkgs.tailscale.com/${TRACK}/$(curl https://pkgs.tailscale.com/${TRACK}/\?mode\=json | jq .Tarballs.${ARCH} -r)" -o tailscale.tgz \
    && tar xvzf tailscale.tgz \
    && mv tailscale*/tailscale* /usr/bin \
    && rm tailscale.tgz \
    && rm -rf tailscale_*

COPY run.sh /tailscale
CMD [ "/tailscale/run.sh" ]
