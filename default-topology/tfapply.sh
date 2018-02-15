#!/usr/bin/env bash

set -euo pipefail

function help(){
    echo "";
    echo "Usage: tfapply.sh [-m module ...] [-f] environment aws_profile";
    echo "Options:";
    echo "-f           : skip interactive plan approval by auto-approving it";
    echo "-d directory : dir where to run terraform apply, defaults to: shared backend frontend";
    echo ""
    exit 1;
}

DIRS=""
AUTO_APPROVE=""

while getopts "m:f" opt; do
  case $opt in
    m)
      DIRS+="$OPTARG "
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

export TF_IN_AUTOMATION=true

if [[ $DIRS == "" ]]; then
    DIRS="shared backend frontend"
fi

for DIR in $DIRS; do
    echo ""
    echo "#-----------------------------------------------------"
    echo "#  Creating infrastructure module $DIR                "
    echo "#-----------------------------------------------------"
    echo ""

    cd $DIR
    terraform init
    terraform workspace new $ENVIRONMENT || true
    terraform apply $AUTO_APPROVE -var-file ../application.tfvars -var-file ../secrets.tfvars
    cd ..
    echo ""
    echo "#-----------------------------------------------------"
    echo "#  Infrastructure module $DIR created                 "
    echo "#-----------------------------------------------------"
    echo ""
done