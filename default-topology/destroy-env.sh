#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]] ; then
    echo 'Usage: destroy-env env aws-profile'
    exit 1
fi

ENVIRONMENT=$1

export AWS_PROFILE=$2
export TF_IN_AUTOMATION=true

for MODULE in frontend backend shared; do

    cd $MODULE

    terraform workspace 'select' $ENVIRONMENT

    echo "Destroying module $MODULE"
    terraform destroy -force -var-file ../application.tfvars -var-file ../secrets.tfvars
    echo "Switching to default workspace"
    terraform workspace 'select' default
    echo "Deleting workspace $ENVIRONMENT"
    terraform workspace delete $ENVIRONMENT

    cd ..
done
