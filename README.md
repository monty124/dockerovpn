# dockerovpn

docker openvpn/sab/transmission shell script for synology

no warranty use at your own risk!

note v2 is no longer maintained, there was stupidity with docker-compose and synology
I recommend using v1 either in syno or standalone

You will need the .env file

Usage: 

start

starts containers

stop

stops containers

status

status of containers

create

create containers based off compose yml file

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

1. ssh to your syno and login (if ssh is not enabled google it)

2. sudo to root (docker commands need root) sudo -i (use your admin password)

change directories to an appropriate location to store the script,

/volume1/docker maybe or /volume1/public, whatever!

3. download the script locally, set permissions and execute bit

easiest way is:

wget https://raw.githubusercontent.com/monty124/dockerovpn/master/docker_vpn.sh -O "docker_vpn.sh"

chmod -R 0755 "docker_vpn.sh"

chmod +x "docker_vpn.sh"

4. get the .env file and check it!

wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"

!! Make sure you check the .env files match your paths and environment (especially local subnet)

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
pull the updated script and .env
do the needful

urgh PIA changed their servers AGAIN
you can do a fork & pull request 
here's a tutorial!

https://github.com/firstcontributions/first-contributions


or open an issue 



