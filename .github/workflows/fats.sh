#!/bin/bash

set -x

set -o errexit
set -o nounset
set -o pipefail

export CLUSTER=${CLUSTER-kind}
export REGISTRY=${REGISTRY-docker-daemon}
export NAMESPACE=${NAMESPACE-fats}

[ -f VERSION ] && readonly version=$(cat VERSION) || readonly version=0.0.1
readonly git_sha=$(git rev-parse HEAD)
readonly git_timestamp=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d%H%M%S' --format="%cd")
readonly slug=${version}-${git_timestamp}-${git_sha:0:16}

# fetch FATS scripts
fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
fats_repo="dsyer/fats"
fats_refspec=fac7395 # master as of 2019-11-07
source `dirname "${BASH_SOURCE[0]}"`/fats-fetch.sh $fats_dir $fats_refspec $fats_repo
source $fats_dir/.util.sh

# start FATS
source $fats_dir/start.sh

# setup namespace
kubectl create namespace $NAMESPACE
fats_create_push_credentials $NAMESPACE

# run test functions
`dirname "${BASH_SOURCE[0]}"`/tests-run.sh
# clean up
`dirname "${BASH_SOURCE[0]}"`/tests-cleanup.sh
