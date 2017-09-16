#!/bin/bash

repos_dir="./repos"

pull () {
  local repo_name="$1"
  local repo_path="$repos_dir/$repo_name"
  if [ -d "$repo_path" ]; then
    pushd "$repo_path" > /dev/null
    echo "Pulling $repo_name into $repo_path"
    git pull && popd > /dev/null
  else
    git clone "git@github.com:windbreaker-io/$repo_name" "$repo_path";
  fi
}

set -e

mkdir -p repos

# clone projects into repos folder
pull windbreaker
pull windbreaker-hooks
pull rss-watcher
pull npm-watcher
pull windbreaker-service-util

