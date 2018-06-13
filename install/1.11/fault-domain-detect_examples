### File (REG:ZONE-N)
script parses a file stored in the /var directory.

```
#!/bin/bash
DETECT_FILE=/var/regionZone
REGION=$(cat ${DETECT_FILE} | head -c3)
ZONE=$(cat ${DETECT_FILE})
echo "{\"fault_domain\":{\"region\":{\"name\": \"${REGION}\"},\"zone\":{\"name\": \"${ZONE}\"}}}"
```
the File Contents should have the folllowing format: RRR:ZZZZ-N
"RRR" is parsed off as the Region (Think Airport Code)
The whole string represents the Zone Name (PHL-ZONE-1)
