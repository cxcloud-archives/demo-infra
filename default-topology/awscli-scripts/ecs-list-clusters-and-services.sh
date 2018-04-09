#!/usr/bin/env bash

set -euo pipefail

CLUSTER_ARNS=$(aws ecs list-clusters --query 'clusterArns' --output text)
MAX_CLUSTER_NAME=0

for ARN in $CLUSTER_ARNS; do
	CLUSTER_NAME=$(echo \"$ARN\" | jq -r 'split("/")[1]')
	if [ ${#CLUSTER_NAME} -gt $MAX_CLUSTER_NAME ]; then
		MAX_CLUSTER_NAME=${#CLUSTER_NAME}
	fi
done

printf "%-*s  %s\n" $MAX_CLUSTER_NAME "Cluster name" "Service name"
printf "%-*s  %s\n" $MAX_CLUSTER_NAME "------------" "------------"


for ARN in $CLUSTER_ARNS; do
    CLUSTER_NAME=$(echo \"$ARN\" | jq -r 'split("/")[1]')
    SERVICES=$(aws ecs list-services --cluster $CLUSTER_NAME --query 'serviceArns' --output text)

    for SERVICE in $SERVICES; do
        SERVICE_NAME=$(echo \"$SERVICE\" | jq -r 'split("/")[1]')
        printf "%-*s  %s\n" $MAX_CLUSTER_NAME $CLUSTER_NAME $SERVICE_NAME
    done

done
