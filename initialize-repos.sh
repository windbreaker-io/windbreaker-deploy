#!/bin/bash

clone () {
  git clone git@github.com:windbreaker-io/$1 repos/$1
}

mkdir repos

set -e

# clone projects into repos folder
clone windbreaker
clone rss-watcher
clone npm-watcher

