#!/usr/bin/env bash
aws ecr describe-repositories --query 'repositories[*].{Name:repositoryName,URI:repositoryUri}' --output table
