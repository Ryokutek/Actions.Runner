# GitHub Actions Runner

### Building an image:
```
docker build \
  --tag <namespace>/github-actions-runner:latest \
  --build-arg RUNNER_UID=1000 \
  --build-arg RUNNER_GID=1000 \
  --build-arg DOCKER_GID=996 \
  .
```

### Running an image:
```
docker run -d \
  -e RUNNER_UID=<host user id> \
  -e RUNNER_GID=<host group id> \
  -e RUNNER_VERSION=<GitHub runner version> \
  -e RUNNER_TYPE=<'organization' or 'repository'> \
  -e ORGANIZATION_NAME=<GitHub organization name> \
  -e OWNER=<GitHub username> \
  -e REPOSITORY=<GitHub repository URL> \
  -e ACCESS_TOKEN=<GitHub personal access token> \
  -e API_VERSION=<GitHub API version> \
  <namespace>/github-actions-runner:latest
```
