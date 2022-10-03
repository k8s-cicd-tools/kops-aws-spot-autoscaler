FROM ubuntu:20.04

ENV YQ_VERSION=v4.26.1 \
    STERN_VERSION=1.11.0 \
    KOPS_VERSION=v1.21.0 \
    KUBECTL_VERSION=v1.21.0 \
    HELM_VERSION=v3.9.4 \
    AUTO_SCALER_VERSION=1.21.0 \
    AWS_PAGER=""

#install dependencies
RUN apt-get update && apt-get install -y \
    unzip vim iputils-ping ca-certificates curl\
    && rm -rf /var/lib/apt/lists/*


ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip .
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install
#install kubectl on linux
#1) download kubectl binary from https://kubernetes.io/docs/tasks/tools/install-kubectl/
ADD https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl .
#2) copy kubectl binary to /usr/local/bin/kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#3) verify kubectl is installed
RUN kubectl version --client
#4) install stern binary
ADD https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 .
#5) copy stern binary to /usr/local/bin/stern
RUN install -o root -g root -m 0755 stern_linux_amd64 /usr/local/bin/stern
#6) verify stern is installed
RUN stern --version
#7) install yq
ADD https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 /usr/bin/yq
RUN chmod +x /usr/bin/yq
#8) install Kops
ADD https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 .
RUN chmod +x kops-linux-amd64
RUN mv kops-linux-amd64 /usr/local/bin/kops
RUN kops version
#9) install helm
ADD https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz .
RUN tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 \
    && rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && helm version --client


#clean up
RUN rm stern_linux_amd64
RUN rm kubectl
RUN rm -rf aws
RUN rm awscli-exe-linux-x86_64.zip

WORKDIR /root

RUN apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/

ENTRYPOINT ["sleep", "infinity"]
