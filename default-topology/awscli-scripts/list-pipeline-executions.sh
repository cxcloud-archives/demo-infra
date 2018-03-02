#!/usr/bin/env bash
EXECUTIONS=`aws codepipeline list-pipeline-executions --pipeline-name cxcloud-backend --output json | jq '.pipelineExecutionSummaries[] | .startTime |= todate | .lastUpdateTime |= todate' | jq -r '[.pipelineExecutionId, .status, .startTime, .lastUpdateTime] | @tsv'`
echo -e "PipelineExecutionId                 \tStatus    \tStartTime           \tLastUpdateTime"
echo -e "====================================\t==========\t====================\t===================="
echo -e "$EXECUTIONS"