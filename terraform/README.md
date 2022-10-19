
## Terraform

Some terraform code to deploy complementary services

````
EnableRemoteDocker
This code Enables remote docker connectivity on Synology devices but the code could be adapted to standalone boxes, ymmv.

Radarr
https://github.com/linuxserver/docker-radarr

Sonarr
https://github.com/linuxserver/docker-sonarr

````

## How do I use this?

### Install Terraform

The easiest way is to use winget

```
    winget install terraform
```
I also recommend Powershell 7 and Windows Terminal

### Run the Code

- From within the code folder
- setup terraform
```
    terraform init
```
- plan your deployment and answer any questions  eg:
```
    terraform plan -out=sonarr
```
- review the plan
- Apply the config eg:
```
    terraform apply ".\sonarr"
    
```
- review and make sure it worked!
- log on to your web portals using the default ports


