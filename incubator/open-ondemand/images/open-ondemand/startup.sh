#!/bin/bash
scl enable ondemand /var/www/ood/apps/sys/shell/bin/setup
mkdir /etc/ood/config/apps /etc/ood/config/apps/shell
touch /etc/ood/config/apps /etc/ood/config/apps/shell/env
cat <<EOF > /etc/ood/config/apps/shell/env
OOD_SSHHOST_ALLOWLIST=""
OOD_SHELL_ORIGIN_CHECK="off"
EOF
sleep 30
if [[ ! -f /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf ]]
then
    printf "OIDCProviderMetadataURL https://$(echo $SLATE_INSTANCE_NAME).keycloak.$(echo $SLATE_CLUSTER_NAME)/auth/realms/ondemand/.well-known/openid-configuration\n\
OIDCClientID        \"`cat /shared/id`\" \n\
OIDCClientSecret    \"`cat /shared/client-secret`\"\n\
OIDCRedirectURI      https://$(echo $SLATE_INSTANCE_NAME).ondemand.$(echo $SLATE_CLUSTER_NAME)/oidc\n\
OIDCCryptoPassphrase 'd14e5b4c8e6257ea81830f23c2be4633ad04d3af9816affdda6d8fec8ea926a000ca47b507587dc5'\n\
\n\
$(echo '# Keep sessions alive for 8 hours')\n\
OIDCSessionInactivityTimeout 28800\n\
OIDCSessionMaxDuration 28800\n\
\n\
$(echo '# Set REMOTE_USER')\n\
OIDCRemoteUserClaim preferred_username\n\
\n\
$(echo '# Do not pass claims to backend servers')\n\
OIDCPassClaimsAs environment\n\
\n\
$(echo '# Strip out session cookies before passing to backend')\n\
OIDCStripCookies mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1 " > '/opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf'
fi
# Configure apache
chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal
supervisorctl restart apache
# Set up SSSD
#chown root:root /etc/sssd/sssd.conf
#chmod 0600 /etc/sssd/sssd.conf
#authconfig --update --enablesssd --enablesssdauth --enablemkhomedir
# Set up incron
usermod -a G ondemand-nginx incronuser
sleep 10
supervisorctl restart incron
# Add users from Keycloak API
sleep 15
newusers /shared/newusers.txt