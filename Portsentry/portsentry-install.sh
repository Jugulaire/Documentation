#!/bin/bash

#Patch configuration file 

usage(){
	echo "-------------------------------------------------------------------------"
	echo "Usage :"
	echo "./install.sh [IP_To_Whitelist/CIDR]"
	echo "   "
	echo "Ex: with netmask of 255.255.255.0"
	echo "./install.sh 192.168.122.2/24"
	echo "-------------------------------------------------------------------------"
}

error(){
	echo "-------------------------------------------------------------------------"
	echo "ERREUR"
	echo "Impossible de continuer"
	echo "-------------------------------------------------------------------------"
}

if [ $# -eq 0 ]
then
	usage
	exit
fi


#Installation du paquet
apt update
apt install portsentry

if [ $? != '0' ]
then
	error
	exit
fi

#Configuration de portsentry
clear
sleep 2
echo "Configuration de portsentry.. "
sleep 2
echo "Activation blocage TCP .."
sleep 2
sed -ie 's/BLOCK_TCP="0"/BLOCK_TCP="1"/g' /etc/portsentry/portsentry.conf
echo "Activation blocage UDP .."
sleep 2
sed -ie 's/BLOCK_UDP="0"/BLOCK_UDP="1"/g' /etc/portsentry/portsentry.conf
echo "Activation blocage par iptables "
sleep 2
sed -ie 's/#KILL_ROUTE=\"\/sbin\/iptables -I INPUT -s $TARGET$ -j DROP\"/KILL_ROUTE=\"\/sbin\/iptables -I INPUT -s $TARGET$ -j DROP\"/g' /etc/portsentry/portsentry.conf
sed -ie 's/KILL_ROUTE=\"\/sbin\/route add -host $TARGET$ reject\"//#KILL_ROUTE=\"\/sbin\/route add -host $TARGET$ reject\"g' /etc/portsentry/portsentry.conf
echo "Whitelist .."
sleep 2
echo "$1" >> /etc/portsentry/portsentry.ignore.static
echo "Passage en mode audp et atcp"
sleep 2
sed -ie 's/TCP_MODE="tcp"/TCP_MODE="atcp"/g' /etc/default/portsentry
sed -ie 's/UDP_MODE="udp"/UDP_MODE="audp"/g' /etc/default/portsentry
sleep 2
echo " "
echo "Parametrage OK..."
echo " "
sleep 2
echo "Redemarrage du service ..."
service portsentry restart
service portsentry status
sleep 2
echo " "
echo "DONE !"
