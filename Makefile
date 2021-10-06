ifndef IMAGE_TAG
  $(error "IMAGE_TAG is not set")
endif

TRACK ?= "stable"
ARCH ?= linux/amd64
ROUTES ?= ""

build:
	@docker build --build-arg TRACK=$(TRACK) . -t $(IMAGE_TAG)

push: build
	@docker push $(IMAGE_TAG)

rbac:
	@kubectl apply -f rbac.yaml

sidecar: rbac
	@sed -e "s;{{IMAGE_TAG}};$(IMAGE_TAG);g" sidecar.yaml | kubectl create -f-