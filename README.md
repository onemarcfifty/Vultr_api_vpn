# VPN on demand with vultr API

the scripts in this repo will create an instance in vultr using the V2 API and install Wireguard on it. You can use this in order to create a "VPN on demand".

## How to use

1. Clone or unzip the repo 
2. rename `.apikey_sample` to `.apikey` and edit the api key to your real api key
3. launch the script `createInstance.sh <location>` (location is a vulture location, so e.g. fra for Frankfurt or cdg for Paris)
4. Launch the script `installInstance.sh [wireguardif] [pubkey]` (`wireguardif` is the name of your local Wireguard interface, if omitted it defaults to wg0. `pubkey` is the public key of your local Wireguard. If omitted, it will be created on the fly. the private key will however not be added to your server. that's Work in progress.)

You're done - you have a VPN Server.

## Running it on Debian or OpenWrt or...

The scripts have been tested on Debian 11 and OpenWrt. They _should_ run on other distros, but I haven't teted that. Please keep in mind that you need to have the following software packages installed as a pre-requisite:

- curl (in order to download the scripts from github etc.)
- sshpass (in order to connect to the vultr instance over ssh with password)
- jq (to parse the json output from the vultr api)
- Wireguard (of course...)

**on OpenWrt you also need openssh-client** - the busybox / dropbear ssh client does not provide any method of connecting to an ssh server and automatically have it added to the `~/.ssh/known_hosts` file - that means that a first connection would either need you to press a key ("y") or - if you used `ssh -y` it would connect but it would not add the host to the known hosts, therefore the scp command will ask for a key again. That's not a big thing if you run it attended, but the scripts are designed to be ran unattended.

## Destroying the server

If you don't need it anymore, just run `destroyInstance.sh` and the Server will be destroyed.

## using ansible with VULTR

in the `ansible` subdfolder you can find some playbook examples on how to create or destroy instances with the Vultr API. They are not used here but I include them in the repo for your reference. There is also an example inventory file.
