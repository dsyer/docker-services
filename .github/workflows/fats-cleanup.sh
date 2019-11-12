#!/bin/bash

set -o nounset

fats_dir=`dirname "${BASH_SOURCE[0]}"`/fats

uninstall_chart() {
  local name=$1
  kubectl delete customresourcedefinitions.apiextensions.k8s.io -l app.kubernetes.io/managed-by=Tiller,app.kubernetes.io/instance=$name 
}

# attempt to cleanup fats
if [ -d "$fats_dir" ]; then
  source $fats_dir/macros/cleanup-user-resources.sh
  kubectl delete namespace $NAMESPACE

  echo "Uninstall system"

  source $fats_dir/cleanup.sh
fi