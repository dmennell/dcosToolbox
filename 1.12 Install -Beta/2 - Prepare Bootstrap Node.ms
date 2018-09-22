# Enterprise DC/OS 1.12 BETA - Prepare Bootstrap Node
After installing the "Prerequisites" on all nodes including the bootstrap nodes, do the following on the server designated as the Bootstrap node.

### Create Bootstrap Directories in Home Directory
```
mkdir -p dcos-install/genconf
cd dcos-install
```

### Create IP-detect
This is one example of creating an ip-detect script.  This assumes that the primary ethernet interface is `eth0`.  For cloud specific ip-detect scripts, please see the docs.
```
cat > genconf/ip-detect << 'EOF'
#!/usr/bin/env bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH
echo $(ip addr show eth0 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
EOF
```

### Create Fault Domain Detect Script
This example reads 2 files (/var/region and /var/zone) to populate the @region and @zone labels on dcos nodes.  For other examples , please see the documentation  
```
cat > genconf/fault-domain-detect << 'EOF'
#!/bin/bash
ZONE_FILE=/var/zone
REGION_FILE=/var/region
REGION=$(cat ${REGION_FILE})
ZONE=$(cat ${ZONE_FILE})
echo "{\"fault_domain\":{\"region\":{\"name\": \"${REGION}\"},\"zone\":{\"name\": \"${ZONE}\"}}}"
EOF
```

### Create public-ip-detect
The following script uses the `dig` command and opendns to determine the public ip of the cluster.
```
#!/usr/bin/env bash
dig +short myip.opendns.com @resolver1.opendns.com
```

### Create license.txt file
```
cat > genconf/license.txt << 'EOF'
<Insert-License-File-Contents-Here>
EOF
```

### Create config.yaml
This is an example config.yaml file with the minimum variables set.  The one optional variable set is the userID and password.  This is highly suggested if this cluster is to be at all exposed to the internet.  there are plenty of bitcoin miners out there that are looking for clusters with default user IDs and passwords.
```
cat > genconf/config.yaml << 'EOF'
bootstrap_url: http://<Bootstrap-IP-Address:Port>
cluster_name: 'Cluster Name'
fault_domain_enabled: True
ip_detect_public_filename: genconf/public-ip-detect
exhibitor_storage_backend: static
master_discovery: static
master_list:
- <Master-IP-Address> 
resolvers:
- <DNS-Server-1>
- <DNS Server-2>
security: permissive
superuser_password_hash: <HashGoesHere>
superuser_username: <default-user-ID>
ssh_user: <default-ssh-user-ID
EOF
```

### Get the Bits
```
curl -O <https://downloads.mesosphere.io/blah blah blah (get the most recent url from the support site)>
```

### Create Password Hash (put it in config.yaml @ <HashGoesHere>)
```
sudo bash dcos_generate_config.ee.sh --hash-password <default-user-ID>
```

### Create the Docker Container
```
sudo bash dcos_generate_config.ee.sh
```

### Deploy the Docker Container
```
sudo docker run -d -p 80:80 -v ${PWD}/genconf/serve:/usr/share/nginx/html:ro nginx
```
### Verify Container Launched
```
sudo docker ps
```

Move on to Installing Nodes (Master, Private Agent, and Public Agent)
