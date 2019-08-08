# SLATE Base Login Node

An SSH login node to use as the base for any applications that requires login. This chart simply deploys a container running sshd with the desired config and user accounts setup. This chart isn't a useful application on it's own, and should be forked and used as a starting point for login node applications. 

Because the Base Login Node is simply a starting point for other applications, it will remain in the incubator indefinitely and use the --dev flag for SLATE CLI commands.

# Installation

You will need to add your desired user accounts to the configuration of this application. The file format is the same as /etc/passwd.

`slate app get-conf login-node --dev -o conf`

Edit the configuration with your desired public key. If you need to generate a public key, a guide can be found [here](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). Currently, this container only supports key based login. Each user shold appear on their own line, and must be formatted like this:

```
name:x:uid:gid::/home/name:/bin/bash:publickey
```

A real example might look like this: 

```
myuser:x:1005:1005::/home/myuser:/bin/bash:ssh-rsa AAaAB3NzaC1yc2EAAAADAQABAAABAQDcJRfwNSraeeNkEb4OBQbybS1G72Ez5ACgRHapiEpGdyXEBLzAgNTfjKmYXhJXaaGgUVuVQnMQc3q1dM4TQC2yYv2qhVj8YwOmhhDMroxAemGzApzNvXtC1HwwrmGrBRLzZ3peDVlX39zwQMd7P0PqjzAh2JjpxwAD6aM47fshv2phuH5rPo5aI5qg1Zsg3+bprl39dqERNMzXb2kk8Ja/V+VqC90m2f6BzayPt2IFO7MR/aWsgvBzieOyFtf/dI4vLg3xiSt0h5z2dDfHif/YOUlt10m1LjRr+x1EIKhGhAXB+6d9qxnZ9RA7mFYC83h9YxIuKFDnwR1RThogN/fcZ myuser@myhost
```

Once each user has been added, you want to give your application a unique instance tag in the configuration file

```
Instance: 'my-instance'
```
Upon deployment, the full instance name in this case would be login-node-my-instance.

Finally, simply deploy the application.

`slate app install login-node --dev --cluster <YOUR CLUSTER> --group <YOUR GROUP> --conf conf`

Once the instance is running you can get the correct port and IP address by running the following command:

`slate instance info <YOUR INSTANCE ID>`


# Usage

To log in to the SLATE Login Node, ssh into the instance's External IP. The NodePort will be the mapped port for in the application. For example, if the port listed is 22:12345/TCP, NodePort will be 12345.

`ssh myuser@NodeIP -p NodePort`
