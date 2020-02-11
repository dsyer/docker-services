#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export CLUSTER=${CLUSTER-kind}
export CLUSTER_NAME=${CLUSTER_NAME-fats}
export REGISTRY=${REGISTRY-docker-daemon}
export NAMESPACE=${NAMESPACE-fats}

[ -f VERSION ] && readonly version=$(cat VERSION) || readonly version=0.0.1
readonly git_sha=$(git rev-parse HEAD)
readonly git_timestamp=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d%H%M%S' --format="%cd")
readonly slug=${version}-${git_timestamp}-${git_sha:0:16}

# fetch FATS scripts
fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
fats_repo="projectriff/fats"
fats_refspec=6cf797ff # kind cluster changes
if [ ! -f ${fats_dir} ]; then
  mkdir -p ${fats_dir}
  curl -L https://github.com/${fats_repo}/archive/${fats_refspec}.tar.gz | \
    tar xz -C ${fats_dir} --strip-components 1
fi

# start FATS
source $fats_dir/start.sh

# setup namespace
kubectl create namespace $NAMESPACE
fats_create_push_credentials $NAMESPACE