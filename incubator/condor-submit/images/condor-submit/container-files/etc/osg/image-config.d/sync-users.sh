# Add new users
if [ -n "$PASSWDFILE" ]; then
  echo '$PASSWDFILE is set:' $PASSWDFILE
  bash config/init/new.sh $PASSWDFILE
else
  echo '$PASSWDFILE not defined! Not creating users'
fi

if [ -n "$API_TOKEN" ] && [ -n "$USER_GROUP" ] && [ -n "$GROUP_GROUP" ]; then
  echo "Using Connect API for syncing users"
  cd /usr/local/etc/ciconnect
  bash /usr/local/sbin/sync_users.sh -u $USER_GROUP -g $GROUP_GROUP -e https://api.ci-connect.net:18080
  for i in $(awk '{ FS=":"; if ($3>10000) print $1}' /etc/passwd); do sed -i "s/$i:\!\!/$i:x/" /etc/shadow; done;
  cp _config config
  chmod 600 config
  echo "export API_TOKEN=$API_TOKEN" >> config
  cd -
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
