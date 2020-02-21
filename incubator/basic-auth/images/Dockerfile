FROM centos:7

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y sssd authconfig openssh-server supervisor && \
    yum clean all

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /etc/startup.sh

# --enablesssd sets up nssswitch.conf with sssd
# --enablesssdauth sets up pam with sssd
RUN authconfig --update --enablesssd --enablesssdauth --enablemkhomedir

RUN chmod +x /etc/startup.sh

CMD ["/bin/sh", "-c", "/etc/startup.sh && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]