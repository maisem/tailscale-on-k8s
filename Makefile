ifndef IMAGE_TAG
  $(error "IMAGE_TAG is not set")
endif

ifndef DEST_IP
  $(error "DEST_IP is not set")
endif

ARCH ?= linux/amd64
ROUTES ?= ""

secret:
	@kubectl delete -f secret.yaml --ignore-not-found
	@kubectl create -f secret.yaml

build:
	@docker build . -t $(IMAGE_TAG)

buildx:
	@docker buildx build --platform $(ARCH) -t $(IMAGE_TAG) .

push:
	@docker push $(IMAGE_TAG)

deploy:
	@kubectl apply -f svc.yaml
	@sed -e "s/{{DEST_IP}}/$(DEST_IP)/g" sts.yaml | sed -e "s/{{ROUTES}}/$(ROUTES)/g" | sed -e "s;{{IMAGE_TAG}};$(IMAGE_TAG);g" | kubectl apply -f-

pv:
	@kubectl create -f pv.yaml
