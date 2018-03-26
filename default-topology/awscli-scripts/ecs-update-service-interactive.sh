#!/usr/bin/env bash

set -euo pipefail

echo -e "Fetching ECS clusters and their services...\n"

./ecs-list-clusters-and-services.sh

echo ""
echo -n "Enter target cluster name: "
read CLUSTER_NAME

echo -n "Enter name of the service to be updated: "
read SERVICE_NAME

TASK_DEF_ARN=$(aws ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME --query "services[*].taskDefinition" --output text)
TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_DEF_ARN)

IMAGE=$(echo $TASK_DEF | jq '.taskDefinition.containerDefinitions[0].image')
REPOSITORY_NAME=$(echo $IMAGE | jq 'split(":")[0]' | jq -r 'split("/")[1]')
IMAGE_TAG=$(echo $IMAGE | jq -r 'split(":")[1]')

echo -e "\nFetching images...\n"

./ecr-list-repository-images.sh $REPOSITORY_NAME

echo ""
echo "Currently deployed image: $IMAGE"

echo -n "Enter tag of an image to be deployed: "
read NEW_IMAGE_TAG

echo ""
echo -n "Deploying image $NEW_IMAGE_TAG to service $SERVICE_NAME, type 'yes' to proceed: "
read CONFIRMATION

if [ "$CONFIRMATION" == "yes" ]; then
	echo -e "\nUpdating service..."
	./ecs-update-service.sh $CLUSTER_NAME $SERVICE_NAME $NEW_IMAGE_TAG >/dev/null
	echo "Service updated, waiting blue-green deployment to complete..."
	aws ecs wait services-stable --services $SERVICE_NAME --cluster $CLUSTER_NAME
	echo "Done"
fi