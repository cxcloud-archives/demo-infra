#!/usr/bin/env bash

set -euo pipefail

CLUSTERS=$(aws ecs list-clusters --query 'clusterArns' --output text)


for CLUSTER in $CLUSTERS; do
    CLUSTER_NAME=$(echo \"$CLUSTER\" | jq -r 'split("/")[1]')
    SERVICES=$(aws ecs list-services --cluster $CLUSTER_NAME --query 'serviceArns' --output text)

    echo -e "Cluster name \tService name"
    echo -e "------------ \t------------"

    for SERVICE in $SERVICES; do
        SERVICE_NAME=$(echo \"$SERVICE\" | jq -r 'split("/")[1]')
        echo -e "$CLUSTER_NAME\t$SERVICE_NAME"
    done

done
