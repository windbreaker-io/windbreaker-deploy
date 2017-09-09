#!/bin/bash

pull () {
  if [ cd repo; ] then
    git pull && cd ../;
  else
    git clone git@github.com:windbreaker-io/$1 repos/$1;
  fi
}

mkdir repos

# set -e

# clone projects into repos folder
pull windbreaker
pull rss-watcher
pull npm-watcher
pull windbreaker-service-util

