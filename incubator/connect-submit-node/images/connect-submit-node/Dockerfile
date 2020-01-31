FROM opensciencegrid/software-base:fresh
LABEL maintainer "Lincoln Bryant <lincolnb@uchicago.edu>"

RUN yum update -y && yum install -y epel-release

# upcoming for tokens
RUN yum install -y --enablerepo=osg-upcoming \
  condor \
  openssh-server \
  pwgen \
  supervisor \
  openssl \
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

RUN yum clean all && rm -rf /tmp/yum*

ADD container-files /

CMD ["/usr/local/sbin/supervisord_startup.sh"]
