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

RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/osg.repo
RUN echo -e "[osg-upcoming]\nname=OSG Software for Enterprise Linux 7 - Upcoming - x86_64\nmirrorlist=https://repo.opensciencegrid.org/mirror/osg/upcoming/el7/release/x86_64\nfailovermethod=priority\npriority=97\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG" > /etc/yum.repos.d/osg-upcoming.repo

RUN yum -y install condor \ 
  openssh-clients \ 
  openssh-server \
  libXt \
  tcsh \
  gcc \
  libXpm \
  libXpm-devel \
  supervisor \
  unzip && \
  yum install http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm -y && \
  yum install HEP_OSlibs -y && \
  yum clean all

RUN mkdir -p /var/lib/condor/credentials

COPY worker.conf /etc/condor/config.d/

ENTRYPOINT ["/config/bootstrap.sh"]
