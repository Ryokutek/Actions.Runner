# Actions.Runner

### Building an image:
```
docker build --tag <namespace>/github-actions-runner:latest .
```

### Running an image:
```
docker run -d -e ORGANIZATION_NAME=<GitHub organization> -e ACCESS_TOKEN=<personal access token> <namespace>/github-actions-runner:latest
```
