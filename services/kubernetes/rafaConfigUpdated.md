# K8S Quickest Start : 06-12-2018 (Created by Rafael Gonzalez)
*** You should already have marathon-lb running on DC/OS 1.11.2 ….

## Step 1 : Setup the CLI
use https to connect to the cluster, seems could be needed.  Use IP instead of hostname, if hostname does not work
```
dcos cluster setup https://<master>/
dcos package install --yes dcos-enterprise-cli
```

## Step 2 : Create Secret and Service Account
```
dcos security org service-accounts keypair k8s-private-key.pem k8s-public-key.pem
dcos security org service-accounts delete kubernetes   ##in case exhists
dcos security org service-accounts create -p k8s-public-key.pem -d 'Kubernetes service account' kubernetes
dcos security secrets delete kubernetes/sa   ##in case exists
dcos security secrets create-sa-secret k8s-private-key.pem kubernetes kubernetes/sa
```

## Step 3 : Assign Permissions to kubernetes Service Account
I find I cannot submit all in one shot... causes some kind of overrun
```
dcos security org users grant kubernetes dcos:mesos:master:framework:role:kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:task:user:root create
dcos security org users grant kubernetes dcos:mesos:agent:task:user:root create
dcos security org users grant kubernetes dcos:mesos:master:reservation:role:kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:reservation:principal:kubernetes delete
dcos security org users grant kubernetes dcos:mesos:master:volume:role:kubernetes-role create
sleep 10
```
```
dcos security org users grant kubernetes dcos:mesos:master:volume:principal:kubernetes delete
dcos security org users grant kubernetes dcos:service:marathon:marathon:services:/ create
dcos security org users grant kubernetes dcos:service:marathon:marathon:services:/ delete
dcos security org users grant kubernetes dcos:secrets:default:/kubernetes/\* full
dcos security org users grant kubernetes dcos:secrets:list:default:/kubernetes read
dcos security org users grant kubernetes dcos:adminrouter:ops:ca:rw full
sleep 10
```
```
dcos security org users grant kubernetes dcos:adminrouter:ops:ca:ro full
dcos security org users grant kubernetes dcos:mesos:master:framework:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:framework:role:slave_public/kubernetes-role read
dcos security org users grant kubernetes dcos:mesos:master:reservation:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:volume:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:framework:role:slave_public read
dcos security org users grant kubernetes dcos:mesos:agent:framework:role:slave_public read
```

## Step 4 : Install Kubernetes
Create "k8s-options.json" configuration file.  Please add your options - this is default single node using service account & secret created in previous step
```
cat > k8s-options.json << 'EOF'
{
  "service": {
    "service_account": "kubernetes",
    "service_account_secret": "kubernetes/sa"
  }
}
EOF
```

Install Kubernetes on Cluster
```
dcos package install --yes kubernetes --options=k8s-options.json
```


## Step 5 : Expose Kubernetes apiserver via external load balancer (marathon-lb)
expose k8s apiserver via marathon-lb, see step on next page to identify public IP

Create Deployment Config File.
```
cat > kubectl-proxy.json << 'EOF'
{
  "labels": {
    "HAPROXY_0_MODE": "http",
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_BACKEND_SERVER_OPTIONS": "  server kube-apiserver apiserver.kubernetes.l4lb.thisdcos.directory:6443 ssl verify required ca-file /mnt/mesos/sandbox/.ssl/ca-bundle.crt\n",
    "HAPROXY_0_SSL_CERT": "/etc/ssl/cert.pem",
    "HAPROXY_0_PORT": "6443"
  },
  "id": "/kubectl-proxy",
  "backoffFactor": 1.15,
  "backoffSeconds": 1,
  "cmd": "tail -F /dev/null",
  "container": {
    "type": "MESOS",
    "volumes": []
  },
  "cpus": 0.001,
  "disk": 0,
  "instances": 1,
  "maxLaunchDelaySeconds": 3600,
  "mem": 16,
  "gpus": 0,
  "networks": [
    {
      "mode": "host"
    }
  ],
  "portDefinitions": [
    {
      "protocol": "tcp",
      "port": 10101
    }
  ],
  "requirePorts": false,
  "upgradeStrategy": {
    "maximumOverCapacity": 1,
    "minimumHealthCapacity": 1
  },
  "killSelection": "YOUNGEST_FIRST",
  "unreachableStrategy": {
    "inactiveAfterSeconds": 0,
    "expungeAfterSeconds": 0
  },
  "healthChecks": [],
  "fetch": [],
  "constraints": []
}
EOF
```

Deploy Config File
```
dcos marathon app add kubectl-proxy.json
```

Identify public IP on aws

In DC/OS gui find private IP of marathon-lb
```
dcos node
```
   HOSTNAME         IP                         ID                    TYPE             REGION     ZONE
 10.2.70.221   10.2.70.221  0364ec30-e715-461c-aa19-302b2b56a897-S6  agent             lb01   lb01-virt
 10.2.70.222   10.2.70.222  0364ec30-e715-461c-aa19-302b2b56a897-S5  agent             lb01   lb01-virt
 10.2.70.231   10.2.70.231  0364ec30-e715-461c-aa19-302b2b56a897-S7  agent             lb01   lb01-virt
 10.2.70.232   10.2.70.232  0364ec30-e715-461c-aa19-302b2b56a897-S4  agent             lb01   lb01-virt
 10.2.70.233   10.2.70.233  0364ec30-e715-461c-aa19-302b2b56a897-S2  agent             lb01   lb01-virt
 10.2.70.234   10.2.70.234  0364ec30-e715-461c-aa19-302b2b56a897-S1  agent             lb01   lb01-virt
 10.2.70.235   10.2.70.235  0364ec30-e715-461c-aa19-302b2b56a897-S3  agent             lb01   lb01-virt
 10.2.70.236   10.2.70.236  0364ec30-e715-461c-aa19-302b2b56a897-S0  agent             lb01   lb01-virt
master.mesos.  10.2.70.211    0364ec30-e715-461c-aa19-302b2b56a897   master (leader)   lb01   lb01-virt
master.mesos.  10.2.70.212                    N/A                    master            N/A       N/A
master.mesos.  10.2.70.213                    N/A                    master            N/A       N/A

```
dcos node ssh --user=rgonza --master-proxy --mesos-id=0364ec30-e715-461c-aa19-302b2b56a897-S5
```
Running `ssh -A -t  -l rgonza 10.2.70.211 -- ssh -A -t  -l rgonza 10.2.70.222 -- `

[rgonza@lb01virt-public2 ~]$
[rgonza@lb01virt-public2 ~]$ curl -s ifconfig.co
10.1.70.222
[rgonza@lb01virt-public2 ~]$



## Step 6 : Attach Kubectl to the Kubernetes cluster

attach to apiserver
```
dcos kubernetes kubeconfig --apiserver-url https://<public-node>:6443 --insecure-skip-tls-verify --no-activate-context
```
kubeconfig context 'public26443' updated successfully

```
kubectl get nodes
```
NAME                                   STATUS    ROLES     AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     <none>    5h        v1.10.3
kube-node-1-kubelet.kubernetes.mesos   Ready     <none>    1h        v1.10.3
kube-node-2-kubelet.kubernetes.mesos   Ready     <none>    1h        v1.10.3

## Step 7 : Launch proxy to Kubernetes Dashboard
start proxy to dashboard
```
kubectl proxy   
```  
Starting to serve on 127.0.0.1:8001

you can ‘ctrl-z’ then ‘bg’ this process above, or just run it in dedicated terminal window.  open web browser, I noticed dashboard can take a few minutes to be fully functional

http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
