# VPN on demand with vultr API

the scripts in this repo will create an instance in vultr using the V2 API and install Wireguard on it. You can use this in order to create a "VPN on demand".

## How to use

1. Clone or unzip the repo 
2. rename `.apikey_sample` to `.apikey` and edit the api key to your real api key
3. launch the script `createInstance.sh <location>` (location is a vulture location, so e.g. fra for Frankfurt or cdg for Paris)
4. Launch the script `installInstance.sh`

You're done - you have a VPN Server.

## Destroying the server

If you don't need it anymore, just run `destroyInstance.sh` and the Server will be destroyed.
