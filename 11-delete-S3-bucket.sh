#!/bin/bash
source 00-envs.sh


#delete all the objects in the versioned s3 bucket
aws s3 rm s3://${KOPS_STATE_STORE} --recursive


#delete S3 bucket
echo "Deleting S3 bucket ${KOPS_STATE_PREFIX}"
aws s3 rb s3://${KOPS_STATE_PREFIX} --force

