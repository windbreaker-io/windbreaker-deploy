# windbreaker-deploy

Tools for deploying windbreaker

## Initialization

Run `pull-repos.sh` to pull down all of the services. It will also pull down updates.

## Running services locally

Run `deploy-local.sh` to build and launch services together.

## Logging

To monitor logs of services that you are interested in use the
`docker-compose logs` command.

Ex:
```bash
docker-compose logs -f windbreaker npm-watcher
```

Note: `-f` flag will tail the logs.
