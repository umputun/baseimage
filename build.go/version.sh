#!/usr/bin/env sh

version="local-$(date +%Y%m%dT%H:%M:%S)"

if [ -z "$CI" ] ; then
  # outside of CI
  if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ] ; then
    # valid git repo
    ref=$(git describe --tags --exact-match 2> /dev/null || git symbolic-ref -q --short HEAD)
    version="${ref}"-$(git log -1 --format=%h)-$(date +%Y%m%dT%H:%M:%S)
  fi
else
  # inside CI (gh actions)
  ref="$(echo ${GITHUB_REF} | cut -d'/' -f3)"
  version=${ref}-${GITHUB_SHA:0:7}-$(date +%Y%m%dT%H:%M:%S)
fi

echo "$version"
