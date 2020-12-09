FROM opensciencegrid/software-base:fresh
LABEL description="File Transfer Service from CERN"
LABEL maintainer lincolnb@uchicago.edu

ADD "http://fts-repo.web.cern.ch/fts-repo/fts3-prod-el7.repo" "/etc/yum.repos.d/"
RUN yum install -y osg-ca-certs yum-plugin-priorities gfal2-all osg-gridftp gfal2-util fts-server fts-client fts-rest fts-monitoring fts-mysql fts-server-selinux fts-rest-selinux fts-monitoring-selinux fts-msg fts-infosys cronie crontabs supervisor

ADD fetch-crl /etc/cron.d/fetch-crl
RUN chmod 644 /etc/cron.d/fetch-crl

#COPY fts3config etc/fts3/fts3config
#COPY fts-msg-monitoring.conf etc/fts3/fts-msg-monitoring.conf
#COPY fts-diff-4.0.1.sql /usr/share/fts-mysql/fts-diff-4.0.1.sql

COPY 10-fts.conf /etc/supervisord.d/
COPY 20-fts-config.sh /etc/osg/image-config.d/

ENTRYPOINT ["/usr/local/sbin/supervisord_startup.sh"]
