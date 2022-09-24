#!/bin/bash
source 00-envs.sh

# Labeling all nodes as OnDemand
echo "Labeling all nodes as OnDemand"
for availability_zone in $(echo ${AWS_REGION_AZS} | sed 's/,/ /g')
do
  NODEGROUP_NAME=nodes-${availability_zone}
  echo "Updating configuration for group ${NODEGROUP_NAME}"
  cat << EOF > ./nodes-extra-labels.yaml
spec:
  nodeLabels:
    kops.k8s.io/lifecycle: OnDemand
EOF
  kops get instancegroups --name ${NAME} ${NODEGROUP_NAME} -o yaml > ./${NODEGROUP_NAME}.yaml
  yq eval-all --inplace '. as $item ireduce ({}; . * $item )' ${NODEGROUP_NAME}.yaml ./nodes-extra-labels.yaml
  aws s3 cp ${NODEGROUP_NAME}.yaml ${KOPS_STATE_STORE}/${NAME}/instancegroup/${NODEGROUP_NAME}
done


#check the changes
for availability_zone in $(echo ${AWS_REGION_AZS} | sed 's/,/ /g')
do
  NODEGROUP_NAME=nodes-${availability_zone}
  kops get ig --name ${NAME} ${NODEGROUP_NAME} -o yaml | grep "lifecycle: OnDemand" > /dev/null
  if [ $? -eq 0 ]
  then
    echo "Instancegroup ${NODEGROUP_NAME} contains label kops.k8s.io/lifecycle: OnDemand"
  else
    echo "Instancegroup ${NODEGROUP_NAME} DOES NOT contains label kops.k8s.io/lifecycle: OnDemand"
  fi
done

kops get ig --name ${NAME} nodes-$(echo ${AWS_REGION_AZS}|cut -d, -f 1) -o yaml