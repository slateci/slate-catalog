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

# System requirements:
This NGINX Demonstrator creates a deployment of one nginx pod with besteffort QOS.

# Network requirements:
- The NGINX Demonstrator exposes the webserver service through an kubernetes ingress object.
- The slate clusters to run this app should have MetalLB installed.
- The application expose http port to the internet.
- The ipfamily of the service depends on the underlying kubernetes cluster configurations.

# Storage Requirements:
The application doesn't require volumes. The application data is stored in a kubernetes configmap object.

# Statefulness:
This application is stateless.

# Privilege requirements:
No special privilege requirements

# Labels and Annotations:
Slate recommended labels and included in the kubernetes objects:
- app
- chart
- release
- instance
- instanceID

# Monitoring and Logging:
No monitoring and logging specific to the app is required.

# Multiple Versions:
By default the chart deploys the latest nginx version. A specific version can be deployed by specifying the nginx image tag during the installation.

# Testing
No testing frameworks included.
