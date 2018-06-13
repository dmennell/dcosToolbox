# Secure Jenkins Deployment on Mesosphere Enterprise DC/OS
These instructions include what is needed to get Jenkins up and running on Enterprise DC/OS 1.11 using a Service Account and Secrets.  It assumes that your cluster is installed in SECURITY: PERMISSIVE.  For other instructions, please see the DC/OS Documentation.

## Jenkins Install Prerequisites
Execute the following on tour local laptop to setup access to the DC/OS Cluster

### Log Into Server via SSH and DC/OS via Browser UI

From either Firefox or Chrome, log into the DC/OS Browser UI using the credentials you have been supplied
```
https://<masterPublicIPAddress>
```

From your favorite SSH client (Termius, puTTy, iTerm, OSX Terminal, etc), connect to your DC/OS Bootstrap Node using appropriate system User ID & Password.
```
ssh <username>@<bootstrapNodePublicIpAddress>
```

### Install DC/OS CLI

1.  From the Browser UI, click the "Cluster Name" in the upper left-hand corner of the screen
2.  From the drop-down list, select "Install CLI"
3.  In the window that appears, select the OS type to which you will be installing (As it will be installed on your BootStrap Node, select Linux)
4.  Copy the commands as 1 large block of text.  It will resemble the following, except it include settings for your sopecific cluster

  ```
  [ -d /usr/local/bin ] || sudo mkdir -p /usr/local/bin && 
  curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.11/dcos -o dcos && 
  sudo mv dcos /usr/local/bin && 
  sudo chmod +x /usr/local/bin/dcos && 
  dcos cluster setup https://192.168.1.211 && 
  dcos
  ```
5.  Paste the copied text into your SSH session (the one where you connected to the DC/OS Bootstrap Node)
6.  Accept requests and enter userIDs and Passwords (first the password for the bootstrap node, Second the User ID and password for the DC/OS cluster account

### Install DC/OS Enterprise CLI
The Enterprise CLI, available only in Enterprise DC/OS provides access to Security and Backup Command Line interfaces
```
dcos package install --yes dcos-enterprise-cli
```

## Create Service Account, Privelages, and Secrets to Install Manage Jenkins

### Create Public-Private Key Pair
```
dcos security org service-accounts keypair jenkins-private-key.pem jenkins-public-key.pem
```

### Create and Verify a New Service Account "jenkins-principal"
```
dcos security org service-accounts create -p jenkins-public-key.pem -d "Jenkins service account" jenkins-principal
dcos security org service-accounts show jenkins-principal
```

### Create and Verify a new Secret "jenkins/jenkins-secret"
```
dcos security secrets create-sa-secret jenkins-private-key.pem jenkins-principal jenkins/jenkins-secret
dcos security secrets list /
```

### Delete Key from Local System
```
rm -rf jenkins-private-key.pem
```

### Retrieve the DC/OS CA Bundle
```
curl -k -v $(dcos config show core.dcos_url)/ca/dcos-ca.crt -o dcos-ca.crt
```

### Create Necessary Permissions
```
curl -X PUT --cacert dcos-ca.crt -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:task:user:nobody -d '{"description":"Allows Linux user nobody to execute tasks"}' -H 'Content-Type: application/json'

curl -X PUT --cacert dcos-ca.crt -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:framework:role:* -d '{"description":"Controls the ability of jenkins-role to register as a framework with the Mesos master"}' -H 'Content-Type: application/json'
```

### Grant Permissions and Allowed acrions to Service account
```
curl -X PUT --cacert dcos-ca.crt -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:framework:role:*/users/jenkins-principal/create

curl -X PUT --cacert dcos-ca.crt -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:task:user:nobody/users/jenkins-principal/create
```

## Install Jenkins on DC/OS

### Create "config.json" File
```
{
  "security": {
    "secret-name": "jenkins/jenkins-secret"
  },
  "service": {
    "user": "nobody"
  }
}
```

### Install & Verify Jenkins Deployment
```
dcos package install --options=config.json jenkins
```
1.  Go to the Services section of the Enterprise DC/OS Web UI.  Here you will see the Jenkins Service being deployed.
2.  When the status turns green (Running) click the callout box next to the "jenkins " service name
3.  A new tab should open with jenkins dashboard in it (if it fails, give the service a minute or two more to startup)

### Verify Jenkins is running with Service Account and Secrets

1.  Paste the following path into your browser:
    `URL: https://<cluster-url>/service/jenkins/configure`
2.  Scroll to the Mesos cloud area.
3.  Next to the Framework credentials field, click the Add button and select Jenkins.
4.  In the Username field, type "jenkins-principal".
5.  In the Password field, type any value.
6.  Once you have completed your entries, click Add.
7.  Click Apply and then click Save.
8.  Select the new jenkins-principal account in the Framework credentials list box.
9.  Click New item in the side menu.
10.  Click the "Freestyle project" button, type "Test service account" in the Enter an item name field, and press ENTER.
11.  Scroll down to the Build area.
12.  Click Add build step and select Execute shell.
13.  Type echo "hello world" in the Command field.
14.  Click Save.
      > The browser should display a Project test service account page.
15.  Click Build now from the side menu.
      > After some time, the job should turn green in the Build history box. Congratulations! You have succeeded in setting Jenkins up with a service account.

You can also provide the config.json file to someone else to install Jenkins. Please see the Jenkins documentation for more information about how to use the JSON file to install the service.
