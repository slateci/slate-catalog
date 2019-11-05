#!/bin/sh

if [ $# -ne 3 ]; then
  echo "usage: log-jenkins.sh jobname buildnumber status"
  exit 1
fi

# just in case
JOB_NAME=${1:-unknown_job}
BUILD_NUMBER=${2:-unknown_build}
STATUS=${3:-unknown_status}

RESULTS="/usr/share/nginx/html/buildresults/$JOB_NAME/${BUILD_NUMBER}-log.txt"
URL="https://$(hostname)/buildresults/$JOB_NAME/${BUILD_NUMBER}-log.txt"

mkdir -p /usr/share/nginx/html/buildresults/$JOB_NAME
sed 's|.\[8m[^[]*.\[0m||g' /var/lib/jenkins/jobs/$JOB_NAME/builds/$BUILD_NUMBER/log > $RESULTS
echo $STATUS >> $RESULTS

# return the url for the results
echo $URL
