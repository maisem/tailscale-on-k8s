 # Overview
  The goal of this project is to provide a few ways to run Tailscale inside a Kubernetes Cluster

# Instructions
## Setup
1. (Optional) Create the following secret which will automate login.
   <br>You will need to get an auth key from [Tailscale Admin Console](https://login.tailscale.com/admin/authkeys).
   <br>If you don't provide you the key, you can still use authenticate by using the url in the logs.
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: tailscale-auth
   stringData:
     AUTH_KEY: tskey-...
   ```

1. Set the approriate env variables:
   ```bash
   # We are using untable releases in this example as the support for storing Tailscale
	 # state in k8s secrets is not in a stable release yet and is expected in the 1.16 release.
   export TRACK=unstable
   export IMAGE_TAG=ts:latest
   ```

1. Build and push the container
   ```bash
   make push
   ```

## Sample Sidecar
1. Create the sample nginx pod with a tailscale sidecar
    ```bash
    make sidecar
    ```
1. If you're not using an AuthKey, authenticate by grabbing the login URL here:

   ```bash
   kubectl logs tailscale-sidecar tailscale
   ```

1. Check if you can to connect to nginx over tailscale:

   ```bash
   curl "http://$(tailscale ip -4 nginx)"
   ```

   Or, if you have MagicDNS enabled:

   ```bash
   curl http://nginx
   ```


## Sample Proxy
1. Provide the Cluster IP of the service you want to reach by either:
   - creating a new deployment
      ```bash
      kubectl create deployment nginx --image nginx
      kubectl expose deployment nginx --port 80
      export DEST_IP="$(kubectl get svc nginx -o=jsonpath='{.spec.clusterIP}')"
      ```
    - or, using an existing service
      ```bash
      export DEST_IP="$(kubectl get svc <SVC_NAME> -o=jsonpath='{.spec.clusterIP}')"
      ```
1. Deploy the proxy pod
    ```bash
    make proxy
    ```
1. If you're not using an AuthKey, authenticate by grabbing the login URL here:

   ```bash
   kubectl logs proxy
   ```

1. Check if you can to connect to nginx over tailscale:

   ```bash
   curl "http://$(tailscale ip -4 proxy)"
   ```

   Or, if you have MagicDNS enabled:

   ```bash
   curl http://proxy
   ```
