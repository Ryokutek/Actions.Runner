#!/usr/bin/env bash

if [[ ! -S /var/run/docker.sock ]]; then
    echo "Docker socket is missing"
	exit 1
fi

if [[ ! -r /var/run/docker.sock || ! -w /var/run/docker.sock ]]
then
    echo "Docker socket is missing read/write permission"
	exit 1
fi

gid=$(stat -c '%g' '/var/run/docker.sock')

if ! getent group "$gid" > /dev/null; then
	addgroup --gid "$gid" docker
fi

gname=$(getent group "$gid" | cut -d: -f1)

if ! groups myuser | grep --quiet "\b${gname}\b"; then
	usermod --append --groups "$gid" myuser
fi

sudo -u runner-user "./start-runner.sh"
