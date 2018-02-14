#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] ; then
    echo 'Usage: create-backend aws-profile'
    exit 1
fi

export AWS_PROFILE=$1
export TF_IN_AUTOMATION=true

cd tfs3backend

terraform init
terraform apply -auto-approve