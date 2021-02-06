#! /bin/bash
export PATH=$PATH:/tailscale/bin

set -e
set -x

if [ ! -d /dev/net ]; then
    mkdir -p /dev/net
fi
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi
if [ ! -d /var/run/tailscale ]; then
    mkdir -p /var/run/tailscale
fi

tailscaled &
sleep 5
tailscale up --accept-dns=false --authkey="${AUTH_KEY}"

sleep 5

TAILSCALE_IP=$(ip -j a show tailscale0 | jq '.[].addr_info[] | select( .family == "inet" ) | .local' -r)

iptables -t nat -I PREROUTING -p tcp -d "${TAILSCALE_IP}" -j DNAT --to-destination "${DEST_IP}"

wait
