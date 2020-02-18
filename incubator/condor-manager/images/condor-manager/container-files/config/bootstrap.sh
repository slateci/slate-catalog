#!/usr/bin/env bash
  
set -e
set +x

# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

condor_token_create -identity submit@pool > /submit_token
condor_token_create -identity worker@pool > /worker_token

exec supervisord -n $SUPERVISOR_PARAMS
