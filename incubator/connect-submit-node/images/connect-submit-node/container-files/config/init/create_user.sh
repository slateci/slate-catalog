#!/bin/bash
user=$USER
pwd=$PASSWORD
# Creating the www user only if it does not exist
ret=false
getent passwd $user >/dev/null 2>&1 && ret=true

if $ret; then
echo "user already exists";
else

useradd $user -d /data/$user
# Comments supose $user is www
# Setting password for the www user
echo "${user}:${pwd}" | chpasswd
# Add 'www' user to sudoers
echo "${user}  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/$user
echo "user created"
fi
