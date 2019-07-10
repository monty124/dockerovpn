#!/bin/bash

#container names
#openvpn container first in array! hardcoded array value 0 in network link because CBF handling it
declare -a CONTAINERS=("openvpn" "transmission" "sabnzbd")
#container images
declare -a IMAGES=("dperson/openvpn-client" "linuxserver/transmission" "linuxserver/sabnzbd")

#change these to match your paths
trans_config="/volume1/docker/transmission"
trans_download="/volume1/Downloads"
trans_watch="/volume1/Downloads/watch"

container_downloads=""

vpn_home="/volume1/docker/openvpn"

sab_config="/volume1/docker/sabnzbd"
sab_download="/volume1/Downloads"
sab_incomplete="/volume1/Downloads/incomplete"

#run as this user
PGID=100
PUID=1024

#local subnet and timezone
LOCAL_NET=""
TIMEZONE="Australia/Sydney"
TUN_SH="/volume1/public"


stop(){
    clear
    for i in "${CONTAINERS[@]}"
    do
        echo -e "\033[31m\n stopping container $i \033[0m"
        docker stop "$i" > /dev/null
        echo -e "\033[32m\n container $i stopped \033[0m"
    done
}

start(){
    clear
    for i in "${CONTAINERS[@]}"
    do
        if docker start "$i" | egrep "($i)" > /dev/null ; then
            echo -e "\033[32m\n  container $i started  \033[0m"
        else
            echo -e "\033[31m\n  container $i start error  \033[0m"
        fi
    done
}

status(){
    clear
    echo -e "\033[32m\n container $i status \033[0m"
    for i in "${CONTAINERS[@]}"
    do
        docker container ls -f name=${i} --format='container {{.ID}} with name: {{.Names}} has been {{.Status}}'
    done
    echo -e "\n"
}

