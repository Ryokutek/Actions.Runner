# GitHub Actions Runner

### Building an image:
```
docker build --tag <namespace>/github-actions-runner:latest .
```

### Running an image:
```
docker run -d -e RUNNER_TYPE=<'organization' or 'repository'> -e ACCESS_TOKEN=<personal access token> -e API_VERSION=<GitHub API version> <namespace>/github-actions-runner:latest
```
