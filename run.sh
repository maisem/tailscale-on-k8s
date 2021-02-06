#! /bin/bash
export PATH=$PATH:/tailscale/bin

AUTH_KEY="${AUTH_KEY:-}"
ROUTES="${ROUTES:-}"
DEST_IP="${DEST_IP:-}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

set -e

if [[ ! -d /dev/net ]]; then
    mkdir -p /dev/net
fi
if [[ ! -c /dev/net/tun ]]; then
    mknod /dev/net/tun c 10 200
fi
if [[ ! -d /var/run/tailscale ]]; then
    mkdir -p /var/run/tailscale
fi

echo "Starting tailscaled"
tailscaled &
sleep 5

ARGS="--accept-dns=false"
if [[ ! -z "${ROUTES}" ]]; then
    ARGS="--advertise-routes=${ROUTES} ${ARGS}"
fi
if [[ ! -z "${AUTH_KEY}" ]]; then
    ARGS="--authkey=${AUTH_KEY} ${ARGS}"
fi
if [[ ! -z "${EXTRA_ARGS}" ]]; then
    ARGS="${ARGS} ${EXTRA_ARGS:-}"
fi

echo "Running tailscale up"
tailscale up ${ARGS}

sleep 5


TAILSCALE_IP=$(ip -j a show tailscale0 | jq '.[].addr_info[] | select( .family == "inet" ) | .local' -r)
if [[ ! -z "${DEST_IP}" ]]; then
    echo "Adding iptables rule for DNAT"
    iptables -t nat -I PREROUTING -d "${TAILSCALE_IP}" -j DNAT --to-destination "${DEST_IP}"
fi
echo "Tailscale IP: ${TAILSCALE_IP}"

wait