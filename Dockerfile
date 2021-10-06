FROM ubuntu
ARG TRACK=stable
WORKDIR /tailscale
RUN apt-get update && apt-get install gnupg curl -y
RUN curl -fsSL https://pkgs.tailscale.com/$TRACK/ubuntu/focal.gpg | apt-key add -
RUN curl -fsSL https://pkgs.tailscale.com/$TRACK/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list
RUN apt-get update && apt-get install tailscale -y

COPY run.sh .
ENTRYPOINT [ "/tailscale/run.sh" ]
