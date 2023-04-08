#!/bin/sh
# ##################################
# This script runs the remote script
# on the newly created instance and
# installs Wireguard on it
# You will need the software packages 
# curl, sshpass, jq and wireguard installed!
# on OpenWrt you also need openssh-client
# ##################################

# include the parameters from the previous createInstance.sh run
. ./.instance

# Let's determine if this is an OpenWrt Router or not
OPENWRT=FALSE
if (grep "OpenWrt" /etc/device_info); then OPENWRT=TRUE; fi

# the first parameter is the name of our local Wireguard interface, 
# e.g. wg0
if [ -z "$1" ] ; then
  LOCAL_WG_INTERFACE=wg0
else
  LOCAL_WG_INTERFACE=$1
fi

# the second parameter is the public key of our local Wireguard 
# Interface. If there is none, then we create it on the fly
# The Wireguard tools need to be present for this
# If we are on an OpenWrt Router, then we will derive it from the 
# interface settings from UCI
if [ ! -z "$2" ] ; then
  LOCAL_PUBLIC_KEY=$2
  LOCAL_PRIVATE_KEY=
else
  if [ "$OPENWRT" = "TRUE" ] ; then
    LOCAL_PRIVATE_KEY=$(uci show network.${LOCAL_WG_INTERFACE}.private_key | cut -d \' -f 2)
  else
    LOCAL_PRIVATE_KEY=`wg genkey`
  fi
  LOCAL_PUBLIC_KEY=$(echo "$LOCAL_PRIVATE_KEY" | wg pubkey)
fi

# ##################################
# Now ssh into the new server for a
# first time and accept the host 
# key. Wait until the 
# instance is ready
# ##################################

SSHRESULT=""
while [ ! "SSHRESULT" = "OK" ] ; do
  if (sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no root@${INSTANCE_IP} echo "Hello") ; then
    SSHRESULT=OK
  fi
  sleep 5
done

# ##################################
# Now ssh into the new server and
# Create a Wireguard Server on it
# It may take a while until the 
# instance is really ready
# ##################################

# if we have a local script, then we just copy it over to the server
# if not, then we instruct the server to pull the script from
# Marc's Github Repo
if [ -e remotescript.sh ] ; then
  sshpass -p "${SSH_PASS}" scp remotescript.sh root@${INSTANCE_IP}:/root/remotescript.sh
else
  sshpass -p "${SSH_PASS}" ssh root@${INSTANCE_IP} "wget https://raw.githubusercontent.com/onemarcfifty/api_vpn/master/remotescript.sh"
fi

# now we just execute it on the remote host
sshpass -p "${SSH_PASS}" ssh root@${INSTANCE_IP} "bash remotescript.sh $LOCAL_PUBLIC_KEY"

# the script has set the (remote) Environment variable SERVER_PUBLIC_KEY
# which contains the Wireguard public key of the remote instance
SERVER_PUB_KEY=$(sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no root@${INSTANCE_IP} "cat .serverkey")
echo "The Server has the public key $SERVER_PUB_KEY"
echo "SERVERKEY=$SERVER_PUB_KEY" >>.instance

# Now we add the remote peer to our local config

# if we run this on an OpenWrt Router then we use uci
# if not, then we use the normal Wireguard tools
if [ "$OPENWRT" = "TRUE" ] ; then
  # we assume that the local Wireguard interface only has one peer
  # We delete the entry and create it new from scratch
  uci delete network.@wireguard_${LOCAL_WG_INTERFACE}[0]
  uci add network wireguard_${LOCAL_WG_INTERFACE} >/dev/null 2>&1
  
  # Now we add a new entry with the parameters from above 
  uci set network.@wireguard_${LOCAL_WG_INTERFACE}[-1].public_key="$SERVER_PUB_KEY"
  uci set network.@wireguard_${LOCAL_WG_INTERFACE}[-1].description="REMOTE"
  uci add_list network.@wireguard_${LOCAL_WG_INTERFACE}[-1].allowed_ips="0.0.0.0/0"
  uci set network.@wireguard_${LOCAL_WG_INTERFACE}[-1].route_allowed_ips='1'
	uci set network.@wireguard_${LOCAL_WG_INTERFACE}[-1].persistent_keepalive='25'

  uci commit
 
else
  # add the new peer to the wg0 config file
  wg set ${LOCAL_WG_INTERFACE} peer $SERVER_PUB_KEY allowed-ips "0.0.0.0/0"
  wg-quick down ${LOCAL_WG_INTERFACE} && wg-quick up ${LOCAL_WG_INTERFACE}
fi
