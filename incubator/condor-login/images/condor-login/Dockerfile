FROM opensciencegrid/osg-wn:3.4-devel-el7

RUN yum update -y 
 
#RUN yum install -y epel-release

RUN yum install -y openssh-server pwgen supervisor
  
RUN yum install openssl -y

# Support flocking

RUN yum -y install osg-flock
RUN yum -y install cronie

# Copy the Gratia probe into the correct place
RUN cp /etc/gratia/condor/ProbeConfig-flocking /etc/gratia/condor/ProbeConfig

# not sure what this does. can we remove it?
RUN echo > /etc/sysconfig/i18n

RUN yum clean all && rm -rf /tmp/yum*

ADD container-files /

# we dont need osg-upcoming.
#RUN echo -e "[osg-upcoming]\nname=OSG Software for Enterprise Linux 7 - Upcoming - x86_64\nmirrorlist=https://repo.opensciencegrid.org/mirror/osg/upcoming/el7/release/x86_64\nfailovermethod=priority\npriority=97\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG" > /etc/yum.repos.d/osg-upcoming.repo

RUN yum -y install condor \ 
  openssh-clients \ 
  openssh-server \
  libXt \
  tcsh \
  gcc \
  libXpm \
  libXpm-devel \
  unzip && \
  yum install http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm -y && \
  yum install HEP_OSlibs -y && \
  yum clean all

# not needed for now
#RUN mkdir -p /var/lib/condor/credentials

RUN sed -i 's/EnableProbe="0"/EnableProbe="1"/' /etc/gratia/condor/ProbeConfig

COPY worker.conf /etc/condor/config.d/

ADD fetch-crl /etc/cron.d/

ENTRYPOINT ["/config/bootstrap.sh"]
