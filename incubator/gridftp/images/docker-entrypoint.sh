#!/bin/bash -e

globusGridFTPString="globus-gridftp-server -l /dev/stdout"

#here check the environment variables to get the server command to evaluate
#appending each option to the server evalString defined above as it is detected
#that the option was set by the configurator
#Read http://toolkit.globus.org/toolkit/docs/latest-stable/gridftp/admin/#_options if you have questions
#and then ask for help if you have more of them. The blocks are commented with the relevant section
#of GridFTP documentation to which I have linked.

#1.4.2. Modes of Operation
if [[ ! -z "${GRIDFTP_INETD}" ]]; then
    globusGridFTPString="$globusGridFTPString -i ${GRIDFTP_INETD}"
fi
#if [[ ! -z "${GRIDFTP_DAEMON}" ]]; then
#    globusGridFTPString="$globusGridFTPString -daemon"
#fi
if [[ ! -z "${GRIDFTP_DETACH}" ]]; then
    globusGridFTPString="$globusGridFTPString -detach"
fi
if [[ ! -z "${GRIDFTP_SSH}" ]]; then
    globusGridFTPString="$globusGridFTPString -ssh"
fi
if [[ ! -z "${GRIDFTP_EXEC}" ]]; then
    globusGridFTPString="$globusGridFTPString -exec ${GRIDFTP_EXEC}"
fi
if [[ ! -z "${GRIDFTP_CHDIR}" ]]; then
    globusGridFTPString="$globusGridFTPString -chdir"
fi
if [[ ! -z "${GRIDFTP_CHDIRTO}" ]]; then
    globusGridFTPString="$globusGridFTPString -chdir-to ${GRIDFTP_CHDIRTO}"
fi
if [[ ! -z "${GRIDFTP_THREADS}" ]]; then
    globusGridFTPString="$globusGridFTPString -threads ${GRIDFTP_THREADS}"
fi
if [[ ! -z "${GRIDFTP_FORK}" ]]; then
    globusGridFTPString="$globusGridFTPString -exec ${GRIDFTP_FORK}"
fi
if [[ ! -z "${GRIDFTP_SINGLE}" ]]; then
    globusGridFTPString="$globusGridFTPString -single"
fi
if [[ ! -z "${GRIDFTP_CHROOTPATH}" ]]; then
    globusGridFTPString="$globusGridFTPString -chroot-path ${GRIDFTP_CHROOTPATH}"
fi

#1.4.3. Authentication, Authorization, and Security Options
if [[ ! -z "${GRIDFTP_AUTHLEVEL}" ]]; then
    globusGridFTPString="$globusGridFTPString -auth-level ${GRIDFTP_AUTHLEVEL}"
