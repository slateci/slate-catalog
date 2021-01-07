# OSG Hosted Compute Element

An OSG Compute Element (CE) is an application that allows a site to contribute HPC or HTC compute resources to the Open Science Grid. The CE is responsible for receiving jobs from the grid and routing them to your local cluster(s). Jobs from the Open Science Grid are preemptible, and can be configured to run only when resources would have otherwise been idle. Resource providers can use OSG to backfill their cluster(s) to efficiently utilize resources and contribute to the shared national cyberinfrastructure.

The simplest way to start contributing resources to the OSG, for many sites, is via the "Hosted" CE. In the hosted case, installation and setup of the Compute Element is done by the OSG team, usually on a machine outside of your cluster, and uses standard OpenSSH as a transport for submitting jobs to your resources. With SLATE, we have simplified Hosted CE installation and made a shared operations model possible. Now the Compute Element can be hosted on your Kubernetes infrastructure on-prem and cooperatively managed by OSG and your local team.

---
## Prerequisites
- You must have a functional Kubernetes cluster with SLATE ([Instructions]( https://slateci.io/docs/cluster/))

- You will need an external cluster with a functional batch system to connect with

- You must be able to add a user account and corresponding SSH key to the external cluster

- It is best to have a Squid Proxy for your CE to cache with [You can deploy one through SLATE](https://portal.slateci.io/applications/osg-frontier-squid)

## Site Setup 

This should be done according to whatever process you normally use to create accounts for users.

Once the account has been created, you'll want to create a new SSH key pair.
The private part of the key will be stored within SLATE, and the public part of
the key will be installed into `authorized_keys` file of the OSG user on your
cluster. To generate the key, you'll need to run the following on some machine
with OpenSSH installed:

	ssh-keygen -f osg-keypair

Note that you will need to make this key passphraseless, as the HostedCE
software will consume this key. Once you've created the key, you'll want to
store the public part of it (osg-keypair.pub) into the `authorized_keys` file
on the OSG account for your cluster. For example, if your OSG service account
is called `osg`, you'll want to append the contents of `osg-keypair.pub` to
`/home/osg/.ssh/authorized_keys`. 

The private part of the keypair will need to be stored on a SLATE cluster for use by the
CE. In this particular example, I'll be operating under the `slate-dev` group and using the `uutah-prod` cluster to host a CE pointed at a SLURM cluster at University of Utah. To do that:

	slate secret create hosted-ce-secret --from-file bosco.key=osg-keypair --group <YOUR GROUP> --cluster <YOUR SLATE CLUSTER>

Where `hosted-ce-secret` will be the name of the secret, and `osg-keypair` is the
path to your private key (assumed to be the current working directory).

## Configuration

Use the following command to obtain a copy of the application configuration file locally

`slate app get-conf osg-hosted-ce -o hosted-ce.yaml`

### Site
The Site section needs to have information that will correspond with what will
be registered in the OSG Topology site. For more information on topology please
visit here:
https://opensciencegrid.org/docs/common/registration/#registering-resources

The resource name typically corresponds to the name of the remote resource. A good template is `SLATE_<COUNTRY>_<INSTITUTION>_<CLUSTER NAME>`

The resource group usually matches the group at the institution providing the resource, for example CHTC. There might already be an entry for that under OSG Topology. If possible, use the existing one. 

Sponsor should be left alone. Leave this as `osg:100`

The Contact and corresponding ContactEmail sections should match the contact info for a support person or group responsible for the resource.

The City, Country, Latitude, and Longitude sections should match the physical location of the resource.

    Topology:
      Resource: <RESOURCE NAME> (Must match OSG Topology)
      Sponsor: osg:100 
      Contact: <NAME OF LOCAL CONTACT>
      ContactEmail: <EMAIL FOR LOCAL CONTACT>
      City: <RESOURCE PHYSICAL LOCATION>
      Country: <RESOURCE PHYSICAL LOCATION>
      Latitude: <RESOURCE PHYSICAL LOCATION>
      Longitude: <RESOURCE PHYSICAL LOCATION>

### RemoteCluster

The `RemoteCluster` section contains configuration parameters for the remote cluster that the Hosted CE sends jobs to
via Bosco, specifically the SSH configuration, whose private key must be stored as a SLATE secret and selection of the
remote batch system.

`LoginHost` is the FQDN for the remote SSH host.

`PrivateKeySecret` is the name of a secret created in SLATE which contains the private key for the osg user on the remote cluster. 

`Batch` is the remote batch system, e.g. `condor`, `lsf`, `pbs`, `sge`, or `slurm`.

`MemoryPerNode`, `CoresPerNode`, and `MaxWallTime` should be set to the max resource limits available on the remote cluster.

*Note: For clusters composed of disparate nodes, you want to target the lowest common denominator with these settings*

This section contains a `GridDir` parameter, which describes the location where the OSG Worker Node client can be found
on the remote side.
This is usually under `/cvmfs` or the home directory.

This section additionally requires that the application administrator configure the `WorkerNodeTemp` directory, which
will be seen by jobs under the environment variable `$OSG_WN_TEMP` for scratch space.

**Be sure to specify absolute paths**

This section informs the HostedCE of the Squid proxy cache closest to the *remote* side, for job access.
Set `Location: null` to disable.

    RemoteCluster:
      LoginHost: <REMOTE SSH HOST>
      PrivateKeySecret: <NAME OF SLATE SECRET>
      Batch: <SITE BATCH SYSTEM>
      MemoryPerNode: <MAX MEMORY IN MB>
      CoresPerNode: <MAX CORES PER NODE>
      MaxWallTime: <MAX ALLOWED WALLTIME IN MINUTES>
      GridDir: /path/to/bosco-wn-client
      WorkerNodeTemp: /tmp
      # may be left as null
      Squid: <IP OR HOSTNAME>:<PORT>

### Networking

The HostedCE application requires both forward and reverse DNS resolution for its publicly routable IP. Most SLATE clusters come pre-configured with a handful of "LoadBalancer" IP addresses that can be allocated automatically to different applications. You must set-up the DNS records for this address so you will need to request a specific address from the pool.

If you do not know which addresses are available to your cluster, set `RequestIP: null` and deploy the application. Use `slate instance info <INSTANCE ID>` to see which IP address the application recieves, then set that IP in your config and redeploy.

The default ServiceType is `LoadBalancer` and that value should be used with production CEs.

    Networking:
      ServiceType: "LoadBalancer"
      Hostname: "<YOUR FQDN>"
      RequestIP: <IP ADDRESS>
      
*It is possible to run the CE in HostNetworking mode. This allows the container to use the host machine's network directly, and removes a lot of the isolation a container normally has from the host system.*

To enable HostNetworking set

	Networking:
      	   ServiceType: "HostNetwork"
          Hostname: "<FQDN OF YOUR KUBERNETES NODE>"
          RequestIP: <IP ADDRESS OF YOUR KUBERNETES NODE>
	  
*HostNetwork should be avoided for Production CEs*
	  

### VoRemoteUserMapping Section

This list controls the VOs accepted by the CE and the users they are mapped to on the remote site.

To disallow VOs, remove the relevant item from the list.
To change the remote user for a given VO, change the value (e.g. osg01)
To add custom VOMS FQAN mappings, add a new item to the list.
VOMS FQANs may include "*" wildcards.

	VoRemoteUserMapping:
	  # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/OSG.yaml
      - "/osg/Role=NULL/Capability=NULL": osg01
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/GLOW.yaml
      - "/GLOW/Role=htpc/Capability=NULL": osg02
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/HCC.yaml
      - "/hcc/Role=NULL/Capability=NULL": osg03
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/CMS.yaml
      - "/cms/*": osg04
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/Fermilab.yaml
      - "/fermilab/*": osg05
      # osg06 reserved for JLAB
      # LIGO-Virgo collaboration
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/LIGO.yaml
      - "/osg/ligo/Role=NULL/Capability=NULL": osg07
      - "/virgo/ligo/Role=NULL/Capability=NULL": osg07
      # Brookhaven National Lab VOs
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/sPHENIX.yaml
      - "/sdcc/Role=NULL/Capability=NULL": osg08
      - "/sphenix/Role=NULL/Capability=NULL": osg08
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/ATLAS.yaml
      - "/atlas/*": osg09
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/Gluex.yaml
      - "/Gluex/Role=NULL/Capability=NULL": osg10
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/DUNE.yaml
      - "/dune/Role=pilot/Capability=NULL": osg11
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/IceCube.yaml
      - "/icecube/Role=pilot/Capability=NULL": osg12
      # https://github.com/opensciencegrid/topology/blob/master/virtual-organizations/XENON.yaml
      - "/xenon.biggrid.nl/Role=NULL/Capability=NULL": osg13

### DnRemoteUserMapping

The `DnRemoteUserMapping` will allow you to add your own personal grid proxy to the CE. This is for the purpose of testing basic job submission.

You can obtain one with your institutional credential at [cilogon.org](https://cilogon.org/)

	DnRemoteUserMapping:
	  - "/DC=foo/DC=bar/OU=Organic Units/OU=Users/CN=YourUserName": osguser

### HTCondorCeConfig

The HTCondorCeConfig file contains any additional configuration for HTCondor-CE itself.
By default, the Hosted CE app contains a single default route that submits jobs for each remote user (as specified in
`VoRemoteUserMapping` and `DnRemoteUserMapping`) to the remote batch system specified by `Batch` and  `LoginHost`.

In other words, the `GridResource` line is automatically set appropriately for each route so if you need to add custom
routes, you may exclude that line.
For example:

    HTCondorCeConfig: |+
      JOB_ROUTER_ENTRIES @=jre
      [
        Name = "COVID19_Jobs";
        Requirements = (TARGET.IsCOVID19 =?= true);
      ]
      $(JOB_ROUTER_ENTRIES)
      @jre
      
      # The job router should try to match jobs to the "COVID19_Jobs" route first
      JOB_ROUTER_ROUTE_NAMES = COVID19_Jobs $(JOB_ROUTER_ROUTE_NAMES)

### BoscoOverrides

The BoscoOverrides section provides a mechanism to override default configuration placed on the remote cluster for the OSG Worker Node Client. This can include things like the local path to the batch system's executables and additional job submission parameters for the batch system.

This will vary depending on your batch system. All the overrides are expected to be placed in a git repository with a subdirectory format that matches `<RESOURCE NAME>/bosco-override`

It may take some trial and error to get the correct overrides in place. The general proccess for this is to deploy the CE, then check the logs on the application's HTTP Log exporter to see what must be changed. Finally re-deploy with the updated overrides.

There is a [template bosco override](https://github.com/slateci/bosco-override-template) repository that you can fork and tailor to your needs.

Once you've customized your fork, you can simply provide that repository as the GitEndpoint for this section.

You can use a private git repo and provide the key to the application as a SLATE secret with `git.key` key set to the private key.

    BoscoOverrides:
      Enabled: true
      GitEndpoint: "<GIT ENDPOINT>"
      GitKeySecret: null


### HTTPLogger Section

This allows you to turn toggle HTTP logging side car. When it is enabled, it will allow you to view the CE logs from your browser. 

You may provide a SLATE secret with an `HTPASSWD` key containing password instead of having the container randomly
generate a password.

**TIP** You can create a SLATE secret containing a predefined password for the logger using a command like this:

```
slate secret create <name-of-your-secret> --group <your-group> --cluster <your-cluster> --from-literal HTPASSWD=<your-desired-password>
```

To disable this, comment out the `Secret` line (default).

	HTTPLogger:
	  Enabled: true
      Secret: <PATH TO PASSWORD SECRET>

You can get the endpoint for your logger by running `slate instance info <INSTANCE ID>`, and the randomly generated credentials will be written to the sidecar's logs.

`slate instance logs <INSTANCE ID>`


### Certificate 

Each time the CE is deployed, it requests a new certificate from Let's Encrypt, which has rate limits to prevent denial-of-service attacks. This means that if you are redeploying a CE frequently for troubleshooting purposes, you may experience the rate limit.

To avoid these rate limits, it's possible to bootstrap the certificate request process with your own private key and retrieve the Let's Encrypt certificate from the SLATE instance logs:

1.  Generate your host  key:

        openssl genrsa -out <PATH TO KEYFILE> 2048

1.  Store the generated host key in a SLATE secret:

        slate secret create <YOUR HOST KEY SECRET NAME> --cluster <YOUR CLUSTER> --group <YOUR GROUP> --from-file host.key=<PATH TO KEYFILE>

1.  Update your values file to use the host key secret that you've created:

        HostCredentials:
          HostKeySecret: <YOUR HOST KEY SECRET NAME>
          HostCertSecret: null

1.  Upon successful startup of the Hosted CE app, the Let's Encrypt host certificate can be found in the instance logs:

        slate instance logs <YOUR INSTANCE NAME> --container osg-hosted-ce --max-lines 0

1.  Save the encoded certificate to a file (i.e., everything between and including the `BEGIN CERTIFICATE` and `END CERTIFICATE` lines)

1.  Store the host certificate in a SLATE secret:

        slate secret create <YOUR HOST CERT SECRET NAME> --cluster <YOUR CLUSTER> --group <YOUR GROUP> --from-file host.cert=<PATH TO CERT FILE>

1.  Update your values file to use the host key secret that you've created:

        HostCredentials:
          HostKeySecret: <YOUR HOST KEY SECRET NAME>
          HostCertSecret: <YOUR HOST CERT SECRET NAME>

### Developer 
Simply disable this. It is in place for the purpose of OSG Internal Testbed hosts, and is not intended for use with production CEs.

	Developer:
	  Enabled: false
    
### Example Config

```
Instance: "my-cluster"

Topology:
  Resource: SLATE_US_MYINSTITUTION_MYCLCUSTER
  Sponsor: osg:100
  Contact: My Group Support
  ContactEmail: my-support-list@institution.edu
  City: My City
  Country: My Country
  Latitude: 0.00
  Longitude: 0.00

RemoteCluster:
  LoginHost: remote-ssh.login.org
  PrivateKeySecret: my-slate-secret-key # maps to SLATE secret
  Batch: slurm
  MemoryPerNode: 24000
  CoresPerNode: 4
  MaxWallTime: 4320
  GridDir: /home/osguser/bosco-osg-wn-client
  WorkerNodeTemp: /scratch/local/.osgscratch
  Location: squid.example.com:31192

Networking:
  ServiceType: "LoadBalancer"
  Hostname: "hosted-ce.example.com"
  RequestIP: 0.0.0.0

VoRemoteUserMapping:
  - "/osg/Role=NULL/Capability=NULL": osguser
  - "/GLOW/Role=htpc/Capability=NULL": osguser
  - "/hcc/Role=NULL/Capability=NULL": osguser
  - "/cms/*": osguser
  - "/fermilab/*": osguser
  - "/osg/ligo/Role=NULL/Capability=NULL": osguser
  - "/virgo/ligo/Role=NULL/Capability=NULL": osguser
  - "/sdcc/Role=NULL/Capability=NULL": osguser
  - "/sphenix/Role=NULL/Capability=NULL": osguser
  - "/atlas/*": osguser
  - "/Gluex/Role=NULL/Capability=NULL": osguser
  - "/dune/Role=pilot/Capability=NULL": osguser
  - "/icecube/Role=pilot/Capability=NULL": osguser
  - "/xenon.biggrid.nl/Role=NULL/Capability=NULL": osguser

DnRemoteUserMapping:
  - "/DC=foo/DC=bar/OU=Organic Units/OU=Users/CN=YourUserName": osguser

HTCondorCeConfig: |+
  ALL_DEBUG = D_CAT D_ALWAYS:2

BoscoOverrides:
  Enabled: true
  GitEndpoint: "https://github.com/slateci/bosco-override-template.git"
  GitKeySecret: null

HTTPLogger:
  Enabled: true
  Secret: null

HostCredentials:
  HostKeySecret: null
  HostCertSecret: null
  
Developer:
  Enabled: false

```


---
## Installation
Once you have configured the HostedCE, you can install it in the following way:

```
slate app install osg-hosted-ce --conf osg-hosted-ce.yaml --cluster <your cluster> --group <your group> 
```

## Testing

### Obtain a Certificate

In order to test end-to-end job submission through the CE you will need a valid grid proxy and the HTCondor CE tools. First you must obtain a certificate.

An easy way to do that is through [CILogon](https://cilogon.org/).

Create a cert and download it. You'll need to remember the password you set.

### Convert the Certificate to PKCS12

Next you will need to convert it to PKCS12 format for voms. These commands will prompt for your password.

`openssl pkcs12 -in usercred.p12 -nocerts  -out userkey.pem`

`openssl pkcs12 -in usercred.p12 -nocerts -nodes -out usercert.pem`

Be sure that both files have the correct file permissions

`chmod 600 userkey.pem && chmod 600 usercert.pem`

### Install HTCondorCE Client 

You will need to install `htcondor-ce-client` on the machine you would like to submit from.

On EL7 enable the OSG yum repos

`yum install https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm && yum update`

Then install the tools

`yum clean all; yum install htcondor-ce-client`

### Initialize Your Grid Proxy

You should be able to use your cert to initialize your grid proxy

`voms-proxy-init -cert usercert.pem -key userkey.pem --debug`

Here I use the `--debug` flag because `voms-proxy-init` won't give us very helpful output, if it fails.

If that was successful you should be able to run a job trace against your CE, which will trace the end-to-end submission of a small test job.

### Run the Trace

`condor_ce_trace hosted-ce.example.com`

This command will output a great deal of helpful information about the job submission, it's status and the eventual result. If the jobs sits idle on the remote cluster for too long, the command may time out.

### Understanding the ouput

If authentication is successful you should see your job sbumit.

```
Testing HTCondor-CE authorization...
Verified READ access for collector daemon at <0.0.0.0:9619?addrs=0.0.0.0-9619&noUDP&sock=collector>
Verified WRITE access for scheduler daemon at <0.0.0.0:9619?addrs=0.0.0.0-9619&noUDP&sock=1326_1aab_3>
Submitting job to schedd <0.0.0.0:9619?addrs=0.0.0.0-9619&noUDP&sock=1326_1aab_3>
- Successful submission; cluster ID 3
```

This will be followed by the job's ClassAd which is a large description of the job and its state. ClassAds are also used to describe other types of objects in the CE software.

After the ClassAd there should be some output describing the status of the job. The job will typically go form Held to Idle. It may stay idle for a long time waiting on available resource. Eventually the trace should report that the job was successful. 

```
Spooling cluster 3 files to schedd <0.0.0.0:9619?addrs=0.0.0.0-9619&noUDP&sock=1326_1aab_3>
- Successful spooling
Job status: Held
Job transitioned from Held to Idle
Job transitioned from Idle to Completed
- Job was successful
```

If the jobs stays idle for too long, the trace may time out. You can simply run it again.

### Authorization Failure

You might see some output like this:

```
Testing HTCondor-CE authorization...
Verified READ access for collector daemon at <0.0.0.0:9619?addrs=155.101.6.240-9619&noUDP&sock=collector>
********************************************************************************
2020-01-24 08:58:41 ERROR: WRITE access failed for scheduler daemon at
<0.0.0.0:9619?addrs=0.0.0.0-9619&noUDP&sock=1326_1aab_3>. Re-run
with '--debug' for more information.
********************************************************************************
```

This error indicates that the CE is running and we can communicate with it, but it did not accept our credentials. This could be due to a number of reasons these are the most common:

1) Your grid proxy isn't setup correctly

2) Your grid proxy is expired

3) You have not correctly added your identity to the CE GridmapOverride

You can use `voms-proxy-info` to check the status of your grid proxy.

If the command hangs, this could indicate a connection problem or an issue with the CE.

You can run the command with the `--debug` flag to see verbose output.

`condor_ce_trace --debug hosted-ce.example.com`

## Registration with OSG

You must properly register the CE with the OSG in order to recieve work from the grid.

### Registering yourself as an OSG Contact

Head over to [https://opensciencegrid.org/docs/common/registration/#registering-contacts](https://opensciencegrid.org/docs/common/registration/#registering-contacts) for instructions on registering yourself as a contact with OSG. 

This will be important for creating the resource record under OSG Topology, which is required for the accounting data.

It is possible to register an institutional contact such as a support list.

### Registering the Resource in OSG Topology

Once you are registered as a contact with the OSG, you can head over to the contact database to grab your contact ID.

[https://topology.opensciencegrid.org/contacts](https://topology.opensciencegrid.org/contacts)

You will need this when you register the Resource(s) in OSG topology. Following the instructions available at:

[https://opensciencegrid.org/docs/common/registration/#new-site](https://opensciencegrid.org/docs/common/registration/#new-site)

Go to the OSG Topology GitHub repository and fork it. You will need to find your site within the repository, or create a new directory for it. Following the template fill in the details about your CE (primarily from the `Site` section of the SLATE config).

Submit your updated fork as a Pull Request to the main OSG Topology repository.

### Registering the CE with the OSG Factory

In order to recieve work from the OSG you must inform the factory operations team about your resource.

Send an e-mail to [osg-gfactory-support@physics.ucsd.edu](mailto:osg-gfactory-support@physics.ucsd.edu) with all of the details of your CE:

  - CE hostname
  - Details regarding: support for multicore, max wall time, max memory usage
  - GLIDEIN_Site (maps to ResourceGroup)
  - GLIDEIN_ResourceName (maps to Resource)
  - GLIDEIN_Supported_VOs (maps to AllowedVOs)

For more information please see here: https://opensciencegrid.org/docs/#verify-osg-software

---
