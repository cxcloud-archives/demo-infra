#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] ; then
    echo 'Usage: destroy-backend aws-profile'
    exit 1
fi

export AWS_PROFILE=$1
export TF_IN_AUTOMATION=true

cd tfs3backend
terraform destroy -force
