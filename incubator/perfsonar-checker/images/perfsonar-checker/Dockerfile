FROM perfsonar/testpoint:v4.3.4
LABEL maintainer="SLATE Team"

#ADD run-my-tests.sh /usr/local/bin/run-my-tests.sh
ADD run-perfsonar-tests.sh /usr/local/bin/run-perfsonar-tests.sh
ADD supervisord.conf /etc/supervisord.conf
CMD /usr/bin/supervisord -c /etc/supervisord.conf
