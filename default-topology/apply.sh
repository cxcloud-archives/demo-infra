#!/usr/bin/env bash

set -euo pipefail

function help(){
    echo "";
    echo "Usage: apply.sh [-d directory ...] [-f] [-u] environment aws_profile";
    echo "Options:";
    echo "-f           : auto-approve plan";
    echo "-u           : upgrade modules";
    echo "-d directory : dir where to run terraform apply, defaults to:"
    echo "               shared backend frontend process-engine merchant-center";
    echo ""
    exit 1;
}

DIRS=""
AUTO_APPROVE=""
UPGRADE=""

while getopts ":d:fu" opt; do
  case $opt in
    d)
      DIRS+="$OPTARG "
      ;;
    u)
      UPGRADE="-upgrade"
      ;;
    f)
      AUTO_APPROVE="-auto-approve"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift "$((OPTIND-1))"

if [[ $# -ne 2 ]]; then
    help
fi

export ENVIRONMENT=$1
export AWS_PROFILE=$2

# source GITHUB_TOKEN, see https://www.terraform.io/docs/providers/aws/r/codepipeline.html
source ./secrets-env.sh

export TF_IN_AUTOMATION=true

if [[ $DIRS == "" ]]; then
    DIRS="shared backend frontend process-engine merchant-center"
fi

for DIR in $DIRS; do
    echo ""
    echo "#-----------------------------------------------------"
    echo "#  Applying changes to $DIR on $ENVIRONMENT           "
    echo "#-----------------------------------------------------"
    echo ""

    cd $DIR
    terraform init -input=false $UPGRADE
    terraform workspace new $ENVIRONMENT || true
    terraform workspace 'select' $ENVIRONMENT
    GITHUB_TOKEN=$GITHUB_TOKEN terraform apply $AUTO_APPROVE -var-file ../application.tfvars -var-file ../secrets.tfvars
    cd ..
    echo ""
    echo "#-----------------------------------------------------"
    echo "#  Changes applied to $DIR on $ENVIRONMENT            "
    echo "#-----------------------------------------------------"
    echo ""
done