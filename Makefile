SHELL := /bin/bash

all: image

NOCACHE ?= no

ifeq ($(NOCACHE),no)
	OPTS :=
else
	OPTS := --no-cache
endif

image:
	docker build $(OPTS) -t jubicoy/jenkins-base-debian .

push:
	docker push jubicoy/jenkins-base-debian
