#!/bin/bash
source 00-envs.sh

echo "Creating S3 bucket ${KOPS_STATE_PREFIX}"
aws s3api create-bucket --bucket ${KOPS_STATE_PREFIX} --region ${AWS_REGION}

echo "Enabling versioning on S3 bucket ${KOPS_STATE_PREFIX}"
aws s3api put-bucket-versioning \
--bucket ${KOPS_STATE_PREFIX} \
--region ${AWS_REGION} \
--versioning-configuration Status=Enabled
