

### Create Directories
```
mkdir -p dcos-install/genconf
cd dcos-install
```

### Create IP-detect Script
Below is an example that detects the IP address for "Eth0".  See ip-detect_examples for options.
```
cat > genconf/ip-detect << 'EOF'
#!/usr/bin/env bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH
echo $(ip addr show eth0 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
EOF
```

### Create public-ip-detect
Below is an example that detects the IP address for "Eth0".  See public-ip-detect_examples for options
```
cat > genconf/public-ip-detect << 'EOF'
#!/usr/bin/env bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH
echo $(ip addr show eth0 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
EOF
```

### Create license.txt file
copy the text from your license.txt file and insert where instructed
```
cat > genconf/license.txt << 'EOF'
<License File Text>
EOF
```

### Create Fault Domain Detect Script (optional)
Below example downloads a file that wil detect cloud provider (AWS, Azure, GCP) Public IP Addresses.  For other options, please see fault-domain-detect_examples.
```
curl -O https://raw.githubusercontent.com/dcos/dcos/master/gen/fault-domain-detect/cloud.sh
mv cloud.sh genconf/fault-domain-detect


### Create config.yaml
This is a sample config.yaml.  There are many options for 
```
cat > genconf/config.yaml << 'EOF'
bootstrap_url: http://<IP Address>:<Port>
cluster_name: '<clusterName>'
fault_domain_enabled: false
ip_detect_public_filename: genconf/public-ip-detect
exhibitor_storage_backend: static
master_discovery: static
master_list:
- <masterIpAddress>
- <masterIpAddress>
- <masterIpAddress>
resolvers:
- <dnsServerIp>
- <dnsServerIp>
security: permissive
superuser_password_hash: <HashGoesHere>
superuser_username: dcmennell
ssh_user: <linuxUserID>
EOF

### Get the DC/OS 1.11 Bits
curl -O https://downloads.mesosphere.com/dcos-enterprise/stable/1.11.4/dcos_generate_config.ee.sh

### Creat Password Hash
Put the output of this command in the it in config.yaml
#sudo bash dcos_generate_config.ee.sh --hash-password <adminPassword>

### Create the Docker Container
sudo bash dcos_generate_config.ee.sh

### Deploy the Docker Container
sudo docker run -d -p 80:80 -v ${PWD}/genconf/serve:/usr/share/nginx/html:ro nginx

Move to installing your your Master Node
