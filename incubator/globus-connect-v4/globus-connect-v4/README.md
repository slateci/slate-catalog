# Globus Connect Server v4


*Image source*: https://github.com/slateci/container-gcs4

The initial release of this chart will only configure Globus Connect to
transfer files to an ephemeral container volume. A future release will allow
mounting other filesystems present on the host system into the container.

--- # Installation

### Dependency Notes To deploy this chart, you will need to first create the
administrator credentials and user passwd file with the SLATE secret command. 

This SLATE application requires the creation of two secrets in order to be
used. Before deploying this chart, you will need to create a passwd(5)-like
user list with encrypted passwords, and you will additionally need to have your
Globus credentials stored in SLATE for endpoint deployment. 

### Storing the admin credentials
To add the admin credentials, Create a new file with the contents:

```
GLOBUS_USER=<username>
GLOBUS_PASSWORD=<password>
```

And then create the credential with:

```
slate secret create <secret-name> --group <group> --cluster <cluster> --from-env-file <filename>
```

### Generating the passwd(5) file (MyProxy authentication)
This chart will consume a file in the format of /etc/passwd, with the notable
exception that the second field must contain an encrypted password hash. This
hash will be stored as a SLATE secret (re-encrypted in DynamoDB) and the
encrypted hash be visible to any user of your namespace and the administrator
of the SLATE cluster upon which you are deploying GCSv4. 

This chart requires UNIX passwords in order to allow MyProxy to authenticate
users who wish to transfer files against the SLATE-deployed endpoint.

The encrypted password hash can be generated via:

```
openssl passwd -1
```

You can then copy users out of /etc/passwd or create them by hand. From the
passwd(5) manual:

```
Each line of the file describes  a  single  user,  and  contains  seven
colon-separated fields:

       name:password:UID:GID:GECOS:directory:shell

The field are as follows:

name        This is the user's login name.  It should not contain capi‐
            tal letters.

password    This is either the encrypted  user  password,  an  asterisk
            (*),  or the letter 'x'.  (See pwconv(8) for an explanation
            of 'x'.)

UID         The privileged root login account (superuser) has the  user
            ID 0.

GID         This is the numeric primary group ID for this user.  (Addi‐
            tional groups for the user are defined in the system  group
            file; see group(5)).

GECOS       This  field  (sometimes  called  the  "comment  field")  is
            optional and used only for  informational  purposes.   Usu‐
            ally,  it  contains  the full username.  Some programs (for
            example, finger(1)) display information from this field.

directory   This is the user's home directory:  the  initial  directory
            where  the  user  is placed after logging in.  The value in
            this field is used to set the HOME environment variable.

shell       This is  the  program  to  run  at  login  (if  empty,  use
            /bin/sh).   If  set  to  a nonexistent executable, the user
            will be unable to login through  login(1).   The  value  in
            this field is used to set the SHELL environment variable.
```

Note that only name, password, UID, and directory are respected in the current
release.

### Deploying 
To deploy the chart, first get the values file and store it:

```
slate app get-conf --dev globus-connect-v4 > gcs.yaml
```

Edit to your liking (notably the GlobusPasswdSecret and GlobusConfigFile must match what you have created in previous steps) and deploy with:

```
slate app install --cluster <cluster> --group <group> globus-connect-v4 --conf gcs.yaml
```

This will return an instance ID, please note this as it will be needed later.

---
# Configuration and Usage

## Backing Storage

This application can use just the ephemeral storage of it own container, an
external filesystem provided by the host system, or a PersistentVolumeClaim as
the backing storage to (or from) which it can transfer data. If neither
`InternalPath` nor `PVCName` is set, only ephemeral storage will be available.
`InternalPath` can be set to refer to a path on the host system which should be
mounted, or `PVCName` name can be set to mount a PVC by name. If either option
is used to mount a volume, `ExternalPath` can be used to set the path within
the container at which it will be mounted. 
 
## Activating the endpoint
Once the application has deployed, you will need to visit globus.org to
activate the endpoint.

Click log in, and log in with the same credentials used to deploy the GCSv4
container.

Once logged in, click Endpoints, then click "Administered By You". 

Find the endpoint you just created, and then click the arrow ( ">" ) on the
right. Go to the tab labeled Server, and click "Edit Identity Provider".

At your console, you will need to tail the logs with:

```
slate instance logs <instance id>
```

Copy the Distinguished Name from the log output that says "Server DN:
/C=US/O=Globus Consortium/OU=Globus Connect Service/CN=..." and paste it into
the field that says "DN". Click Save Changes.

On the Overview page, click "Activate Endpoint". You will need to enter your
admin credentials and then the endpoint should be activated.

Once this has been completed, you can transfer files between the SLATE-deployed
Globus endpoint and any other Globus endpoint where you have access.

##Usage
For further instrucions on how to use globus please read this
[documentation](https://docs.globus.org/)
