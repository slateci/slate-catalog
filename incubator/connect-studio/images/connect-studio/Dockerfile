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

# Make sure we have some needed dirs
RUN mkdir -p /etc/condor/passwords.d && \
    mkdir -p /etc/condor/tokens.d && \
    chown condor: /etc/condor/passwords.d && \
    chown condor: /etc/condor/tokens.d

## Now we create our shotgun wwedding of Condor submit and Jupyter
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ARG NB_USER="osg"
ARG NB_UID="1000"
ARG NB_GID="1000"

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR

ARG PYTHON_VERSION=default

ENV MINICONDA_VERSION=4.7.12.1 \
    MINICONDA_MD5=81c773ff87af5cfac79ab862942ab6b3 \
    CONDA_VERSION=4.7.12

USER 1000
WORKDIR $HOME

RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn && \

RUN conda install --quiet --yes \
    'notebook=6.0.3' \
    'jupyterhub=1.1.0' \
    'jupyterlab=1.2.5' && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \

EXPOSE 8888

CMD ["/usr/local/sbin/supervisord_startup.sh"]
