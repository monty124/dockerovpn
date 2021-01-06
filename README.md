# dockerovpn

docker openvpn/sab/transmission shell script for synology

no warranty use at your own risk!

note v2 is no longer maintained, there was stupidity with docker-compose and synology
I recommend using v1 either in syno or standalone

You will need the .env file

./docker_vpn.sh <command>

Commands: 

start

starts containers

stop

stops containers

status

status of containers

create

create containers (v2 based off compose yml file)

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




How do I get started?

1. ssh to your syno ip address as admin and login 

https://www.synology.com/en-global/knowledgebase/DSM/tutorial/General_Setup/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet

2. if you have not already, sudo to root (docker commands need root) sudo -i (use your admin password)

change directories to an appropriate location to store the script,

/volume1/docker maybe or /volume1/public, whatever!

3. download the script locally, set permissions and execute bit

easiest way is:

wget https://raw.githubusercontent.com/monty124/dockerovpn/master/docker_vpn_v1 -O "docker_vpn.sh"

chmod -R 0755 "docker_vpn.sh"

chmod +x "docker_vpn.sh"

4. get the .env file and check it!

wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"

!! Make sure you check the .env files match your paths and environment (especially local subnet)

enable or disable services in the .env file
i.e.
enable_trans=true/false
enable_sab=true/false
enables or disables transmission and or sabnzb

5. run the script with the prepare flag

./docker_vpn.sh prepare

5. do a create 

./docker_vpn.sh create

6. do a start

./docker_vpn.sh start

7. check your services are up

navigate using a browser to 

http://<synoip>:<sabport> for sab

http://<synoip>:9091/transmission/web/ for transmission

use the torrent file in my git to confirm vpn is working!

thats all!


upgrading from my old script?


delete all your containers

pull the updated script and/or update your .env

do the needful


.env file changes for v3 commit

add these to your env file

an update will pull the rest


```
enable_trans=true/false
enable_sab=true/false
othercontainer=true
othercontainerdotfilename=othercontainer
```





urgh PIA changed their servers AGAIN
you can do a fork & pull request 
here's a tutorial!

https://github.com/firstcontributions/first-contributions


or open an issue 

Whats this othercontainer thing?

new feature! 
see the othercontainer example, you can edit and change where needed or run the example!
grab the .othercontainer file and give it a go!
 




Problems?

lsmod issues? try

sudo modprobe ip_tables

sudo echo 'ip_tables' >> /etc/modules

and

sudo modprobe ip6table_filter

or as root


no traffic in the qbitorrent container?

change the settings to bind to the tun device (all ipv4)




