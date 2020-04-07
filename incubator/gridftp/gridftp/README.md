# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 

This chart installs an endpoint for the GridFTP high-performance, secure  data-transfer protocol. GridFTP uses X509 certificates to authenticate communications, and a 'grid-map' to associate user certificates' distinguished names to local unix accounts. 

---
# Installation

## Dependency notes
**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

**NOTE**: The Common Name in the server certificate used with this application must match the hostname configured on the node where it is scheduled. To coordinate this, the application will only schedule on nodes which have a `gridftp: "true"` label set by a cluster administrator. Users are recommended to contact cluster admins to arrange this. 

**NOTE**: This application currently uses host networking, so two instances configured to use the same port cannot coexist on the same node. No mechanism is currently in place to ensure that multiple instances are scheduled to different nodes even if multiple suitable nodes are available. 

## The host secret

The host secret should contain two keys: `hostcert.pem` and `hostkey.pem`, containing the server certificate and secret key, respectively. 

## The user secret

The user secret should contain the 'gridmap' file under the key `grid-mapfile`. This file should contain the DNs of any clients you wish to allow, mapped to the usernames with which you want them to be associated. Additionally, under the key `etc-passwd` the secret should contain a file, in the (old) passwd(5) format, describing the mapping of usernames to user identifier numbers and groups. Details like home directory paths and login shells are allowed, but have little practical use. By using these two mappings, it is possible to configure GridFTP to read and write files according to pre-existing schemes of user and group IDs (such as whatever may be already in use on the filesystem mounted by GridFTP with `InternalPath`).

### The passwd format

The expected passwd format is as follows: 

> Each line of the file describes  a  single  user,  and  contains  seven
> colon-separated fields:
> 
>        name:password:UID:GID:GECOS:directory:shell
> 
> The fields are as follows:
> 
> name:        This is the user's login name.  It should not contain capital
>              letters.
> 
> password:    This is either the encrypted  user  password,  an  asterisk
>             (*),  or the letter 'x'.  (See pwconv(8) for an explanation
>             of 'x'.)
> 
> UID:         The privileged root login account (superuser) has the  user
>             ID 0.
> 
> GID:         This is the numeric primary group ID for this user.  (Additional
>              groups for the user are defined in the system  group
>             file; see group(5)).
> 
> GECOS:       This  field  (sometimes  called  the  "comment  field")  is
>             optional and used only for  informational  purposes.   Usually
>             ,  it  contains  the full username.  Some programs (for
>             example, finger(1)) display information from this field.
> 
> directory:   This is the user's home directory:  the  initial  directory
>             where  the  user  is placed after logging in.  The value in
>             this field is used to set the HOME environment variable.
> 
> shell:       This is  the  program  to  run  at  login  (if  empty,  use
>             /bin/sh).   If  set  to  a nonexistent executable, the user
>             will be unable to login through  login(1).   The  value  in
>             this field is used to set the SHELL environment variable.

No encrypted passwords should be placed in the passwd file for GridFTP, as password-based login is not enabled. Specified home directory paths will be created as needed, but it should be noted that these will typically be within the ephemeral storage space of the GridFTP container, so they should not be confused with any other home directories the users have on machines at the same site, and should not be used to store any important data. Since shell login is not permitted, the value of the shell field is irrelevant. 

A typical passwd entry might look like:

	jdoe:x:1001:1001:John Doe:/home/jdoe:/bin/false
	
### The grid-map format

The grid-mapfile contains one user entry per line, where each entry is made up of the quoted Distinguished Name (DN) for a user's certificate and the user's unix account name. On a system with the Grid Community Toolkit installed and a user's certificate in already place, the user can extract his or her DN using the command

	grid-proxy-info -identity
	
The DN can also be extracted from a user's certificate file using 

	openssl x509 -in <usercert.pem> -subject -noout

A typical grid-map entry might look like:

	"/DC=org/DC=cilogon/C=US/O=University of Somewhere/CN=John Doe A806281" jdoe

## Deployment

	$ slate app get-conf gridftp > gridftp.yaml
	$ slate app install --group <group-name> --cluster <cluster-name> gridftp

---
# Configuration and usage

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `gridftp-host-pems` |
| UserSecretName | The SLATE secret that contains the grid-mapfile for GridFTP, and the /etc/passwd file for the server, named 'grid-mapfile' and 'etc-passwd' respectively | `gridftp-users` |
| GridFTPPort | The port for data & control channel access to GridFTP. These can be decoupled by advanced configuration | `2811` |
| InternalPath | A path on the host system which should be mounted into the GridFTP container as back-end storage. Cannot be set at the same time as PVCName. | `/mnt` |
| PVCName | The name of a PersistentVolumeClaim which should be mounted into the GridFTP container as back-end storage. Cannot be set at the same time as InternalPath. | None | 
| ExternalPath | The path inside the GridFTP container at which the filesystem specified by `InternalPath` should be mounted. This is the path which will be used in GridFTP URLs to manipulate data on that filesystem. | `/export` | 

