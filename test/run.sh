#!/bin/sh

dockerd --config-file=/etc/docker/daemon.json -p /var/run/docker-bootstrap.pid &

docker-compose create
docker-compose start
