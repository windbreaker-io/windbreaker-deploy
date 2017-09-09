#!/bin/bash

# explicitly select services to deploy
# since the same compose file may end
# being used to run integration test containers
docker-compose up \
  windbreaker \
  rss-watcher \
  npm-watcher
