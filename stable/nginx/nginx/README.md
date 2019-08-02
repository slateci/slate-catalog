# NGINX Demonstrator

A minimal webserver which serves a single static page. 
Intended for testing and demonstration purposes. 

# Installation:

    $ slate app get-conf nginx > nginx.yaml
    $ slate app install nginx --group <group name> --cluster <cluster> --conf nginx.yaml

# Configuration and usage:
The configuration for the NGINX Demonstrator only allows an end-user to create a single static HTML page. The "data" block can be modified to be any HTML document. By default, we demonstrate a trivial "Hello world!" page: 

    Data: |-
      <html>
      <body>
      <h1>Hello world!</h1>
      </body>
      </html>
