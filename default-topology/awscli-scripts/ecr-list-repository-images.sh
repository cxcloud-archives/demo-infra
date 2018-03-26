#!/usr/bin/env bash

set -euo pipefail


function help(){
    echo "";
    echo "Usage: ecr-list-repository-images.sh repository_name";
    exit 1;
}

if [[ $# -ne 1 ]]; then
    help
fi

REPOSITORY_NAME=$1

aws ecr describe-images --query 'imageDetails[*].{Repository:repositoryName,PushedAt:imagePushedAt,Tags:join(`, `, not_null(imageTags, `[]`))} | reverse(sort_by(@, &PushedAt))' --repository-name $REPOSITORY_NAME --output table