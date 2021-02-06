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
    docker build . -t "${IMAGE_TAG}" && docker push "${IMAGE_TAG}"
    ```

    From a Mac M1 you can use `docker buildx` to cross-compile for linux/amd64:
    ```
    docker buildx build --platform linux/amd64 --push -t "${IMAGE_TAG}" .
    ```

1. Create the StatefulSet
    ```
    kubectl apply -f svc.yaml
    sed -e "s/{{DEST_IP}}/${DEST_IP}/g" sts.yaml | sed -e "s/{{ROUTES}}/${ROUTES:-}/g" | sed -e "s/{{IMAGE_TAG}}/${IMAGE_TAG}/g" | kubectl apply -f-
    ```