FROM debian:stable

ARG RUNNER_VERSION=2.316.0
ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=runner-user

RUN apt update -y && apt upgrade -y
RUN apt install -y --no-install-recommends curl ca-certificates jq build-essential libssl-dev libffi-dev

RUN useradd --create-home ${USERNAME}
RUN mkdir -p /home/${USERNAME}/actions-runner

WORKDIR /home/${USERNAME}/actions-runner

RUN curl -o ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN tar -xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN pwd && chown -R ${USERNAME} ./
RUN ./bin/installdependencies.sh

COPY ./scripts/start-runner.sh start-runner.sh
RUN chmod +x start-runner.sh

USER ${USERNAME}

ENTRYPOINT [ "/bin/sh", "-c", "./start-runner.sh" ]
