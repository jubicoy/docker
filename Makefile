SHELL := /bin/bash

all: container

container:
	docker build -t jubicoy/jenkins-base-debian .

push:
	docker push jubicoy/jenkins-base-debian
