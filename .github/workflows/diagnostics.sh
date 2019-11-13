#!/bin/bash

set -o nounset

fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats

echo "##[group]Docker daemon"
cat /etc/docker/daemon.json
echo "##[endgroup]"


if [ -d "$fats_dir" ]; then
  source $fats_dir/diagnostics.sh
fi