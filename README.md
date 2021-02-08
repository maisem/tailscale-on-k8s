# Overview
The goal of this project is to provide a Tailscale based LoadBalancer implementation for Kubernetes Clusters.

# Instructions
The current version of can be deployed as a StatefulSet:
1. Optional: Create the following secret which will automate login.
  You will need to get an auth key from [Tailscale Admin Console](https://login.tailscale.com/admin/authkeys).  
  If you don't provide you the key, you can still use authenticate by using the url in the logs.
    ```
    apiVersion: v1
    kind: Secret
    metadata:
      name: tailscale-auth
    stringData:
      AUTH_KEY: tskey-...
    ```
1. Export the following variables:
    ```
    # The image repository tag that you would like to use.
    export IMAGE_TAG=
    # The destination IP Address.
    export DEST_IP=
    ```

1. Optional: Configure the [subnet routing](https://tailscale.com/kb/1019/subnets) feature.
    ```
    export ROUTES=10.0.0.0/24,10.0.1.0/24
    ```

1. Build and publish the container to your desired registry.
    ```
    make build && make push
    ```

    To cross compile for a different arch use:
    ```
    export ARCH=linux/arm64
    make buildx && make push
    ```

1. Create the StatefulSet
    ```
    make deploy
    ```
    
1. Grab the Tailscale IP from either the logs or the admin console.
   ```
   kubectl logs tailscale-0 | grep "Tailscale IP"
   ```
   
1. Interact with your endpoint like you normally would:  
   ```
   e.g. if `DEST_IP` is `1.1.1.1`
   dig google.com "@${TAILSCALE_IP}"
   ```
