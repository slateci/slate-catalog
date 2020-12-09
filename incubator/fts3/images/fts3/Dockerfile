FROM centos:7
LABEL description="File Transfer Service from CERN"
LABEL maintainer lincolnb@uchicago.edu

ADD "http://fts-repo.web.cern.ch/fts-repo/fts3-prod-el7.repo" "/etc/yum.repos.d/"

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm
RUN yum update -y
RUN yum install -y osg-ca-certs yum-plugin-priorities gfal2-all osg-gridftp gfal2-util fts-server fts-client fts-rest fts-monitoring fts-mysql fts-server-selinux fts-rest-selinux fts-monitoring-selinux fts-msg fts-infosys cronie crontabs supervisor

COPY crontab /etc/crontab
COPY supervisord.conf etc/supervisord.conf

#COPY fts3config etc/fts3/fts3config
#COPY fts-msg-monitoring.conf etc/fts3/fts-msg-monitoring.conf

COPY docker-entrypoint.sh tmp/docker-entrypoint.sh 

#COPY fts-diff-4.0.1.sql /usr/share/fts-mysql/fts-diff-4.0.1.sql

ENTRYPOINT sh tmp/docker-entrypoint.sh
