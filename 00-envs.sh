#!/bin/bash
#cluster name
export NAME=myfirstcluster.k8s.local

#kop state prefix
export KOPS_STATE_PREFIX=ghfrg45d325r-kops-state

#kops state store
export KOPS_STATE_STORE=s3://${KOPS_STATE_PREFIX}

#aws region
export AWS_REGION=us-east-1

#aws availability zones
export AWS_REGION_AZS=us-east-1a

#export AWS_REGION_AZS=$(aws ec2 describe-availability-zones \
#--region ${AWS_REGION} \
#--query 'AvailabilityZones[0:3].ZoneName' \
#--output text | \
#sed 's/\t/,/g')



