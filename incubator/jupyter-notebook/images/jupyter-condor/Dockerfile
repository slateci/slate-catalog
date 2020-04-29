FROM jupyter/scipy-notebook:latest

USER root
RUN apt-get update
RUN apt-get install -y gnupg
RUN apt-get install -y supervisor wget openssh-server
RUN wget -qO - https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | apt-key add -
RUN echo "deb http://research.cs.wisc.edu/htcondor/ubuntu/8.9/bionic bionic contrib" >> /etc/apt/sources.list
RUN echo "deb-src http://research.cs.wisc.edu/htcondor/ubuntu/8.9/bionic bionic contrib" >> /etc/apt/sources.list

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y condor
RUN pip install htcondor

RUN mkdir -p /var/log/supervisor
ADD container-files /
RUN mkdir -p /var/run/sshd /var/log/supervisor
# Make sure we have some needed dirs
RUN mkdir -p /etc/condor/passwords.d && \
    mkdir -p /etc/condor/tokens.d && \
    chown condor: /etc/condor/passwords.d && \
    chown condor: /etc/condor/tokens.d
CMD ["/usr/local/sbin/supervisord_startup.sh"]

