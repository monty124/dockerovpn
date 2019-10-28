#!/bin/bash
# Version 2
# Updated to use docker-compose and .env file


stop(){
    clear
    echo -e "\033[31m\n stopping containers \033[0m"
    docker-compose -f dockerovpn.yml stop
    echo -e "\033[32m\n containers stopped \033[0m"
}

start(){
    clear
    echo -e "\033[32m\n  starting containers  \033[0m"
	docker-compose -f dockerovpn.yml start
}

update(){
    clear
	echo -e "\033[32m\n force updating all containers \033[0m"
	delete
	docker-compose -f dockerovpn.yml up --force-recreate -d
	echo -e "\033[32m\n all containers recreated \033[0m"
}

updateme(){
	clear
	echo -e "\033[32m\n updating THIS script only \033[0m"
	wget https://raw.githubusercontent.com/monty124/dockerovpn/master/docker_vpn.sh -O "docker_vpn.sh"
	source .env
	chown -R $PUID:$PGID "docker_vpn.sh"
	chmod -R 0755 "docker_vpn.sh"
	chmod +x "docker_vpn.sh"
	echo -e "\033[32m\n script updated \033[0m"
	exit
}

restart(){
    clear
    echo -e "\033[32m\n restarting all containers \033[0m"
    docker-compose -f dockerovpn.yml stop
	docker-compose -f dockerovpn.yml start
    echo -e "\033[32m\n containers restarted \033[0m"
}

status(){
    clear
	#yeah hacky workaround as docker-compose ps is shit
	CONTAINERS=($(docker-compose -f dockerovpn.yml config --service))
    echo -e "\033[32m\n container $i status \033[0m"
    for i in "${CONTAINERS[@]}"
    do
        docker container ls -f name=${i} --format='container {{.ID}} with name: {{.Names}} has been {{.Status}}'
    done
    echo -e "\n"
}

create(){
    clear
	if [ ! -f ".env" ]; then
    read -p "use git env settings (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            git_env_settings
			
        ;;
        * )
		    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"
            echo "Please manually configure each variable in the .env file first and rerun"
			exit
			
        ;;
    esac
	
	fi
	echo -e "\033[32m\n .env exists, using existing .env file \033[0m"
    source .env
    
	if [ ! -f "./dockerovpn.yml" ]; then
	echo -e "\033[31m\n downloading compose file from git \033[0m"
    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/dockerovpn.yml -O "dockerovpn.yml"
    chown -R $PUID:$PGID "dockerovpn.yml"
    chmod -R 0755 "dockerovpn.yml"    	
	fi
	
	echo -e "\033[31m\n create containers from compose file \033[0m"
    
	docker-compose -f dockerovpn.yml up --no-start
	
    echo -e "\033[31m\n create complete you may try a start now \033[0m"
	}

prepare(){
    clear
    read -p "use git env settings (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            git_env_settings
	
        ;;
        * )
		    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"
            echo "Please manually configure each variable in the .env file first and rerun"
			exit
			
        ;;
    esac
	source .env
	
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
	
	echo -e "\033[31m\n downloading compose file from git \033[0m"
    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/dockerovpn.yml -O "dockerovpn.yml"
    chown -R $PUID:$PGID "dockerovpn.yml"
    chmod -R 0755 "dockerovpn.yml"    	
	
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

git_env_settings(){
    echo -e "\033[31m\n get base env file \033[0m"
    wget https://raw.githubusercontent.com/monty124/dockerovpn/master/.env -O ".env"
	source ".env"
    chown -R $PUID:$PGID ".env"
    chmod -R 0755 ".env"
}

delete(){
    
    echo -e "\033[32m\n stopping & deleting containers and images \033[0m"
    docker-compose -f dockerovpn.yml down --rmi all
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
    update)
        update
    ;;
    updateme)
        updateme
    ;;    *)
        echo $"Usage: $0 {start|stop|status|create|restart|prepare|update|updateme|delete}"
        exit 1
esac

