#!/bin/bash
# ##################################
# This script runs on the newly 
# created instance and
# installs Wireguard on it
# ##################################

# The first and only mandatory parameter is the public key of the peer
REMOTE_PUBLIC_KEY=$1

# second optional parameter is the clientname
[[ ! -z "$2" ]] && WGCLIENTNAME=$2 || WGCLIENTNAME=newclient

# third optional parameter is the IP address it gets on the VPN
[[ ! -z "$3" ]] && WGCLIENTADDRESS=$3 || WGCLIENTADDRESS="192.168.88.2/24"

echo -e "\ngenerating peer $WGCLIENTNAME with IP $WGCLIENTADDRESS and public key $REMOTE_PUBLIC_KEY\n"

# For the Wireguard installation we can use Marc's VPS Install Script
# This will install a wg0 interface with a new private key and add
# the necessary routing and masquerading. The interface
# by default has the 192.168.88.1/24 address
apt update
apt install wget 
wget https://raw.githubusercontent.com/onemarcfifty/wireguard_vps_vpn/master/wireguard.sh -O wireguard.sh
bash wireguard.sh 

# We add a firewall rule in order to let traffic in on UDP port 51820
# and allow routing out to enp1s0
ufw allow in on wg0 
ufw allow 51820/udp 
#ufw route allow in on wg0 out on enp1s0 

# read out this server's pubkey
#readarray -d : -t templine <<< $(wg | grep "public key")
#export SERVER_PUBLIC_KEY=${templine[1]};
export SERVER_PUBLIC_KEY=$(wg | grep "public key" | cut -d " " -f 5)
echo $SERVER_PUBLIC_KEY >.serverkey

# add the new peer to the wg0 config file
wg set wg0 peer $REMOTE_PUBLIC_KEY allowed-ips "$WGCLIENTADDRESS,192.168.0.0/24,10.0.0.0/8"

# we need to down and up the interface in order to 
# make changes persistent
wg-quick down wg0 && wg-quick up wg0
