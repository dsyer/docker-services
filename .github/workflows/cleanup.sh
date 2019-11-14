#!/bin/bash

set -o nounset

NAMESPACE=${NAMESPACE-fats}

# fetch FATS scripts
fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats
source $fats_dir/.util.sh

export KAPP_NAMESPACE=${NAMESPACE}

# run test functions
for test in simple enhanced petclinic server; do
  echo "##[group]Clean up test $test"
      kapp delete -y -a $test
  echo "##[endgroup]"
done
