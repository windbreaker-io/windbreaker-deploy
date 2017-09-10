#!/bin/bash

pull () {
  pushd repos/$1;
  if [ $? == 0 ]; then
    git pull && popd;
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

