FROM debian:latest

ARG DEBIAN_FRONTEND=noninteractive

# Set default values for UID and GID
ENV RUNNER_UID=1000 \
    RUNNER_GID=1000 \
    RUNNER_VERSION=2.322.0


# Install core dependencies
RUN apt update -y && apt upgrade -y
RUN apt install -y --no-install-recommends sudo curl wget ca-certificates jq

# Install Docker repository
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install .NET SDK repository
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

# Install Docker CLI and .NET SDK
RUN apt update -y && apt install -y --no-install-recommends \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin \
    dotnet-sdk-8.0 \
    dotnet-sdk-9.0


RUN groupadd -g ${RUNNER_GID} github-runner && \
    useradd -u ${RUNNER_UID} -g github-runner -s /usr/sbin/nologin github-runner

WORKDIR /actions-runner

RUN curl -o ./runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar -xzf ./runner.tar.gz && \
    rm runner.tar.gz

# Install dependencies for the runner
RUN ./bin/installdependencies.sh

# This lets the Docker socket be accessed by the github-runner when mounted
RUN DOCKER_GROUP_ID=999 && \
    groupadd -g ${DOCKER_GROUP_ID} docker && \
    usermod -aG docker github-runner

COPY ./scripts/docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

# Switch to non-root user
USER github-runner

ENTRYPOINT [ "./docker-entrypoint.sh" ]
