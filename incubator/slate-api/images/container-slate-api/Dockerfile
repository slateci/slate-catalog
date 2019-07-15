FROM centos:centos7

#RUN yum update -y
RUN yum install epel-release -y
RUN yum install yaml-cpp -y

COPY aws-sdk.repo /etc/yum.repos.d/aws-sdk.repo
COPY slate-server.repo /etc/yum.repos.d/slate-server.repo

RUN yum install -y slate-api-server
RUN yum clean all && rm -rf /var/cache/yum

RUN curl -LO https://get.helm.sh/helm-v2.14.2-linux-amd64.tar.gz
RUN tar xzf helm-v2.14.2-linux-amd64.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm
RUN rm -rf helm-v2.14.2-linux-amd64.tar.gz linux-amd64

RUN mkdir -p /opt/slate-api-server
WORKDIR /opt/slate-api-server
ENTRYPOINT /usr/bin/slate-service
