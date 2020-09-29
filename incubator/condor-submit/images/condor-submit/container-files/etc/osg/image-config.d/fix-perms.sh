cp -a /root/tokens/* /etc/condor/tokens.d/
chown -R condor: /etc/condor/tokens.d
chmod 400 /etc/condor/tokens.d/*
