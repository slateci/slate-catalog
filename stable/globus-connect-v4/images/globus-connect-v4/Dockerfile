FROM centos:7
LABEL maintainer lincolnb@uchicago.edu

RUN yum update -y

RUN yum install epel-release -y
RUN curl -LOs https://downloads.globus.org/toolkit/globus-connect-server/globus-connect-server-repo-latest.noarch.rpm
RUN rpm --import https://downloads.globus.org/toolkit/gt6/stable/repo/rpm/RPM-GPG-KEY-Globus
RUN yum install globus-connect-server-repo-latest.noarch.rpm -y

RUN yum install yum-plugin-priorities -y
RUN yum install globus-connect-server supervisor -y 

COPY supervisord.conf /etc/supervisord.conf
COPY supervisord_startup.sh /usr/local/bin/supervisord_startup.sh
RUN chmod +x /usr/local/bin/supervisord_startup.sh

ENTRYPOINT ["/usr/local/bin/supervisord_startup.sh"]
