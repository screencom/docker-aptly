NAME = registry:5000/screencom/aptly
VERSION = latest

.PHONY: all build build-nocache

all: build

full: build push

build:
	docker build -t $(NAME):$(VERSION) --rm .

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

push:
	docker push $(NAME):$(VERSION)
