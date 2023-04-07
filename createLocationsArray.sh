#!/bin/sh

APIENDPOINT="https://api.vultr.com/v2"
INSTANCE_PLAN=vc2-1c-1gb

QUERY=".plans[] | select(.id == \"$INSTANCE_PLAN\") | .locations"

ValidLocations=`curl "$APIENDPOINT/plans" -X GET | jq -r "$QUERY"`
echo $ValidLocations