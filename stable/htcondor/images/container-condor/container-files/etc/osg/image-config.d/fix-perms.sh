mkdir -p /etc/condor/tokens.d
cp -a /root/tokens/* /etc/condor/tokens.d/
chown -R condor: /etc/condor/tokens.d
chmod 644 /etc/condor/tokens.d/*
