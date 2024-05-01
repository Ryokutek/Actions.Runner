# Actions.Runner

### Building an image:
```
docker build --tag <repository owner>/github-actions-runner:latest .
```

### Running an image:
```
docker run -d -e ORGANIZATION_NAME=<GitHub organization> -e ACCESS_TOKEN=<access token> <repository owner>/github-actions-runner:latest
```
