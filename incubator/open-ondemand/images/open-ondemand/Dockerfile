FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager openssh-server openssh-clients && \
    yum install -y wget 

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
RUN yum groupinstall 'Development Tools' -y
RUN yum update -y
RUN mkdir /etc/ood/config/apps && mkdir /etc/ood/config/apps/shell
COPY env /etc/ood/config/apps/shell/env
COPY startup.sh /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh
WORKDIR /root

# Configure Desktop application
RUN mkdir -p /etc/ood/config/apps/bc_desktop/single_cluster
RUN mkdir /etc/ood/config/apps/bc_desktop/submit
RUN mv /var/www/ood/apps/sys/bc_desktop/form.yml /var/www/ood/apps/sys/bc_desktop/form.yml.org
RUN mv /var/www/ood/apps/sys/bc_desktop/submit.yml.erb /var/www/ood/apps/sys/bc_desktop/submit.yml.erb.org

# Configure SSH
RUN sed -i 's/#   HostbasedAuthentication no/   HostBasedAuthentication yes\n   EnableSSHKeysign yes/g' /etc/ssh/ssh_config
# Some security precautions
RUN chmod 0700 /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]