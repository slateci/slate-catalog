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
#  chmod +x /Users/nehalingareddy/neha_test/python_api/python/new/wookiee2187/container-files/config/init/new.sh
  bash config/init/new.sh $PASSWDFILE
#/Users/nehalingareddy/neha_test/python_api/python/new/wookiee2187/container-files/config/init/new.sh $PASSWDFILE
else
  echo '$PASSWDFILE not defined! Not creating users'
fi

supervisord -n $SUPERVISOR_PARAMS