create(){
    clear
    COUNT=0
	echo -n "Local Subnet? (eg 192.168.1.0/24) [ENTER]: "
    read LOCAL_NET
	echo -n "Container Downloads? (eg downloads or Downloads?) [ENTER]: "
	read container_downloads
    for i in "${CONTAINERS[@]}"
    do
        RES=""
        RES=$(docker ps -a --no-trunc  --format "{{.Names}}"  | grep "^${i}$")
        echo $RES
        if [ -n "$RES" ]; then
            COUNT=$((COUNT + 1))
        else
            echo -e "\033[32m\n Container $i not found \033[0m"
        fi
    done
    if [ "$COUNT" -ne "0" ]; then
        clear
        arraylength=${#CONTAINERS[@]}
        for (( i=0; i<${arraylength}; i++ ));
        do
            echo -e "\033[32m\n stopping container ${CONTAINERS[$i]} \033[0m"
            docker stop "${CONTAINERS[$i]}" > /dev/null
            echo -e "\033[31m\n deleting container ${CONTAINERS[$i]} \033[0m"
            docker rm "${CONTAINERS[$i]}" > /dev/null
            echo -e "\033[32m\n pulling image ${IMAGES[$i]} \033[0m"
            docker pull "${IMAGES[$i]}"
            echo -e "\033[32m\n creating container ${CONTAINERS[$i]} \033[0m"
            ${CONTAINERS[$i]} ${CONTAINERS[$i]}
        done
    else
        arraylength=${#CONTAINERS[@]}
        for (( i=0; i<${arraylength}; i++ ));
        do
            echo -e "\033[32m\n pulling image ${IMAGES[$i]} \033[0m"
            docker pull "${IMAGES[$i]}"
            echo -e "\033[32m\n creating container ${CONTAINERS[$i]} \033[0m"
            ${CONTAINERS[$i]} ${CONTAINERS[$i]}
        done
    fi
    
    echo -e "\033[31m\n create complete you may try a start now \033[0m"
}


restart(){
    clear
    echo -e "\033[32m\n restarting all containers \033[0m"
    for i in "${CONTAINERS[@]}"
    do
        docker restart "$i" > /dev/null
    done
    echo -e "\033[32m\n containers restarted \033[0m"
}

prepare(){
    clear
    echo -e "\033[32m\n checking paths exist \033[0m"
    echo -e "\033[31m\n checking transmission paths \033[0m"
    
    if [ -d "$trans_config" ]; then
        echo -e "\033[32m\n $trans_config path exists \033[0m"
    else
        echo -e "\033[32m\n creating $trans_config path \033[0m"
        mkdir $trans_config
        chown -R $PUID:$PGID $trans_config
        chmod -R 0755 $trans_config
    fi
    
    if [ -d "$trans_download" ]; then
        echo -e "\033[32m\n $trans_download path exists \033[0m"
    else
        echo -e "\033[32m\n creating $trans_download path \033[0m"
        mkdir $trans_download
        chown -R $PUID:$PGID $trans_download
        chmod -R 0755 $trans_download
    fi
    
    if [ -d "$trans_watch" ]; then
        echo -e "\033[32m\n $trans_watch path exists \033[0m"
    else
        echo -e "\033[32m\n creating $trans_watch path \033[0m"
        mkdir $trans_watch
        chown -R $PUID:$PGID $trans_watch
        chmod -R 0755 $trans_watch
    fi
    
    echo -e "\033[31m\n checking sabnzb paths \033[0m"
    
    if [ -d "$sab_config" ]; then
        echo -e "\033[32m\n $sab_config path exists \033[0m"
    else
        echo -e "\033[32m\n creating $sab_config path \033[0m"
        mkdir $sab_config
        chown -R $PUID:$PGID $sab_config
        chmod -R 0755 $sab_config
    fi
    
    if [ -d "$sab_download" ]; then
        echo -e "\033[32m\n $sab_download path exists \033[0m"
    else
        echo -e "\033[32m\n creating $sab_download path \033[0m"
        mkdir $sab_download
        chown -R $PUID:$PGID $sab_download
        chmod -R 0755 $sab_download
    fi
    
    if [ -d "$sab_incomplete" ]; then
        echo -e "\033[32m\n $sab_incomplete path exists \033[0m"
    else
        echo -e "\033[32m\n creating $sab_incomplete path \033[0m"
        mkdir $sab_incomplete
        chown -R $PUID:$PGID $sab_incomplete
        chmod -R 0755 $sab_incomplete
    fi
    
    echo -e "\033[31m\n checking openvpn path \033[0m"
    
    if [ -d "$vpn_home" ]; then
        echo -e "\033[32m\n $vpn_home path exists \033[0m"
    else
        echo -e "\033[32m\n creating $vpn_home path \033[0m"
        mkdir $vpn_home
        chown -R $PUID:$PGID $vpn_home
        chmod -R 0755 $vpn_home
    fi
    
    echo -e "\033[31m\n checking TUN script path \033[0m"
    if [ ! -f "$TUN_SH/tun.sh" ]; then
        wget https://raw.githubusercontent.com/monty124/dockerovpn/master/tun.sh -O "$TUN_SH/tun.sh"
        chmod 0744 "$TUN_SH/tun.sh"
    fi
    
    echo -e "\033[31m\n openvpn setup \033[0m"
    
    read -p "Configure for PIA VPN (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            PIA
        ;;
        * )
            read -p "Configure for NORD VPN (y/n)? " answer
			case ${answer:0:1} in
				y|Y )
					NORD
				;;
				* )
			echo "Please manually configure vpn files in $vpn_home"
        ;;
    esac
        ;;
    esac
	
    
    echo -e "\033[31m\n preparation complete you may try a create now \033[0m"
    
    echo -e "\033[32m\n remember to create tasks for start and tun.sh in Synology Task Scheduler, tun must run first at boot \033[0m"
    
    echo -e "\033[32m\n it is recommended to also create a restart task daily to ensure the openvpn connection remains connected \033[0m"
}

PIA(){
    if [ ! -f "$vpn_home/vpn.cert_auth" ]; then
        echo -n "Enter your PIA username [ENTER]: "
        read username
        echo -n "Enter your PIA password [ENTER]: "
        read -s password
        echo -e "$username\n$password" >> "$vpn_home/vpn.cert_auth"
    fi
    echo -e "\033[31m\n get openvpn certificate files \033[0m"
    #https://www.privateinternetaccess.com/helpdesk/kb/articles/which-encryption-auth-settings-should-i-use-for-ports-on-your-gateways-2
    wget https://www.privateinternetaccess.com/openvpn/crl.rsa.2048.pem -O "$vpn_home/crl.rsa.2048.pem"
    wget http://www.privateinternetaccess.com/openvpn/ca.rsa.2048.crt -O "$vpn_home/crl.rsa.2048.crt"
    echo -e "\033[31m\n create config file \033[0m"
    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/vpn.conf -O "$vpn_home/vpn.conf"
    chown -R $PUID:$PGID $vpn_home
    chmod -R 0755 $vpn_home
    chown -R root:root "$vpn_home/vpn.cert_auth"
    chmod 0600 "$vpn_home/vpn.cert_auth"
    
    echo -e "\033[32m\n docker paths ready \033[0m"
    
    
    read -p "Configure transmission settings (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            trans_settings
        ;;
        * )
            echo "Please manually configure transmission settings in settings.json in $trans_config after starting container"
        ;;
    esac
}

