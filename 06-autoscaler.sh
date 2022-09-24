#!/bin/bash
source 00-envs.sh

echo "Installing Autoscaler"
kops get cluster --name ${NAME} -o yaml > ./cluster_config.yaml
cat << EOF > ./extra_policies.yaml
spec:
  additionalPolicies:
    node: |
      [
        {
          "Effect":"Allow",
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeTags",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeImages",
            "ec2:GetInstanceTypesFromInstanceRequirements"
          ],
          "Resource":"*"
        }
      ]
EOF
#yq merge -a append --overwrite --inplace ./cluster_config.yaml ./extra_policies.yaml
yq eval-all --inplace '. as $item ireduce ({}; . * $item )' ./cluster_config.yaml ./extra_policies.yaml
aws s3 cp ./cluster_config.yaml ${KOPS_STATE_STORE}/${NAME}/config
kops update cluster --state=${KOPS_STATE_STORE} --name=${NAME} --yes

curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add stable https://charts.helm.sh/stable
helm version --short

helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm upgrade --install cluster-autoscaler-1.21.1  autoscaler/cluster-autoscaler \
  --set fullnameOverride=cluster-autoscaler \
  --set nodeSelector."kops\.k8s\.io/lifecycle"=OnDemand \
  --set cloudProvider=aws \
  --set extraArgs.scale-down-enabled=true \
  --set extraArgs.expander=random \
  --set extraArgs.balance-similar-node-groups=true \
  --set extraArgs.scale-down-unneeded-time=2m \
  --set extraArgs.scale-down-delay-after-add=2m \
  --set autoDiscovery.clusterName=${NAME} \
  --set rbac.create=true \
  --set awsRegion=${AWS_REGION} \
  --wait

kubectl logs -f deployment/cluster-autoscaler --tail=10

#kops rolling-update cluster
#kubectl --namespace=default get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler,app.kubernetes.io/instance=cluster-autoscaler-1.21.1"
#kubectl logs -f deployment/cluster-autoscaler | grep -I scale_up
#kubectl scale --replicas=20 deployment/nginx-deployment