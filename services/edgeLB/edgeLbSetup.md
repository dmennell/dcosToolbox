## Create a Service Account
```
#Create a Key-Pair
dcos security org service-accounts keypair edge-lb-private-key.pem edge-lb-public-key.pem
#Create & Verify the Principal
dcos security org service-accounts create -p edge-lb-public-key.pem -d "Edge-LB service account" edge-lb-principal
dcos security org service-accounts show edge-lb-principal
#Create and Verify a Secret
dcos security secrets create-sa-secret --strict edge-lb-private-key.pem edge-lb-principal dcos-edgelb/edge-lb-secret
```


## Create and Assign Privelages
You only need to do one of the following steps based on the level privelages you want to provide to the Service Account

### Add Service Account to "superusers"
```
dcos security org groups add_user superusers edge-lb-principal
```
### Grant Limited Actions to the Service Account
```
dcos security org users grant edge-lb-principal dcos:adminrouter:service:marathon full
dcos security org users grant edge-lb-principal dcos:adminrouter:package full
dcos security org users grant edge-lb-principal dcos:adminrouter:service:edgelb full
dcos security org users grant edge-lb-principal dcos:service:marathon:marathon:services:/dcos-edgelb full
dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1 full
dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1/scheduler full
dcos security org users grant edge-lb-principal dcos:mesos:master:framework:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:framework:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:volume:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:volume:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:task:user:root full
dcos security org users grant edge-lb-principal dcos:mesos:master:task:app_id full
```
Additionally, this permission needs to be granted for each Edge-LB pool created:
```
dcos security org users grant edge-lb-principal dcos:adminrouter:service:dcos-edgelb/pools/<POOL-NAME> full
```
## Create a configuration file for service authentication
```
{
  "service": {
    "secretName": "dcos-edgelb/edge-lb-secret",
    "principal": "edge-lb-principal",
    "mesosProtocol": "https"
  }
}
```
## Install EdgeLB on DC/OS Cluster
```
dcos package install --options=edge-lb-options.json edgelb
```
run the following to see when EdgeLB Comes online
```
until dcos edgelb ping; do sleep 1; done
```
> Pong response signifies it is up.
