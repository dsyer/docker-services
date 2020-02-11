#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export CLUSTER=${CLUSTER-kind}
export CLUSTER_NAME=${CLUSTER_NAME-fats}
export REGISTRY=${REGISTRY-docker-daemon}
export NAMESPACE=${NAMESPACE-fats}

# fetch FATS scripts
fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
source ${fats_dir}/.configure.sh
$fats_dir/install.sh kustomize
$fats_dir/install.sh kapp

basedir=$(realpath `dirname "${BASH_SOURCE[0]}"`/../..)
cd `dirname "${BASH_SOURCE[0]}"`

export KAPP_NAMESPACE=${NAMESPACE}

# run test functions
for test in base mysql kafka; do
  echo "##[group]Run kustomize layers/$test"
    kustomize build ${basedir}/layers/${test}
  echo "##[endgroup]"
done

for test in base mysql kafka; do
  echo "##[group]Apply kustomize layers/$test"
    kubectl apply \
      -f <(kustomize build ${basedir}/layers/${test}) \
      --dry-run --namespace ${NAMESPACE}
  echo "##[endgroup]"
done

for test in simple enhanced petclinic config service; do
  echo "##[group]Run kustomize sample $test"
    kustomize build ${basedir}/layers/samples/${test}
  echo "##[endgroup]"
done

for test in simple enhanced petclinic server secure; do
  echo "##[group]Apply app $test"
    kubectl apply \
      -f <(kustomize build samples/${REGISTRY}/${test}) \
      --dry-run --namespace ${NAMESPACE}
  echo "##[endgroup]"
done

for test in simple enhanced petclinic server secure; do
  echo "##[group]Deploy app $test"
    name=demo
    if [ "${test}" == "petclinic" ] || [ "${test}" == "server" ]; then
      name=${test}
    fi
    kapp deploy --wait-check-interval 2s --wait-timeout 30m -y -a $test \
		  -f <(kustomize build samples/${REGISTRY}/${test} | IMAGE=$(fats_image_repo ${name}) envsubst) \
		  && kapp delete -y -a $test
  echo "##[endgroup]"
done
