SHELL := /bin/bash

all: container

container:
	docker build --no-cache -t jubicoy/jenkins-base-debian .

push:
	docker push jubicoy/jenkins-base-debian
