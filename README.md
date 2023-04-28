# dockerovpn

docker openvpn/sab/transmission shell script for synology

no warranty use at your own risk!

You will need the .env file and you will need to alter its parameters to suit

```
./docker_vpn.sh <command>

Commands: 

start

starts containers

stop

stops containers

status

status of containers

create

create containers 

restart

restart containers

prepare

prepare container paths and supplemantary files

delete

deletes containers

update

updates the core script from git!! (yes really)

piaconf

stops, pulls conf file from git to update; updates certs prompts to update creds file, starts

failover

does a check of current ip against DNS and stops or starts containers

```



## How do I get started?

1. ssh to your syno ip address as admin and login 

https://www.synology.com/en-global/knowledgebase/DSM/tutorial/General_Setup/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet

2. if you have not already, sudo to root (docker commands need root) sudo -i (use your admin password)

change directories to an appropriate location to store the script,

/volume1/docker maybe or /volume1/public, whatever!

3. download the script locally, set permissions and execute bit

easiest way is:

```
wget https://raw.githubusercontent.com/monty124/dockerovpn/master/docker_vpn -O "docker_vpn.sh"

chmod -R 0755 "docker_vpn.sh"

chmod +x "docker_vpn.sh"
```
4. get the .env file and check it!
```
wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"
```
!! Make sure you check the .env files match your paths and environment (especially local subnet)
also take note on the transmission download path (trans_download) it is also used in the terraform code (if you're using it!)

enable or disable services in the .env file
i.e.
```
enable_trans=true/false
enable_sab=true/false
```
enables or disables transmission and or sabnzb

5. run the script with the prepare flag
```
./docker_vpn.sh prepare
```
5. do a create 
```
./docker_vpn.sh create
```
6. do a start
```
./docker_vpn.sh start
```
7. check your services are up

navigate using a browser to 
```
http://<synoip>:<sabport> for sab

http://<synoip>:9091/transmission/web/ for transmission
```
use the torrent file or magnet link in the magnet file in my git to confirm vpn is working!

thats all!


## upgrading from my old script?


delete all your containers

pull the updated script and/or update your .env

do the needful


## Terraform

Yes there's now some terraform code to deploy complementary services

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
- edit the .sonarr or .radarr file to ensure it is relavent to your local network
- setup terraform
```
    terraform init
```
- plan your deployment and answer any questions eg:
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

## Notes

The terraform code uses values from the .env file as well as its own dot env files, I also assume you are using transmission and it will use the transmission download folder; so even if you are not using transmission make sure this variable is set correct in your .env file 

# Changes

## .env file changes for v2 to v3 commit

add these to your env file and an update will pull the rest


```
enable_trans=true/false
enable_sab=true/false
othercontainer=true
othercontainerdotfilename=othercontainer
```

## urgh PIA changed their servers AGAIN
you can do a fork & pull request 
here's a tutorial!

https://github.com/firstcontributions/first-contributions

or open an issue 

## Whats this othercontainer thing?

new feature!
 
see the othercontainer example, you can edit and change where needed or run the example!

grab the .othercontainer file and give it a go!

&nbsp;

## failover?

Yeah..... new feature!!!

Why??

Well if you have a failover service to 4G for example, you may not want to download a metric shit ton over it if your main connection fails for an extended time, so this is an attempt to avoid that; we could do something with like static routes and shit but hey just kill the containers its easy

REQUIRES!

- A DNS 'A' record set to your usual IP Address, note, DDNS records may update in between the script running so this needs to be clunky! if your DHCP IP changes (your containers will stop on the main service) manually update the record, set a low ttl wait for settings to propagate and rerun the script!

    Also if you're using cloudflare make sure the A record is not proxied; a lookup needs to return your actual IP

- A scheduled task on the syno to run this like every 5 mins, every minute is freaking overkill; we're just trying to avoid or minimise things here 

- pull the new script (see update flag)

- add a line at the bottom of your .env like this

    DNS=thisismy.dns.something

- set up your user defined scheduled task so it looks like this (make sure your task scheduler is logging under settings, tick save output results):

    run as root

    run daily, every 5 mins, last run 23:55

    tick send details by email and tick when terminates abnormally (this will email you if it fails over and back)

    command:

    cd <your path to this script>
    bash ./docker_vpn.sh failover

THATS IT!

&nbsp;

# Problems?

## lsmod issues? try
```
sudo modprobe ip_tables
sudo echo 'ip_tables' >> /etc/modules
and
sudo modprobe ip6table_filter
or as root
```

## no traffic in the qbitorrent container?

change the settings to bind to the tun device (all ipv4)




