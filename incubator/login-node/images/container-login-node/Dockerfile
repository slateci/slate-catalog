FROM centos:latest 

RUN \
  yum update -y && \
  yum install -y epel-release

RUN \
  yum install -y openssh-server pwgen supervisor
  
RUN yum install openssl -y

RUN \
  echo > /etc/sysconfig/i18n

RUN \
  yum clean all && rm -rf /tmp/yum*

ADD container-files /

ENTRYPOINT ["/config/bootstrap.sh"]