For more instructions on how to run GridFTP please see the [GridFTP System Administrator’s Guide](https://gridcf.org/gct-docs/6.2/gridftp/admin/index.html)

## Usage

After the GridFTP server is started with SLATE, it is important assign it a DNS name which matches the name in the host certificate with which it was deployed. 

Use the `slate instance info` command, with your instance's ID as an argument, to check the IP address of the node on which the GridFTP pod is running. The relevant section of the output should look something like the following

	Pods:
	  gridftp-cnw-794f597c54-bf97l
	    Status: Running
	    Created: 2019-08-07T16:32:29Z
	    Host: some-node.usnd-hoople.edu
	    Host IP: 146.127.227.58

In this case the node already has a hostname (`some-node.usnd-hoople.edu`), however, since it may not be possible to know ahead of time on which node the GridFTP server will be scheduled, it is often better to configure it with a host certificate using a name distinct from any of the nodes. Supposing that the certificate was issued for `gridftp.usnd-hoople.edu`, a new DNS `A` record can now be created mapping that name to particular IP address in use, `146.127.227.58` in this case. It should be noted that if the GridFTP pod is restarted it may migrate to a different node, at which point the DNS record for it should be updated. 

Once the GridFTP server is running, it can be interacted with using various tools, including [globus-url-copy](https://gridcf.org/gct-docs/6.2/appendices/commands/index.html#globus-url-copy) from the Grid Community Toolkit, and the [gfal2 family of utilities](https://dmc.web.cern.ch/projects/gfal-2/documentation). 

Assuming the example user entries above, and that the `gridftp.usnd-hoople.edu` DNS record points to the server, the following command can be used to list the contents of the user's (ephemeral!) home directory pon the GridFTP server:

	$ gfal-ls -a gsiftp://gridftp.usnd-hoople.edu/home/jdoe
	.
	..
	.bash_logout
	.bash_profile
	.bashrc
	
This should initially exit successfully, and output a few dotfiles with which the user's home directory was initially configured. Assuming the existence of a local file called 'foo.txt', it can be copied to server:

	$ gfal-copy foo.txt gsiftp://gridftp.usnd-hoople.edu/home/jdoe/
	Copying file:///home/jdoe/foo.txt   [DONE]  after 0s
	
After which the file should be visible in the remote directory:

	$ gfal-ls gsiftp://gridftp.usnd-hoople.edu/home/jdoe
	foo.txt
	
The ephemeral home directories are useful for testing, and can be used as temporary storage for small files, but for serious use it is normal to configure the `InternalPath` and `ExternalPath` in the values file to mount a non-ephemeral filesystem (typically a large, networked filesystem), and most file transfers will be to or from the base URL `gsiftp://<hostname>/<ExternalPath>/`. 

Instead of using an external backing filesystem, it is also possible to use a PersistentVolumeClaim within Kubernetes as backing storage. This is more suitable for intermediate amounts of data, or for adding an authenticated interface to a PVC in which another application is storing data. 

### Error when connecting with the wrong hostname

As noted above, the hostname used when connecting to the server must match the name in the host certificate being used. If this is not the case, an error similar to the following will be seen:

> Authorization denied: The name of the remote entity (/DC=org/DC=incommon/C=US/ST=ND/L=Hoople/O=University of Southern North Dakota/OU=IT Services - Self Enrollment/CN=gridftp.usnd-hoople.edu), and the expected name for the remote entity (/CN=some-node.usnd-hoople.edu) do not match

### Error when no nodes are labeled

In order to coordinate GridFTP running on cluster nodes where filesystems to which it is intended to give access are mounted, the pod will only schedule on nodes which carry the extra `gridftp: "true"` label (which must be added by a cluster administrator for the site, outside of SLATE). If no node is labeled in this way, the application will install, but the pod will not start as shown in this example:

	$ slate app install gridftp --group cnw --cluster sandbox
	Installing application...
	Successfully installed application gridftp as instance cnw-gridftp-global with ID instance_Qb9cPw39LOE
	sandbox:~ $ slate instance info instance_Qb9cPw39LOE
	Name           Started                  Group Cluster ID                  
	gridftp-global 2019-Aug-07 17:52:49 UTC cnw   sandbox instance_Qb9cPw39LOE
	
	Services: (none)
	
	Pods:
	  gridftp-global-58667bc6b-gvg5s
	    Status: Pending
	    Created: 2019-08-07T17:52:50Z
	    Conditions: PodScheduled: Unschedulable; 0/1 nodes are available: 1 node(s) didn't match node selector.
	    Events: [2019-08-07T17:52:50Z - 2019-08-07T17:52:52Z] FailedScheduling: 0/1 nodes are available: 1 node
	            (s) didn't match node selector. (x3)
	
	Configuration: (default)
