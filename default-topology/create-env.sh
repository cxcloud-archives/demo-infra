#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]] ; then
    echo 'Usage: create-env env aws-profile'
    exit 1
fi

export ENVIRONMENT=$1
export AWS_PROFILE=$2

export TF_IN_AUTOMATION=true

for MODULE in shared backend frontend; do

    echo "#-----------------------------------------------------"
    echo "#  Creating infrastructure module $MODULE             "
    echo "#-----------------------------------------------------"

    cd $MODULE
    terraform init
    terraform workspace new $ENVIRONMENT || true
    terraform apply -auto-approve -var-file ../application.tfvars -var-file ../secrets.tfvars
    cd ..

    echo "#-----------------------------------------------------"
    echo "#  Infrastructure module $MODULE created              "
    echo "#-----------------------------------------------------"
done