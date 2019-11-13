#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export NAMESPACE=${NAMESPACE-fats}

# fetch FATS scripts
fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
source $fats_dir/.util.sh
$fats_dir/install.sh kustomize
$fats_dir/install.sh kapp

cd `dirname "${BASH_SOURCE[0]}"`/../..

export KAPP_NAMESPACE=${NAMESPACE}

# run test functions
for test in base actuator prometheus mysql; do
  echo "##[group]Run kustomize layers/$test"
    kustomize build layers/${test} --load_restrictor none
  echo "##[endgroup]"
done

for test in simple enhanced petclinic; do
  echo "##[group]Run kustomize sample $test"
    kustomize build layers/samples/${test} --load_restrictor none
  echo "##[endgroup]"
done

for test in simple enhanced petclinic; do
  echo "##[group]Deploy app $test"
    kapp deploy --wait-check-interval 10s --wait-timeout 30m -y -a $test \
      -f <(kustomize build layers/samples/${test} --load_restrictor none)
    kapp delete -y -a $test
  echo "##[endgroup]"
done
