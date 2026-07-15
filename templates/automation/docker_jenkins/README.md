# Jenkins CI/CD

[Jenkins](https://www.jenkins.io) is the OG CI/CD automation server.

## Setup

### Retrieve admin password

During the first boot, you will see log lines with the admin password, and a hint telling you where to find it in the container:

```shell
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> Jenkins initial setup is required. An admin user has been created and a password generated.
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> Please use the following password to proceed to installation:
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> 
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> 
YYYY-mm-ddTHH:MM:SS.0Z [jenkins-server-1] [LF]> This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```
