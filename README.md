 # Overview
  The goal of this project is to provide a few ways to run Tailscale inside a Kubernetes Cluster

# Instructions
## Sidecar
The current version of can be deployed as a Sidecard pod:
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

1. Build and publish the container to your desired registry.
    ```
    IMAGE_TAG=ts:latest TRACK=unstable make push
    ```

1. Create the sample ubuntu pod with a tailscale sidecar
    ```
    IMAGE_TAG=ts:latest make sidecar
    ```