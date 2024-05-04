FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION=2.316.0
ARG USERNAME=runner-user

# Install core dependencies
RUN apt update -y && apt upgrade -y
RUN apt install -y --no-install-recommends sudo curl wget ca-certificates jq

# Install .NET 8 SDK repository
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

# Install Docker repository
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt install -y --no-install-recommends dotnet-sdk-8.0 docker-ce-cli docker-buildx-plugin docker-compose-plugin

RUN useradd -s /bin/bash --create-home ${USERNAME}
RUN mkdir -p /home/${USERNAME}/actions-runner

WORKDIR /home/${USERNAME}/actions-runner

RUN curl -o ./actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN tar -xzf ./actions-runner-linux-x64.tar.gz

RUN chown -R ${USERNAME} /home/${USERNAME} && ./bin/installdependencies.sh

COPY ./scripts/docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT [ "./docker-entrypoint.sh" ]
