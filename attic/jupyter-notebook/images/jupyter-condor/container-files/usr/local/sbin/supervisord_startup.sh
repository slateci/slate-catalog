#!/bin/bash
# This is just for refrence and will be overriden by K8s manifest files
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
