FROM perfsonar/testpoint:latest
LABEL maintainer="SLATE Team"

ADD run-my-tests.sh /usr/local/bin/run-my-tests.sh
ADD supervisord.conf /etc/supervisord.conf
CMD /usr/bin/supervisord -c /etc/supervisord.conf
#ENTRYPOINT ["pscheduler", "troubleshoot"]
