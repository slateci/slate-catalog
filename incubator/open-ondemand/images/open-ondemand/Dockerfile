FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager openssh-server openssh-clients && \
    yum install -y wget 

# Set up SSSD and edit PAM files
# RUN yum install -y sssd authconfig openldap oddjob-mkhomedir && \
#     yum clean all
# COPY sssd/sssd.conf /etc/sssd
# RUN chown root:root /etc/sssd/sssd.conf
# RUN chmod 600 /etc/sssd/sssd.conf
# WORKDIR /etc/pam.d
# RUN rm -f system-auth \
#     rm -f password-auth
# COPY sssd/PAM-system-auth ./system-auth
# COPY sssd/PAM-password-auth ./password-auth
# RUN chmod 744 system-auth
# RUN chmod 744 password-auth
# RUN authconfig --update --enablesssd --enablesssdauth --enablemkhomedir

# Install Ruby 2.5 and Node.js 10
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby25
RUN yum install -y rh-nodejs10

# Copy in the filesystem-map
COPY filesystem.txt /root
WORKDIR /root

# Install OnDemand
RUN yum install -y https://yum.osc.edu/ondemand/1.8/ondemand-release-web-1.8-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all
RUN yum install ondemand-selinux -y

# Install openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# Remove auth_openidc.conf
RUN rm -f /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Configure shel application
RUN mkdir /etc/ood/config/clusters.d
RUN mkdir /opt/ood/linuxhost_adapter
WORKDIR /opt/ood/linuxhost_adapter
RUN yum update -y
RUN mkdir /etc/ood/config/apps && mkdir /etc/ood/config/apps/shell
COPY env /etc/ood/config/apps/shell/env
COPY startup.sh /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh
WORKDIR /root

# Configure Desktop application
RUN mkdir /etc/ood/config/apps/bc_desktop
RUN mkdir /etc/ood/config/apps/bc_desktop/single_cluster
RUN mv /var/www/ood/apps/sys/bc_desktop/form.yml /var/www/ood/apps/sys/bc_desktop/form.yml.org
RUN mv /var/www/ood/apps/sys/bc_desktop/submit.form.yml.erb /var/www/ood/apps/sys/bc_desktop/submit.form.yml.erb.org

# Configure SSH
RUN sed -i 's/#   HostbasedAuthentication no/   HostBasedAuthentication yes\n   EnableSSHKeysign yes/g' /etc/ssh/ssh_config
RUN chgrp ssh_keys /etc/ssh/*_key
RUN chmod g+r /etc/ssh/*_key

# Some security precautions
RUN chmod 0700 /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]