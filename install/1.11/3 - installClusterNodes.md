### Install Master Nodes
```
mkdir /tmp/dcos && cd /tmp/dcos
curl -O http://<bootstrapIpAddress:80/dcos_install.sh && sudo bash dcos_install.sh master
```

### Install Public Agent Nodes
```
mkdir /tmp/dcos && cd /tmp/dcos
curl -O http://<bootstrapIpAddress:80/dcos_install.sh && sudo bash dcos_install.sh slave_public
```

### Install Private Agent Nodes
```
mkdir /tmp/dcos && cd /tmp/dcos
curl -O http://<bootstrapIpAddress:80/dcos_install.sh && sudo bash dcos_install.sh slave
```
