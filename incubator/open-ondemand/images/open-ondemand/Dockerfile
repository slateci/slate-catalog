FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget openssh-server openssh-clients nfs-utils autofs

# Install sssd components
RUN yum install -y sssd realmd oddjob adcli && \
    yum install -y krb5-workstation openldap-clients policycoreutils-python

# Install Ruby 2.7, Node.js 10, and Development Tools
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby27
RUN yum install -y rh-nodejs10
RUN yum groupinstall -y 'Development Tools'

# Copy in the filesystem-map
COPY filesystem.txt /root
WORKDIR /root

# Install OnDemand
RUN yum install -y https://yum.osc.edu/ondemand/2.0/ondemand-release-web-2.0-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all
RUN yum install ondemand-selinux -y

# Install openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# Remove auth_openidc.conf
RUN rm -f /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Configure shel application
RUN mkdir -p /etc/ood/config/clusters.d
RUN mkdir -p /opt/ood/linuxhost_adapter
WORKDIR /opt/ood/linuxhost_adapter
RUN yum update -y
RUN mkdir -p /etc/ood/config/apps && mkdir -p /etc/ood/config/apps/shell
COPY startup-apache.sh /opt/rh/httpd24/root/etc/httpd/conf.d/startup-apache.sh

# Configure Desktop application
RUN mkdir -p /etc/ood/config/apps/bc_desktop/single_cluster
RUN mkdir /etc/ood/config/apps/bc_desktop/submit
RUN mv /var/www/ood/apps/sys/bc_desktop/form.yml /var/www/ood/apps/sys/bc_desktop/form.yml.org
RUN mv /var/www/ood/apps/sys/bc_desktop/submit.yml.erb /var/www/ood/apps/sys/bc_desktop/submit.yml.erb.org

# Some security precautions
RUN chmod 0700 /opt/rh/httpd24/root/etc/httpd/conf.d/startup-apache.sh

COPY supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]