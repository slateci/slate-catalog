#!/bin/bash
# Create Homedirs
mkdir -p $(ls -1 -d /var/log/ondemand-nginx/*/ | tr -d '/' | \
sed 's/\(varlogondemand-nginx\)//g' | xargs -L 1 echo /home/ | tr -d ' ')
# Chown homedirs
ls -1 -d /home/*/ | tr -d '/' | sed 's/\(home\)//g' | sed p | paste - - | xargs -L 1 chown