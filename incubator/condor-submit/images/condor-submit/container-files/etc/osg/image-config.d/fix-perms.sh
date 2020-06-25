cp -a /root/tokens/* /etc/condor/tokens.d/
chown -R condor: /etc/condor/tokens.d
chmod 400 /etc/condor/tokens.d/*
cp /root/condor_password /etc/condor/password
chown condor: /etc/condor/password
chmod 400 /etc/condor/password
