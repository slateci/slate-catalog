FROM centos:7

RUN \
  yum update -y && \
  yum install -y epel-release

RUN \
  yum install -y openssh-server pwgen supervisor authconfig
  
RUN yum install openssl -y \
    yum install -y openldap-clients pam_ldap nss-pam-ldap authconfig 

RUN \
  echo > /etc/sysconfig/i18n

RUN \
  yum clean all && rm -rf /tmp/yum*

ADD container-files /

ENTRYPOINT ["/config/bootstrap.sh"]
