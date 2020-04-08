#!/bin/bash

# check for configmap / volume with users to be created
stat /root/passwd
if [[ $? -eq 0 ]]; then
	#set the internal field splitter to colon to parse /etc/passwd-like files
	IFS=':'
	# loop through every line of the config map / passwd file and create the user,
	# unlock them, and add their public key
    cp /root/passwd /root/passwd1
    # small sanitization of the passwd file.
    # kubernetes will strip newlines, but we need at least one so the while 
    # loop can read the file.  this strips any empty lines after..
    sed -i '/^$/d' /root/passwd1
	while read -r user pass uid gid comment home shell; do
		echo "username is: " $user
		echo "password is: xxxxxxx"  # we dont watn to print out the password, actually
		echo "uid is: " $uid
		echo "gid is: " $gid
		echo "comment is: " $comment
		echo "home is: " $home
		echo "shell is: " $shell

		if [[ $pass == "" ]]; then
			echo "password seems to be empty.. cowardly refusing to continue"
			break
		fi
		useradd $user -d $home -u $uid -s $shell -p $pass

	done < /root/passwd1
fi


# check for a globus_server defined as an environment variable. if we get one,
# check to see if it has a port attached. if there is, comment out the default
# port so globus can do whatever with its gridftp.d file
if [ -z "$GLOBUS_SERVER" ]; then
  echo "GLOBUS_SERVER is undefined"
else
  GLOBUS_PORT=$(echo "$GLOBUS_SERVER" | cut -d':' -f2 -s)
  # if we actually get a port out of that, then comment out the gridftp defualt
  if [ -z "$GLOBUS_PORT" ]; then
    echo "Globus port is an empty string, assume defaults"
  else
    sed -i 's/port/#port/' /etc/gridftp.conf
  fi
fi

# Run configuration
globus-connect-server-setup -v

# now we just run the init scripts and fork em off
/etc/init.d/myproxy-server start
/etc/init.d/globus-gridftp-server start

while true; do sleep 3600; done # we need to get some health checks in here

# Now we can actually start the supervisor
#exec /usr/bin/supervisord -c /etc/supervisord.conf
