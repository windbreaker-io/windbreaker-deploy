#!/bin/bash

# Explicitly select services to deploy
# since the same compose file may end
# being used to run integration test containers.
# Must explicitly start dependencies or they will keep
# will keep running on ctrl+c. That or switch to just `docker-compose up` and
# use a separate docker-compose.test.yml
docker-compose up \
  windbreaker \
  windbreaker-hooks \
  rss-watcher \
  npm-watcher \
  postgres \
  rabbitmq \
  rediscluster
