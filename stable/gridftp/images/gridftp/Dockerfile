FROM opensciencegrid/software-base:fresh
LABEL lastupdate=12-16-2020

RUN yum update -y
RUN yum install osg-gridftp osg-ca-certs yum-plugin-priorities gfal2-all gfal2-util globus-proxy-utils -y

# Set up the users and host certificate
COPY image-config/10-users.sh /etc/osg/image-config.d/
COPY image-config/20-certificate.sh /etc/osg/image-config.d/

# do the bad thing of overwriting the existing cron job for fetch-crl
ADD fetch-crl /etc/cron.d/fetch-crl
RUN chmod 644 /etc/cron.d/fetch-crl

# We also copy in our own gridftp server launcher to overwrite the existing one
COPY globus-gridftp-server-start /usr/libexec/globus-gridftp-server-start
RUN chmod 755 /usr/libexec/globus-gridftp-server-start

# take a bunch of gridftp options as environment variables and then become gridftp
#COPY gridftp-startup.sh /usr/local/sbin/gridftp-startup.sh
#RUN chmod +x /usr/local/sbin/gridftp-startup.sh

# Create the appropriate supervisor job to launch gridftp
COPY supervisor/gridftp.conf /etc/supervisord.d/

ENTRYPOINT ["/usr/local/sbin/supervisord_startup.sh"]
