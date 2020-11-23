#!/bin/bash

# need to copy the certificate and key into the right place and chmod them
stat /root/gridftp-certificates
if [ $? -eq 0 ]; then 
  echo "Found certificate directory, trying to copy the files out"
  cp /root/gridftp-certificates/usercert.pem \
    /root/gridftp-certificates/userkey.pem  /etc/grid-certs/
  if [ $? -ne 0 ]; then 
    echo "Couldn't copy the certificates into place. Are you sure they're called hostcert and hostkey?"
  else
    echo "Setting proper mode on the certificate and key"
    chmod 600 /etc/grid-certs/usercert.pem
    chmod 400 /etc/grid-certs/userkey.pem
  fi
else 
  echo "Couldn't find a certificate directory. Doing nothing."
fi
