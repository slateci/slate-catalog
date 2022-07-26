#!/bin/bash -e

# certs
cp /tmp/fts3-host-pems/hostcert.pem /etc/grid-security/
chmod 644 /etc/grid-security/hostcert.pem
chown root:root /etc/grid-security/hostcert.pem
cp /tmp/fts3-host-pems/hostkey.pem /etc/grid-security/
chmod 400 /etc/grid-security/hostkey.pem
chown root:root /etc/grid-security/hostkey.pem

# cp /tmp/fts3-configs/ca.crt /etc/grid-security/certificates/docker-entrypoint_ca.crt
# cp /tmp/fts3-configs/fts3config /etc/fts3/fts3config
# cp /tmp/fts3-configs/fts-msg-monitoring.conf /etc/fts3/fts-msg-monitoring.conf

mkdir -p /var/log/fts3rest/ && touch /var/log/fts3rest/fts3rest.log

chown fts3:fts3 /var/log/
chown fts3:fts3 /var/log/fts3rest/fts3rest.log

#touch /var/lib/mysql/mysql.sock

if [[ ! -z "${DATABASE_UPGRADE}" ]]; then
   yes Y | python /usr/share/fts/fts-database-upgrade.py
fi
if [[ ! -z "${REST_HOST}" ]]; then
   replaceCommand="sed -i -e 's/*/${REST_HOST}/g' /etc/httpd/conf.d/fts3rest.conf"
   eval $replaceCommand
fi
if [[ -z "${WEB_INTERFACE}" ]]; then
   rm /etc/httpd/conf.d/ftsmon.conf
fi

# do a oneshot fetch-crl
fetch-crl
