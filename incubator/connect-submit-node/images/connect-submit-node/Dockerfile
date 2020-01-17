FROM opensciencegrid/software-base:fresh
LABEL maintainer "Lincoln Bryant <lincolnb@uchicago.edu>"

RUN yum update -y && yum install -y epel-release

RUN yum install -y openssh-server pwgen supervisor openssl
  
# Here comes the giant list of packages we lift from OSG Connect
RUN yum install -y \
  htop \ 
  gratia-probe-glideinwms \ 
  gratia-probe-common \
  gratia-probe-condor \
  emacs \ 
  vim-enhanced \
  nano \
  iotop \ 
  tmux \
  screen \
  zsh \
  tcsh \
  git \
  subversion \
  tcl \
  jq \
  python2-scitokens-credmon \
  stashcache-client \
  pegasus \
  @development \
  xorg-x11-xauth \
  xorg-x11-apps \
  bc \
  empty-ca-certs \
  glibc-static \
  wget \ 
  curl

# ??
#RUN echo > /etc/sysconfig/i18n

RUN yum clean all && rm -rf /tmp/yum*

ADD container-files /

CMD ["/usr/local/sbin/supervisord_startup.sh"]
