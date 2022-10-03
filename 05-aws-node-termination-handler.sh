#!/bin/bash
source 00-envs.sh

echo "Installing aws-node-termination-handler"

mkdir ~/environment
kops get cluster --name ${NAME} -o yaml > ~/environment/cluster_config.yaml
cat << EOF > ./node_termination_handler_addon.yaml
spec:
  nodeTerminationHandler:
    enabled: true
    enableSQSTerminationDraining: true
    managedASGTag: "aws-node-termination-handler/managed"
EOF

yq eval-all --inplace '. as $item ireduce ({}; . * $item )' ~/environment/cluster_config.yaml  ./node_termination_handler_addon.yaml
aws s3 cp ~/environment/cluster_config.yaml ${KOPS_STATE_STORE}/${NAME}/config
kops update cluster --state=${KOPS_STATE_STORE} --name=${NAME} --yes --admin
kubectl get deployment aws-node-termination-handler -n kube-system -o wide

kubectl apply -f https://github.com/aws/aws-node-termination-handler/releases/download/v1.17.2/all-resources.yaml
kubectl get pods -n kube-system

kubectl get deployment aws-node-termination-handler -n kube-system -o wide
echo "Waiting for aws-node-termination-handler to be ready"
