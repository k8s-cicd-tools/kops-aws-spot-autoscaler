#!/bin/bash
source 00-envs.sh

echo "Deleting cluster ${NAME}"
kops delete cluster --name ${NAME} --yes
