#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export CLUSTER=${CLUSTER-kind}
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
for test in base actuator prometheus mysql kafka; do
  echo "##[group]Run kustomize layers/$test"
    kustomize build ${basedir}/layers/${test} --load_restrictor none
  echo "##[endgroup]"
done

for test in base actuator prometheus mysql kafka; do
  echo "##[group]Apply kustomize layers/$test"
    kubectl apply \
      -f <(kustomize build ${basedir}/layers/${test} --load_restrictor none) \
      --dry-run --namespace ${NAMESPACE}
  echo "##[endgroup]"
done

for test in simple enhanced petclinic; do
  echo "##[group]Run kustomize sample $test"
    kustomize build ${basedir}/layers/samples/${test} --load_restrictor none
  echo "##[endgroup]"
done

for test in simple enhanced petclinic service; do
  echo "##[group]Apply app $test"
    kubectl apply \
      -f <(kustomize build samples/${REGISTRY}/${test} --load_restrictor none) \
      --dry-run --namespace ${NAMESPACE}
  echo "##[endgroup]"
done

for test in simple enhanced petclinic service; do
  echo "##[group]Deploy app $test"
    name=demo
    if [ "${test}" == "petclinic" ] || [ "${test}" == "server" ]; then
      name=${test}
    fi
    kapp deploy --wait-check-interval 10s --wait-timeout 30m -y -a $test \
      -f <(kustomize build samples/${REGISTRY}/${test} --load_restrictor none | IMAGE=$(fats_image_repo ${name}) envsubst)
    kapp delete -y -a $test
  echo "##[endgroup]"
done
