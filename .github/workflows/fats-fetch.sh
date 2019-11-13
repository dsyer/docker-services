#!/bin/bash

dir=${1}
repo=${2:-projectriff/fats}
refspec=${3:-master}

if [ ! -f $dir ]; then
  mkdir -p $dir
  curl -L https://github.com/${repo}/archive/${refspec}.tar.gz | \
    tar xz -C $dir --strip-components 1
fi