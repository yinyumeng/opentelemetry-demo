#!/bin/bash

# Env Vars
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')



# obtain OSIS endpoints
export OSIS_TRACES_URL=$(aws osis get-pipeline --pipeline-name osi-pipeline-oteltraces --region $AWS_REGION | jq -r '.Pipeline.IngestEndpointUrls[0]')
export OSIS_LOGS_URL=$(aws osis get-pipeline --pipeline-name osi-pipeline-otellogs --region $AWS_REGION | jq -r '.Pipeline.IngestEndpointUrls[0]')
export OSIS_METRICS_URL=$(aws osis get-pipeline --pipeline-name osi-pipeline-otelmetrics --region $AWS_REGION | jq -r '.Pipeline.IngestEndpointUrls[0]')

#configure OSIS endpoints and region
sed -i -e "s/__REPLACE_WITH_OtelTraces_ENDPOINT__/${OSIS_TRACES_URL}/g" src/otelcollector/otelcol-config.yml
sed -i -e "s/__REPLACE_WITH_OtelLogs_ENDPOINT__/${OSIS_LOGS_URL}/g" src/otelcollector/otelcol-config.yml
sed -i -e "s/__REPLACE_WITH_OtelMetrics_ENDPOINT__/${OSIS_METRICS_URL}/g" src/otelcollector/otelcol-config.yml
sed -i -e "s/__AWS_REGION__/${AWS_REGION}/g" src/otelcollector/otelcol-config.yml


