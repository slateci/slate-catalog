# Redis
[Redis](http://redis.io/) is an advanced key-value cache and store. It is often referred to as a data structure server since keys can contain strings, hashes, lists, sets, sorted sets, bitmaps and hyperloglogs.

## Before Installation
The Redis container will get started using password set up in the secret pod. Therefore, a password must be specified and a secret must be created based on the password prior to instantiating a Redis container. </br>

Create the password and a secret with:
```bash
$ echo "REDIS_PASSWORD=<your_redis_password>" > <password file name>
$ slate secret create redis-creds --group <your group> --cluster <your cluster> --from-env-file <password file name>
```
## Installation
```bash
$ slate app install --dev redis --group <your group> --cluster <your cluster> redis
```

After installation, copy, paste and run the last three lines of output to get the application URL. For example:

```bash
$ export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services <service name>)
$ export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
$ echo http://$NODE_IP:$NODE_PORT
```
## Redis Container Access

By the end of installation, the command `$ echo http://$NODE_IP:$NODE_PORT` returns a URL, for example: `http://128.135.235.190:31239` </br>
A Python3 script example to access the Redis container would be:

```python
import redis
import sys

def main():
  ip = sys.argv[1]
  port_num = int(sys.argv[2])
  r = redis.StrictRedis(host=ip, port=port_num, db=0, password='your_redis_password')
  print('set foo bar')
  print(r.set('foo','bar'))
  print('get foo')
  print(r.get('foo'))

if __name__ == "__main__":
  main()
```

Run the python script with command:
```bash
$ python redis_test.py <IP address> <port number>
```
