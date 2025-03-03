#!/usr/bin/env bash

if [[ ! -S /var/run/docker.sock ]]; then
    echo "Docker socket is missing."
	exit 1
fi

if [[ ! -r /var/run/docker.sock || ! -w /var/run/docker.sock ]]; then
    echo "Docker socket is missing read/write permission."
	exit 1
fi

GROUP_ID=$(stat -c '%g' '/var/run/docker.sock')

if ! getent group "$GROUP_ID" > /dev/null; then
	addgroup --gid "$GROUP_ID" docker
fi

GROUP_NAME=$(getent group "$GROUP_ID" | cut -d: -f1)

if ! groups github-runner | grep --quiet "\b${GROUP_NAME}\b"; then
	usermod -aG "$GROUP_ID" github-runner
fi

WORKING_DIRECTORY="running"
mkdir -p ${WORKING_DIRECTORY} && chown -R github-runner ${WORKING_DIRECTORY}
