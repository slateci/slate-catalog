#!/bin/bash

# check for configmap / volume with users to be created
stat /root/passwd
if [[ $? -eq 0 ]]; then
    #set the internal field splitter to colon to parse /etc/passwd-like files
    IFS=':'
    # Copy the immutable Kubernetes version of this with a mutable version we
    # can clean up
    cp /root/passwd /root/passwd1
    # small sanitization of the passwd file.
    # kubernetes will strip newlines, but we need at least one so the while
    # loop can read the file.  this strips any empty lines after..
    sed -i '/^$/d' /root/passwd1
    while read -r user pass uid gid comment home shell; do
        echo "username is: " $user
        echo "password is: xxxxxxx" # we dont actually print it, but here for debugging
        echo "uid is: " $uid
        echo "gid is: " $gid
        echo "comment is: " $comment
        echo "home is: " $home
        echo "shell is: " $shell

        if [[ $pass == "" ]]; then
            #crypt(3) cannot hash a password to string literal 'x'
            #so this will effectively disable password login
            pass='x'
            break
        fi
        useradd $user -d $home -u $uid -s $shell -p $pass

    done < /root/passwd1
else
    echo "Couldn't find a passwd file. Doing nothing."
fi

