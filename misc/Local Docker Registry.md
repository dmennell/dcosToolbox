# Deploy a Local Registry to the Bootstrap Node

At times, the customer may not have a local Docker Registry available to use for demo and use cases.  These few steps are what is needed to deploy a Docker Registry on the DCOS Bootstrap node that already has the prerequisites installed and configured (especially Docker).  The below example uses self signed certificates, is set to auto restart the registry, and uses local persistent storage.

### Prerequisites
* Docker Installed on Bootstrap node (or any other non-cluster node for that matter
* Login to Bootstrap node (user that has sudo privelages)

### Create a New Directory
This new directory will be used to hold the certificate.
```
sudo mkdir -p certs
```

### Create a New Certificate
when you run the below command, it will ask you a bunch of questions about who/where you are.  They are used when creating the self-signed cerificates
```
sudo openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -x509 -days 365 -out certs/domain.crt
```

### Run the Docker Registry
Use the self-signed certs, local storage, auto restart.
```
docker run -d \
--restart=always \
--name registry \
-v /mnt/registry:/var/lib/registry \
-v `pwd`/certs:/certs \
-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-p 443:443 \
registry:2
```
 
