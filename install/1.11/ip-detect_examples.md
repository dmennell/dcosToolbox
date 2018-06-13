### AWS
Using Amazon Metadata Service
```
#!/bin/sh
Example ip-detect script using an external authority
Uses the AWS Metadata Service to get the node's internal
ipv4 address
curl -fsSL http://169.254.169.254/latest/meta-data/local-ipv4
```

### GCE
Using Google Cloud Metaserver
```
#!/bin/sh
Example ip-detect script using an external authority
Uses the GCE metadata server to get the node's internal
ipv4 address
curl -fsSL -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip
```

### Interface Identifier
Using the IP address of a specivied interface
```
#!/usr/bin/env bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH
echo $(ip addr show eth0 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
```

### Route to Mesos Master
```
#!/usr/bin/env bash
set -o nounset -o errexit -o pipefail
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH
MASTER_IP=$(dig +short master.mesos || true)
MASTER_IP=${MASTER_IP:-172.28.128.3}
INTERFACE_IP=$(ip r g ${MASTER_IP} | \
awk -v master_ip=${MASTER_IP} '
BEGIN { ec = 1 }
{
  if($1 == master_ip) {
    print $7
    ec = 0
  } else if($1 == "local") {
    print $6
    ec = 0
  }
  if (ec == 0) exit;
}
END { exit ec }
')
echo $INTERFACE_IP
```

