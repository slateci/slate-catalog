FROM centos:7
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y sssd
RUN yum install -y authconfig
RUN yum install -y openssh-server
RUN yum install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /etc/startup.sh
# --enablesssd sets up nssswitch.conf with sssd
# --enablesssdauth sets up pam with sssd
RUN authconfig --update --enablesssd --enablesssdauth --enablemkhomedir
RUN chmod +x /etc/startup.sh
CMD ["/bin/sh", "-c", "/etc/startup.sh && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
