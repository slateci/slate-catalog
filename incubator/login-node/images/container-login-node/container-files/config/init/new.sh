#!/bin/bash -x 
if [[ $# -ne 1 ]]; then
  echo "Need at least one argument"
  exit 1
fi 
#set the internal field splitter to colon to parse /etc/passwd-like files
IFS=':'
FILE=$1
# loop through every line of the config map / passwd file and create the user,
# unlock them, and add their public key
if test -f "$FILE"; then
    while read -r user pass uid gid comment home shell key; do
        echo "username is: " $user
        echo "password is: " $pass # not used
        echo "uid is: " $uid
        echo "gid is: " $gid
        echo "comment is: " $comment
        echo "home is: " $home
        echo "shell is: " $shell
        echo "key is: " $key

        # Functions for the parsed values
        
        function add_group {
            groupadd -g $gid group$gid
        }
        function add_user {
          # add functions for adding the user $user 
            PASS=$(date +%s | sha256sum | base64 | head -c 32) # 32 character randomized password to unlock the account
            useradd $user -d /home/$user -u $uid -g $gid -s $shell -p $(openssl passwd -1 $PASS)
        }

        function add_key {
            mkdir -p /home/$user/.ssh
            echo $key >> /home/$user/.ssh/authorized_keys
            chown $user -R /home/$user
            chmod 700 /home/$user/.ssh
            chmod 600 /home/$user/.ssh/authorized_keys
        }

        # Run the functions
        echo "Adding group.."
        add_group
        echo 

        echo "Creating user.." 
        add_user
        echo

        echo "Adding key..." 
        add_key
        echo 

    done < $FILE
else
    echo "file does not exist"
    exit
fi
