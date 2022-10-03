#!/bin/bash
source 00-envs.sh


echo "Creating spot instance groups"
kops toolbox instance-selector "spot-group-base-4vcpus-16gb" \
--usage-class spot --cluster-autoscaler \
--base-instance-type "m5.xlarge" --burst-support=false \
--deny-list '^?[1-3].*\..*' --gpus 0 \
--node-count-max 5 --node-count-min 1 \
--name ${NAME}

kops toolbox instance-selector "spot-group-base-2vcpus-8gb" \
--usage-class spot --cluster-autoscaler \
--base-instance-type "m5.large" --burst-support=false \
--deny-list '^?[1-3].*\..*' --gpus 0 \
--node-count-max 5 --node-count-min 1 \
--name ${NAME}

kops update cluster --state=${KOPS_STATE_STORE} --name=${NAME} --yes --admin
kops validate cluster --wait 10m

