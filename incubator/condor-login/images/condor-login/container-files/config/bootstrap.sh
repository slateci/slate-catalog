#!/usr/bin/env bash

set -e
set +x 

# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

#if [ "$(ls /config/init/)" ]; then
#  for init in /config/init/*.sh; do
#    . $init
#  done
#fi

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
&& ssh-keygen -t dsa  -f /etc/ssh/ssh_host_dsa_key -N '' \
&& ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
&& ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
&& chmod 600 /etc/ssh/*

# Add new users
if [ -n "$PASSWDFILE" ]; then
  echo '$PASSWDFILE is set:' $PASSWDFILE
  bash config/init/new.sh $PASSWDFILE
else
  echo '$PASSWDFILE not defined! Not creating users'
fi

if [ -z "${KRBREALM+x}" ]; then
  echo 'Kerberos configuration is empty'
  echo 'Nothing to do'
else
  echo 'Kerberos configuration detected'
  echo 'Checking for KDC'
  if [ -z "${KRBKDC+x}" ]; then
    echo 'KDC configuration appears to be empty'
    echo 'Nothing to do'
  else
    echo "Attempting to use authconfig to enable Kerberos login at $KRBREALM"
    authconfig --enablekrb5 --krb5adminserver="" --krb5realm=$KRBREALM \
    --krb5kdc=$KRBKDC \
    --disablekrb5kdcdns --disablekrb5realmdns --enablelocauthorize --enablepamaccess \
    --disablenis --enablesssd --enablesssdauth --disablefingerprint --disablesmartcard --update
  fi
fi 

supervisord -n $SUPERVISOR_PARAMS
