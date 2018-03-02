#!/usr/bin/env bash
aws codepipeline list-pipelines --output text --query 'pipelines[*].{PipelineName:name}'