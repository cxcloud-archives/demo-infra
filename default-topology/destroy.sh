#!/usr/bin/env bash

set -euo pipefail

function help(){
    echo "";
    echo "Usage: destroy.sh [-d directory ...] [-f] environment aws_profile";
    echo "Options:";
    echo "-f           : do not ask confirmation";
    echo "-d directory : dir where to run terraform destroy, defaults to:"
    echo "               shared backend frontend process-engine merchant-center";
    echo ""
    exit 1;
}

DIRS=""
FORCE=""

while getopts ":d:f" opt; do
  case $opt in
    d)
      DIRS+="$OPTARG "
      ;;
    f)
      FORCE="-force"
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
    DIRS="backend frontend process-engine merchant-center shared"
fi

for DIR in $DIRS; do

    echo ""
    echo "#-----------------------------------------------------"
    echo "#  Destroying $DIR on $ENVIRONMENT                    "
    echo "#-----------------------------------------------------"
    echo ""

    cd $DIR

    terraform workspace 'select' $ENVIRONMENT

    terraform destroy $FORCE -var-file ../application.tfvars -var-file ../secrets.tfvars

    echo "Switching to default workspace"
    terraform workspace 'select' default

    echo "Deleting workspace $ENVIRONMENT"
    terraform workspace delete $ENVIRONMENT

    cd ..
done