fi
if [[ ! -z "${GRIDFTP_IPCALLOWFROM}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-allow-from ${GRIDFTP_IPCALLOWFROM}"
fi
if [[ ! -z "${GRIDFTP_IPCDENYFROM}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-deny-from ${GRIDFTP_IPCDENYFROM}"
fi
if [[ ! -z "${GRIDFTP_ALLOWFROM}" ]]; then
    globusGridFTPString="$globusGridFTPString -allow-from ${GRIDFTP_ALLOWFROM}"
fi
if [[ ! -z "${GRIDFTP_DENYFROM}" ]]; then
    globusGridFTPString="$globusGridFTPString -deny-from ${GRIDFTP_DENYFROM}"
fi
if [[ ! -z "${GRIDFTP_SECUREIPC}" ]]; then
    globusGridFTPString="$globusGridFTPString -secure-ipc"
fi
if [[ ! -z "${GRIDFTP_IPCAUTHMODE}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-auth-mode ${GRIDFTP_DATAINTERFACE}"
fi
if [[ ! -z "${GRIDFTP_ALLOWANONYMOUS}" ]]; then
    globusGridFTPString="$globusGridFTPString -allow-anonymous"
fi
if [[ ! -z "${GRIDFTP_ANONYMOUSNAMESALLOWED}" ]]; then
    globusGridFTPString="$globusGridFTPString -anonymous-names-allowed ${GRIDFTP_ANONYMOUSNAMESALLOWED}"
fi
if [[ ! -z "${GRIDFTP_ANONYMOUSUSER}" ]]; then
    globusGridFTPString="$globusGridFTPString -anonymous-user ${GRIDFTP_ANONYMOUSUSER}"
fi
if [[ ! -z "${GRIDFTP_ANONYMOUSGROUP}" ]]; then
    globusGridFTPString="$globusGridFTPString -anonymous-group ${GRIDFTP_ANONYMOUSGROUP}"
fi
if [[ ! -z "${GRIDFTP_ALLOWSHARINGDN}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-dn ${GRIDFTP_ALLOWSHARINGDN}"
fi
if [[ ! -z "${GRIDFTP_SHARINGSTATEDIR}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-state-dir ${GRIDFTP_SHARINGSTATEDIR}"
fi
if [[ ! -z "${GRIDFTP_SHARINGCONTROL}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-control"
fi
if [[ ! -z "${GRIDFTP_SHARINGRP}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-rp ${GRIDFTP_SHARINGRP}"
fi
if [[ ! -z "${GRIDFTP_SHARINGUSERSALLOW}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-users-allow ${GRIDFTP_SHARINGUSERSALLOW}"
fi
if [[ ! -z "${GRIDFTP_SHARINGUSERSDENY}" ]]; then
    globusGridFTPString="$globusGridFTPString -sharing-users-deny ${GRIDFTP_SHARINGUSERSDENY}"
fi
if [[ ! -z "${GRIDFTP_ALLOWDENY}" ]]; then
    globusGridFTPString="$globusGridFTPString -allow-deny"
fi
if [[ ! -z "${GRIDFTP_ALLOWDISABLEDLOGIN}" ]]; then
    globusGridFTPString="$globusGridFTPString -allow-disabled-login"
fi
if [[ ! -z "${GRIDFTP_PASSWORDFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -password-file ${GRIDFTP_PASSWORDFILE}"
fi
if [[ ! -z "${GRIDFTP_CONNECTIONSMAX}" ]]; then
    globusGridFTPString="$globusGridFTPString -connections-max ${GRIDFTP_CONNECTIONSMAX}"
fi
if [[ ! -z "${GRIDFTP_CONNECTIONSDISABLED}" ]]; then
    globusGridFTPString="$globusGridFTPString -connections-disabled"
fi
if [[ ! -z "${GRIDFTP_OFFLINEMSG}" ]]; then
    globusGridFTPString="$globusGridFTPString -offline-msg ${GRIDFTP_OFFLINEMSG}"
fi
if [[ ! -z "${GRIDFTP_DISABLECOMMANDLIST}" ]]; then
    globusGridFTPString="$globusGridFTPString -disable-command-list ${GRIDFTP_DISABLECOMMANDLIST}"
fi
if [[ ! -z "${GRIDFTP_AUTHZCALLOUTS}" ]]; then
    globusGridFTPString="$globusGridFTPString -authz-callout ${GRIDFTP_AUTHZCALLOUTS}"
fi
if [[ ! -z "${GRIDFTP_USEHOMEDIRS}" ]]; then
    globusGridFTPString="$globusGridFTPString -use-home-dirs"
fi
if [[ ! -z "${GRIDFTP_HOMEDIR}" ]]; then
    globusGridFTPString="$globusGridFTPString -home-dir ${GRIDFTP_HOMEDIR}"
fi
if [[ ! -z "${GRIDFTP_RESTRICTPATHS}" ]]; then
    globusGridFTPString="$globusGridFTPString -connections-number ${GRIDFTP_RESTRICTPATHS}"
fi
if [[ ! -z "${GRIDFTP_RPFOLLOWSYMLINKS}" ]]; then
    globusGridFTPString="$globusGridFTPString -rp-follow-symlinks"
fi
if [[ ! -z "${GRIDFTP_EMORACL}" ]]; then
    globusGridFTPString="$globusGridFTPString -em ${GRIDFTP_EMORACL}"
fi

#1.4.4. Logging Options
if [[ ! -z "${GRIDFTP_LOGLEVEL}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-level ${GRIDFTP_LOGLEVEL}"
fi
if [[ ! -z "${GRIDFTP_LOGMODULE}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-module ${GRIDFTP_LOGMODULE}"
fi
if [[ ! -z "${GRIDFTP_LOGFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -logfile ${GRIDFTP_LOGFILE}"
fi
if [[ ! -z "${GRIDFTP_LOGDIR}" ]]; then
    globusGridFTPString="$globusGridFTPString -logdir ${GRIDFTP_LOGDIR}"
fi
if [[ ! -z "${GRIDFTP_LOGTRANSFER}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-transfer ${GRIDFTP_LOGTRANSFER}"
fi
if [[ ! -z "${GRIDFTP_LOGFILEMODE}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-interface ${GRIDFTP_CONTROLINTERFACE}"
fi
if [[ ! -z "${GRIDFTP_DISABLEUSAGESTATS}" ]]; then
    globusGridFTPString="$globusGridFTPString -disable-usage-stats"
fi
if [[ ! -z "${GRIDFTP_USAGESTATSTARGET}" ]]; then
    globusGridFTPString="$globusGridFTPString -usage-stats-target ${GRIDFTP_USAGESTATSTARGET}"
fi
if [[ ! -z "${GRIDFTP_USAGESTATSID}" ]]; then
    globusGridFTPString="$globusGridFTPString -usage-stats-id ${GRIDFTP_USAGESTATSID}"
fi

#1.4.5. Single and Striped Remote Data Node Options
if [[ ! -z "${GRIDFTP_REMOTENODES}" ]]; then
    globusGridFTPString="$globusGridFTPString -remote-nodes ${GRIDFTP_REMOTENODES}"
fi
if [[ ! -z "${GRIDFTP_HYBRID}" ]]; then
    globusGridFTPString="$globusGridFTPString -hybrid"
fi
if [[ ! -z "${GRIDFTP_DATANODE}" ]]; then
    globusGridFTPString="$globusGridFTPString -data-node ${GRIDFTP_DATANODE}"
fi
if [[ ! -z "${GRIDFTP_STRIPEBLOCKSIZE}" ]]; then
    globusGridFTPString="$globusGridFTPString -stripe-blocksize ${GRIDFTP_STRIPEBLOCKSIZE}"
fi
if [[ ! -z "${GRIDFTP_STRIPECOUNT}" ]]; then
    globusGridFTPString="$globusGridFTPString -stripe-count ${GRIDFTP_STRIPECOUNT}"
fi
if [[ ! -z "${GRIDFTP_STRIPELAYOUT}" ]]; then
    globusGridFTPString="$globusGridFTPString -stripe-layout ${GRIDFTP_STRIPELAYOUT}"
fi
if [[ ! -z "${GRIDFTP_STRIPEBLOCKSIZELOCKED}" ]]; then
    globusGridFTPString="$globusGridFTPString -stripe-blocksize-locked"
fi
if [[ ! -z "${GRIDFTP_STRIPELAYOUTLOCKED}" ]]; then
    globusGridFTPString="$globusGridFTPString -stripe-layout-locked"
fi

#1.4.6. Disk Options
if [[ ! -z "${GRIDFTP_BLOCKSIZE}" ]]; then
    globusGridFTPString="$globusGridFTPString -blocksize ${GRIDFTP_BLOCKSIZE}"
fi
if [[ ! -z "${GRIDFTP_SYNCWRITES}" ]]; then
    globusGridFTPString="$globusGridFTPString -sync-writes"
fi
if [[ ! -z "${GRIDFTP_PERMS}" ]]; then
    globusGridFTPString="$globusGridFTPString -perms ${GRIDFTP_PERMS}"
fi
if [[ ! -z "${GRIDFTP_FILETIMEOUT}" ]]; then
    globusGridFTPString="$globusGridFTPString -file-timeout ${GRIDFTP_FILETIMEOUT}"
fi

#1.4.7. Network Options
if [[ ! -z "${GRIDFTP_PORT}" ]]; then
    globusGridFTPString="$globusGridFTPString -p ${GRIDFTP_PORT}"
fi
if [[ ! -z "${GRIDFTP_CONTROLINTERFACE}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-interface ${GRIDFTP_CONTROLINTERFACE}"
fi
if [[ ! -z "${GRIDFTP_DATAINTERFACE}" ]]; then
    globusGridFTPString="$globusGridFTPString -data-interface ${GRIDFTP_DATAINTERFACE}"
fi
if [[ ! -z "${GRIDFTP_IPCINTERFACE}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-interface ${GRIDFTP_IPCINTERFACE}"
fi
if [[ ! -z "${GRIDFTP_HOSTNAME}" ]]; then
    globusGridFTPString="$globusGridFTPString -hostname ${GRIDFTP_HOSTNAME}"
fi
if [[ ! -z "${GRIDFTP_IPCPORT}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-port ${GRIDFTP_IPCPORT}"
fi
if [[ ! -z "${GRIDFTP_CONTROLPREAUTHTIMEOUT}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-preauth-timeout ${GRIDFTP_CONTROLPREAUTHTIMEOUT}"
fi
if [[ ! -z "${GRIDFTP_IPCIDLETIMEOUT}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-idle-timeout ${GRIDFTP_IPCIDLETIMEOUT}"
fi
if [[ ! -z "${GRIDFTP_IPCCONNECTTIMEOUT}" ]]; then
    globusGridFTPString="$globusGridFTPString -ipc-connect-timeout ${GRIDFTP_IPCCONNECTTIMEOUT}"
fi
if [[ ! -z "${GRIDFTP_ALLOWUDT}" ]]; then
    globusGridFTPString="$globusGridFTPString -allow-udt"
fi
if [[ ! -z "${GRIDFTP_PORTRANGE}" ]]; then
    globusGridFTPString="$globusGridFTPString -port-range ${GRIDFTP_PORTRANGE}"
fi

#1.4.8. User Messages
if [[ ! -z "${GRIDFTP_BANNER}" ]]; then
    globusGridFTPString="$globusGridFTPString -banner ${GRIDFTP_BANNER}"
fi
if [[ ! -z "${GRIDFTP_BANNERFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -banner-file ${GRIDFTP_BANNERFILE}"
fi
if [[ ! -z "${GRIDFTP_BANNERTERSE}" ]]; then
    globusGridFTPString="$globusGridFTPString -banner-terse"
fi
if [[ ! -z "${GRIDFTP_BANNERAPPEND}" ]]; then
    globusGridFTPString="$globusGridFTPString -banner-append"
fi
if [[ ! -z "${GRIDFTP_VERSIONTAG}" ]]; then
    globusGridFTPString="$globusGridFTPString -version-tag ${GRIDFTP_VERSIONTAG}"
fi
if [[ ! -z "${GRIDFTP_LOGINMSG}" ]]; then
    globusGridFTPString="$globusGridFTPString -login-msg ${GRIDFTP_LOGINMSG}"
fi
if [[ ! -z "${GRIDFTP_LOGINMSGFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -login-msg-file ${GRIDFTP_LOGINMSGFILE}"
fi

#1.4.9. Module Options
if [[ ! -z "${GRIDFTP_DSI}" ]]; then
    globusGridFTPString="$globusGridFTPString -dsi ${GRIDFTP_DSI}"
fi
if [[ ! -z "${GRIDFTP_ALLOWEDMODULES}" ]]; then
    globusGridFTPString="$globusGridFTPString -allowed-modules ${GRIDFTP_ALLOWEDMODULES}"
fi
if [[ ! -z "${GRIDFTP_DCWHITELIST}" ]]; then
    globusGridFTPString="$globusGridFTPString -dc-whitelist ${GRIDFTP_DCWHITELIST}"
fi
if [[ ! -z "${GRIDFTP_FSWHITELIST}" ]]; then
    globusGridFTPString="$globusGridFTPString -logdir ${GRIDFTP_FSWHITELIST}"
fi
if [[ ! -z "${GRIDFTP_POPENWHITELIST}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-transfer ${GRIDFTP_POPENWHITELIST}"
fi
if [[ ! -z "${GRIDFTP_XNETMGR}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-interface ${GRIDFTP_XNETMGR}"
fi
if [[ ! -z "${GRIDFTP_DCDEFAULT}" ]]; then
    globusGridFTPString="$globusGridFTPString -dc-dcdefault ${GRIDFTP_DCDEFAULT}"
fi
if [[ ! -z "${GRIDFTP_FSDEFAULT}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-interface ${GRIDFTP_FSDEFAULT}"
fi
#1.4.10. Other
if [[ ! -z "${GRIDFTP_LOGLEVEL}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-level ${GRIDFTP_LOGLEVEL}"
fi
if [[ ! -z "${GRIDFTP_LOGMODULE}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-module ${GRIDFTP_LOGMODULE}"
fi
if [[ ! -z "${GRIDFTP_LOGFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -logfile ${GRIDFTP_LOGFILE}"
fi
if [[ ! -z "${GRIDFTP_LOGDIR}" ]]; then
    globusGridFTPString="$globusGridFTPString -logdir ${GRIDFTP_LOGDIR}"
fi
if [[ ! -z "${GRIDFTP_LOGTRANSFER}" ]]; then
    globusGridFTPString="$globusGridFTPString -log-transfer ${GRIDFTP_LOGTRANSFER}"
fi
if [[ ! -z "${GRIDFTP_LOGFILEMODE}" ]]; then
    globusGridFTPString="$globusGridFTPString -control-interface ${GRIDFTP_CONTROLINTERFACE}"
fi

#1.4.10. Other
if [[ ! -z "${GRIDFTP_LITTLEC}" ]]; then
    globusGridFTPString="$globusGridFTPString -c ${GRIDFTP_LITTLEC}"
fi
if [[ ! -z "${GRIDFTP_BIGC}" ]]; then
    globusGridFTPString="$globusGridFTPString -C ${GRIDFTP_BIGC}"
fi
if [[ ! -z "${GRIDFTP_CONFIGBASEPATH}" ]]; then
    globusGridFTPString="$globusGridFTPString -config-base-path ${GRIDFTP_CONFIGBASEPATH}"
fi
if [[ ! -z "${GRIDFTP_DEBUG}" ]]; then
    globusGridFTPString="$globusGridFTPString -debug"
fi
if [[ ! -z "${GRIDFTP_PIDFILE}" ]]; then
    globusGridFTPString="$globusGridFTPString -pidfile ${GRIDFTP_PIDFILE}"
fi

cp /opt/gridftp/users/grid-mapfile /etc/grid-security/grid-mapfile
cp /tmp/gridftp-host-pems/hostcert.pem /etc/grid-security/
chmod 644 /etc/grid-security/hostcert.pem
chown root:root /etc/grid-security/hostcert.pem
cp /tmp/gridftp-host-pems/hostkey.pem /etc/grid-security/
chmod 400 /etc/grid-security/hostkey.pem
chown root:root /etc/grid-security/hostkey.pem
cat /opt/gridftp/users/etc-passwd | while read var1; do
    etcPasswd="$(echo $var1 | tr ":" " ")"
    arrayEtcPasswd=($etcPasswd)
    groupadd -f -g ${arrayEtcPasswd[3]} ${arrayEtcPasswd[0]}
    useradd ${arrayEtcPasswd[0]} -p ${arrayEtcPasswd[1]} -u ${arrayEtcPasswd[2]} -g ${arrayEtcPasswd[3]} -c "${arrayEtcPasswd[4]}" -d ${arrayEtcPasswd[6]} -s ${arrayEtcPasswd[7]} 
    mkdir -p ${arrayEtcPasswd[6]} 
    chown "${arrayEtcPasswd[2]}:${arrayEtcPasswd[3]}" "${arrayEtcPasswd[6]}"
done
eval $globusGridFTPString
