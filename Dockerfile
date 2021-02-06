FROM ubuntu
WORKDIR /tailscale
RUN apt-get update && apt-get install gnupg curl -y
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | apt-key add -
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list
RUN apt-get update && apt-get install tailscale -y
RUN apt-get install jq -y

COPY run.sh .
ENTRYPOINT [ "/tailscale/run.sh" ]
