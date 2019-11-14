#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export CLUSTER=${CLUSTER-kind}
export REGISTRY=${REGISTRY-docker-daemon}
export NAMESPACE=${NAMESPACE-fats}

fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
source ${fats_dir}/.configure.sh

basedir=$(realpath `dirname "${BASH_SOURCE[0]}"`/../..)
for app in demo server; do
  cd ${basedir}/${app}
  image=`fats_image_repo ${app}`
  docker build -t ${image} .
  docker push ${image}
done

if ! [ ${REGISTRY} == "dockerhub" ]; then
  docker pull dsyer/petclinic
  image=`fats_image_repo petclinic`
  docker tag dsyer/petclinic ${image}
  docker push ${image}
fi