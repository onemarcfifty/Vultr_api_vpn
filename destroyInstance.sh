#!/bin/sh

# ##################################
# destroy the remote instance
# ##################################

# the .apikey file contains our secret API Key
. ./.apikey

# if an instance had previously been created
# then it has been saved into the .instance file
touch ./.instance
. ./.instance

# We use the vultr V2 api
APIENDPOINT="https://api.vultr.com/v2"

if [ -n $INSTANCE_ID ]; then
  API_RESPONSE=$(curl -s -H "Authorization: Bearer $APIKEY" \
               -X DELETE \
               "$APIENDPOINT/instances/$INSTANCE_ID")
  echo $API_RESPONSE
fi

empty the file
echo "" >.instance
