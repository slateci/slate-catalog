#!/bin/bash

# need to copy the certificate and key into the right place and chmod them
if [ $(stat /root/gridftp-certificates) ]; then 
  echo "Found certificate directory, trying to copy the files out"
  cp /root/gridftp-certificates/hostcert.pem \
    /root/gridftp-certificates/hostkey.pem  /etc/grid-security
  if [ $? -ne 0 ]; then 
    echo "Couldn't copy the certificates into place. Are you sure they're called hostcert and hostkey?"
  else
    echo "Setting proper mode on the certificate and key"
    chmod 600 /etc/grid-security/hostcert.pem
    chmod 400 /etc/grid-security/hostkey.pem
  fi
else 
  echo "Couldn't find a certificate directory. Doing nothing."
fi
