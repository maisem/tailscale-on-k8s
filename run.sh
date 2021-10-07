#! /usr/bin/env bash
export PATH=$PATH:/tailscale/bin

# Enable job control.
set -m

AUTH_KEY="${AUTH_KEY:-}"
ROUTES="${ROUTES:-}"
DEST_IP="${DEST_IP:-}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
USERSPACE="${USERSPACE:-true}"
KUBE_SECRET="${KUBE_SECRET:-tailscale}"

set -e

TAILSCALED_ARGS="--state=kube:${KUBE_SECRET}"

if [[ "${USERSPACE}" == "true" ]]; then
  if [[ ! -z "${DEST_IP}" ]]; then
    echo "IP forwarding is not supported in userspace mode"
    exit 1
  fi
  TAILSCALED_ARGS="--tun=userspace-networking"
else
  if [[ ! -d /dev/net ]]; then
    mkdir -p /dev/net
  fi

  if [[ ! -c /dev/net/tun ]]; then
    mknod /dev/net/tun c 10 200
  fi
fi

if [[ ! -d /var/run/tailscale ]]; then
  mkdir -p /var/run/tailscale
fi

echo "Starting tailscaled"
tailscaled ${TAILSCALED_ARGS} &

UP_ARGS="--accept-dns=false"
if [[ ! -z "${ROUTES}" ]]; then
  UP_ARGS="--advertise-routes=${ROUTES} ${UP_ARGS}"
fi
if [[ ! -z "${AUTH_KEY}" ]]; then
  UP_ARGS="--authkey=${AUTH_KEY} ${UP_ARGS}"
fi
if [[ ! -z "${EXTRA_ARGS}" ]]; then
  UP_ARGS="${UP_ARGS} ${EXTRA_ARGS:-}"
fi

echo "Running tailscale up"
tailscale up ${UP_ARGS}

TAILSCALE_IP=$(tailscale ip --4)
if [[ ! -z "${DEST_IP}" ]]; then
  echo "Adding iptables rule for DNAT"
  iptables -t nat -I PREROUTING -d "${TAILSCALE_IP}" -j DNAT --to-destination "${DEST_IP}"
fi
echo "Tailscale IP: ${TAILSCALE_IP}"

fg