#!/bin/sh

# ##################################
# create a Wireguard Server instance
# on demand using the vultr api
# ##################################

# the first parameter is the region 
# (e.g. cdg for Paris, lax for Los Angeles, fra for Frankfurt etc.)
REGION=$1

# the .apikey file contains our secret API Key
. ./.apikey

# if an instance had previously been created
# then it has been saved into the .instance file
touch ./.instance
. ./.instance

# We use the vultr V2 api
APIENDPOINT="https://api.vultr.com/v2"

# This is the smallest available plan 
PLAN=vc2-1c-1gb

# ID 477 is debian 11
OS_ID=477

# ##################################
# destroy a previously created
# Server
# ##################################

if [ -n $INSTANCE_ID ]; then
  API_RESPONSE=$(curl -s -H "Authorization: Bearer $APIKEY" \
               -X DELETE \
               "$APIENDPOINT/instances/$INSTANCE_ID")
  echo $API_RESPONSE
fi

# ##################################
# Create a new Server
# ##################################

API_RESPONSE=$(curl -s -H "Authorization: Bearer $APIKEY" \
               -H "Content-Type: application/json" \
               -X POST \
               -d "{\"region\": \"$REGION\", \"plan\": \"$PLAN\", \"os_id\": \"$OS_ID\"}" \
               "$APIENDPOINT/instances")

# parse the JSON response and extract the instance ID
INSTANCE_ID=$(echo "$API_RESPONSE" | jq -r '.instance.id')
SSH_PASS=$(echo "$API_RESPONSE" | jq  -r '.instance.default_password')
INSTANCE_STATUS=$(echo "$API_RESPONSE" | jq -r '.instance.status')

# print the new instance ID
echo "Created new instance with ID: $INSTANCE_ID"

# ##################################
# wait for the instance to
# come online
# ##################################

while [ "$INSTANCE_STATUS" = "pending" ] ; do
  sleep 5
  API_RESPONSE=$(curl -s -H "Authorization: Bearer $APIKEY" \
               -X GET \
               "$APIENDPOINT/instances/$INSTANCE_ID")
  #echo $API_RESPONSE
  INSTANCE_STATUS=$(echo "$API_RESPONSE" | jq -r '.instance.status')
  echo "status is $INSTANCE_STATUS"  
done
INSTANCE_IP=$(echo "$API_RESPONSE" | jq -r '.instance.main_ip')

# let's save the most important information into the .instance file
(cat >.instance) <<EOF
INSTANCE_ID=$INSTANCE_ID
SSH_PASS="$SSH_PASS"
INSTANCE_IP=$INSTANCE_IP
EOF
chmod 0600 .instance
