FROM centos/systemd:latest

RUN yum update -y
RUN yum install epel-release -y
RUN yum install https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm -y

RUN yum install osg-gridftp osg-ca-certs yum-plugin-priorities gfal2-all gfal2-util globus-proxy-utils -y

COPY docker-entrypoint.sh tmp/docker-entrypoint.sh
ENTRYPOINT sh tmp/docker-entrypoint.sh 
