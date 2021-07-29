#!/bin/bash
scl enable ondemand /var/www/ood/apps/sys/shell/bin/setup
mkdir /etc/ood/config/apps /etc/ood/config/apps/shell
touch /etc/ood/config/apps /etc/ood/config/apps/shell/env
sed -i "/^Host */a \        HostBasedAuthentication yes\n        EnableSSHKeysign yes" /etc/ssh/ssh_config
cat <<EOF > /etc/ood/config/apps/shell/env
OOD_SSHHOST_ALLOWLIST=""
OOD_SHELL_ORIGIN_CHECK="off"
EOF
while [ ! -f /root/autofs_config.sh ]; do
  sleep 2
done
/root/autofs_config.sh
while [ ! -f /shared/id ]; do
  sleep 2
done
cat <<EOF > /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
OIDCProviderMetadataURL https://$(echo $SLATE_INSTANCE_NAME).keycloak.$(echo $SLATE_CLUSTER_NAME)/auth/realms/ondemand/.well-known/openid-configuration
OIDCClientID        "`cat /shared/id`" 
OIDCClientSecret    "`cat /shared/client-secret`"
OIDCRedirectURI      https://$(echo $SLATE_INSTANCE_NAME).ondemand.$(echo $SLATE_CLUSTER_NAME)/oidc
OIDCCryptoPassphrase 'd14e5b4c8e6257ea81830f23c2be4633ad04d3af9816affdda6d8fec8ea926a000ca47b507587dc5'

$(echo '# Keep sessions alive for 8 hours')
OIDCSessionInactivityTimeout 28800
OIDCSessionMaxDuration 28800

$(echo '# Set REMOTE_USER')
OIDCRemoteUserClaim preferred_username

$(echo '# Do not pass claims to backend servers')
OIDCPassClaimsAs environment

$(echo '# Strip out session cookies before passing to backend')
OIDCStripCookies mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1
EOF
# Configure apache
chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal
supervisorctl restart apache
# Generate users
#while read -r line; do
#  user=`echo $line | sed 's/:.*//'`
#  uid=`id $user | tr -s ' ' '\n'| grep uid | sed -r 's/uid=//g' | sed 's/(.*//'`
#  gid=`id $user | tr -s ' ' '\n'| grep gid | sed -r 's/gid=//g' | sed 's/(.*//'`
#  newline=`echo $line | perl -pe "s/(?<=::)a/$uid/" | perl -pe "s/(?<=:)b/$gid/"`
#  echo $newline >> /shared/newusers.txt
#done < /shared/blank_users.txt
supervisorctl restart autofs