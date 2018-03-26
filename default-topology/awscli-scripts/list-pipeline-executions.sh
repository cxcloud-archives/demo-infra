#!/usr/bin/env bash

function help(){
    echo "";
    echo "Usage: list-pipeline-executions.sh pipeline-name";
    exit 1;
}

if [[ $# -ne 1 ]]; then
    help
fi

PIPELINE_NAME=$1

EXECUTIONS=`aws codepipeline list-pipeline-executions --pipeline-name $PIPELINE_NAME --output json | jq '.pipelineExecutionSummaries[] | .startTime |= todate | .lastUpdateTime |= todate' | jq -r '[.pipelineExecutionId, .status, .startTime, .lastUpdateTime] | @tsv'`
echo -e "PipelineExecutionId                 \tStatus    \tStartTime           \tLastUpdateTime"
echo -e "====================================\t==========\t====================\t===================="
echo -e "$EXECUTIONS"