NORD(){
    if [ ! -f "$vpn_home/vpn.cert_auth" ]; then
        echo -n "Enter your NORD username [ENTER]: "
        read username
        echo -n "Enter your NORD password [ENTER]: "
        read -s password
        echo -e "$username\n$password" >> "$vpn_home/vpn.cert_auth"
    fi
    cd "$vpn_home"
	echo -e "\033[31m\n get NORD config files \033[0m"
	rm -f ./au*.nordvpn.com.tcp.ovpn
	rm -f ./vpn.conf
	wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip -O ovpn.zip
	
	7z e ovpn.zip au*.nordvpn.com.tcp.ovpn -r
	
	ls au*.ovpn
	
	echo -n "please choose a server by typing its number, eg for au279.nordvpn.com.tcp.ovpn type 279 [ENTER]: "
	read servernumber
	
	sed 's/auth-user-pass/auth-user-pass vpn.cert_auth/g' au$servernumber.nordvpn.com.tcp.ovpn > vpn.conf
	
	rm -f ovpn.zip
	
    chown -R $PUID:$PGID $vpn_home
    chmod -R 0755 $vpn_home
    chown -R root:root "$vpn_home/vpn.cert_auth"
    chmod 0600 "$vpn_home/vpn.cert_auth"
	
	read -p "Configure transmission settings (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            trans_settings
        ;;
        * )
            echo "Please manually configure transmission settings in settings.json in $trans_config after starting container"
        ;;
    esac

}

trans_settings(){
    echo -e "\033[31m\n get base transmission settings file \033[0m"
    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/settings.json -O "$trans_config/settings.json"
    chown -R $PUID:$PGID $trans_config
    chmod -R 0755 $trans_config
}

delete(){
    for i in "${CONTAINERS[@]}"
    do
        echo -e "\033[32m\n stopping container $i \033[0m"
        docker stop "$i" > /dev/null
        echo -e "\033[32m\n deleting container $i \033[0m"
        docker rm "$i" > /dev/null
    done
}

transmission(){
    name=$1
    docker create \
    --name=$name \
    -v $trans_config:/config \
    -v $trans_download:/$container_downloads \
    -v $trans_watch:/watch \
    --restart always \
    -e PGID=$PGID \
    -e PUID=$PUID \
    -e TZ=$TIMEZONE \
    --net=container:${CONTAINERS[0]} \
    linuxserver/transmission
}

openvpn(){
    name=$1
    docker create \
    --cap-add=NET_ADMIN \
    --device /dev/net/tun \
    --name $name \
    --restart always \
    -v $vpn_home:/vpn \
    --env TZ=$TIMEZONE \
    --env ROUTE=$LOCAL_NET \
    -p 9091:9091 \
    -p 8080:8080 \
    -p 9090:9090 \
    --dns 1.1.1.1 \
    dperson/openvpn-client
}

sabnzbd(){
    name=$1
    docker create \
    --name=$name \
    --restart always \
    -v $sab_config:/config \
    -v $sab_download:/$container_downloads \
    -v $sab_incomplete:/incomplete-downloads \
    -e PGID=$PGID \
    -e PUID=$PUID \
    -e TZ=$TIMEZONE \
    --net=container:${CONTAINERS[0]} \
    linuxserver/sabnzbd
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    status)
        status
    ;;
    create)
        create
    ;;
    restart)
        restart
    ;;
    prepare)
        prepare
    ;;
    delete)
        delete
    ;;
    *)
        echo $"Usage: $0 {start|stop|status|create|restart|prepare|delete}"
        exit 1
esac

