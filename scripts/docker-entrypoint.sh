#!/usr/bin/env bash

if [[ ! -S /var/run/docker.sock ]]; then
    echo "Docker socket is missing"
	exit 1
fi

if [[ ! -r /var/run/docker.sock || ! -w /var/run/docker.sock ]]; then
    echo "Docker socket is missing read/write permission"
	exit 1
fi

GROUP_ID=$(stat -c '%g' '/var/run/docker.sock')
echo ${GROUP_ID}

if ! getent group "$GROUP_ID" > /dev/null; then
	addgroup --gid "$GROUP_ID" docker
fi

GROUP_NAME=$(getent group "$GROUP_ID" | cut -d: -f1)
echo ${GROUP_NAME}

if ! groups runner-user | grep --quiet "\b${GROUP_NAME}\b"; then
	usermod --append --groups "$GROUP_ID" runner-user
fi

ORG_NAME=$ORGANIZATION_NAME
TOKEN=$ACCESS_TOKEN
API_VERSION=$GITHUB_API_VERSION

REGISTRATION_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${TOKEN}" -H "X-GitHub-Api-Version: ${API_VERSION}" https://api.github.com/orgs/${ORG_NAME}/actions/runners/registration-token | jq .token --raw-output)
sudo -u runner-user ./config.sh --unattended --url https://github.com/${ORG_NAME} --token ${REGISTRATION_TOKEN} --labels docker-runner

cleanup() {
    echo "Removing runner from organization ${ORG_NAME}..."

    REMOVE_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${TOKEN}" -H "X-GitHub-Api-Version: ${API_VERSION}" https://api.github.com/orgs/${ORG_NAME}/actions/runners/remove-token | jq .token --raw-output)
    sudo -u runner-user ./config.sh remove --token ${REMOVE_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

sudo -u runner-user ./run.sh & wait $!
