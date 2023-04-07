#!/bin/sh

. ./.instance
# ##################################
# Now ssh into the new server and
# Create a Wireguard Server on it
# It may take a while until the 
# instance is really ready
# ##################################

# These are the commands that we need to execute remotely
# in order to have a wireguard server on the remote host
REMOTECOMMANDS=`cat <<EOF 
apt update
apt install wget 
wget https://raw.githubusercontent.com/onemarcfifty/wireguard_vps_vpn/master/wireguard.sh 
bash wireguard.sh 
wget https://raw.githubusercontent.com/onemarcfifty/wireguard_vps_vpn/master/addpeer.sh 
bash addpeer.sh 
ufw allow in on wg0 
ufw allow 51820/udp 
ufw route allow in on wg0 out on enp1s0 
EOF`

echo "$REMOTECOMMANDS"

sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no root@${INSTANCE_IP} "${REMOTECOMMANDS}"

