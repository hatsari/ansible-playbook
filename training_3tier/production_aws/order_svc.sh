#!/bin/bash
ORIG=$(cd $(dirname $0); pwd)

. "${ORIG}/common.sh"

IFS=";"

# CloudForms OrderGanza - Patrick Rutledge <prutledg@redhat.com>
#                       - Guillaume Coré <gucore@redhat.com>

# Defaults
totalRequests=${totalRequests:-10} # Total number of requests
groupCount=${groupCount:-5} # Number to order at one time
groupWait=${groupWait:-1} # Minutes between groups
apiWait=${apiWait:-1} # Seconds between API calls in a group

# Dont touch from here on

usage() {
    echo "Error: Usage $0 -c <catalog name> -i <item name> [ -u <username> -t <totalRequests> -g <groupCount> -p <groupWait> -a <apiWait> -w <uri> -d <key1=value;key2=value> -y ]"
}

while getopts yu:c:i:t:g:p:a:w:d: FLAG; do
    case $FLAG in
        y) noni=1;;
        u) username="$OPTARG";;
        c) catalogName="$OPTARG";;
        i) itemName="$OPTARG";;
        t) totalRequests="$OPTARG";;
        g) groupCount="$OPTARG";;
        p) groupWait="$OPTARG";;
        a) apiWait="$OPTARG";;
        w) uri="$OPTARG";;
        d) keypairs="$OPTARG";;
        *) usage;exit;;
    esac
done

if [ -z "$catalogName" -o -z "$itemName" ]
then
    usage
    exit 1
fi

if [ -z "$uri" ]
then
    echo -n "Enter CF URI: "
    read uri
fi

if [ -z "$username" ]
then
    echo -n "Enter CF Username: "
    read username
fi

if [ -z "$password" ]; then
    echo -n "Enter CF Password: "
    stty -echo
    read password
    stty echo
    echo
fi

get_token

catalogID=$(curl -s -H "X-Auth-Token: $tok" \
                 -H "Content-Type: application/json" \
                 -X GET "${uri}/api/service_catalogs?attributes=name,id&expand=resources"\
                | jq -r ".resources[] | select(.name == \"${catalogName}\") | .id")

if [ -z "${catalogID}" ]; then
    echo "Catalog '${catalogName}' not found" >&2
    exit 2
fi

itemID=$(curl -s -H "X-Auth-Token: $tok" \
              -H "Content-Type: application/json" \
              -X GET \
              "${uri}/api/service_templates?attributes=service_template_catalog_id,id,name&expand=resources" \
             | jq -r ".resources[] | select(.name == \"${itemName}\") | .id")

if [ -z "${itemID}" ]; then
    echo "Item '${itemName}' not found" >&2
    exit 2
fi

if [ "$noni" != 1 ]
then
    echo -n "Are you sure you wish to deploy $totalRequests instances of this catalog item? (y/N): ";read yn
    if [ "$yn" != "y" ]
    then
        echo "Exiting."
        exit
    fi
fi

KPS=""
if [ -n "$keypairs" ]
then
    for kp in $keypairs
    do
        k=`echo $kp|cut -f1 -d=`
        v=`echo $kp|cut -f2 -d=`
        KPS="${KPS}, \"${k}\" : \"${v}\""
    done
fi

PAYLOAD="{ \"action\": \"order\", \"resource\": { \"href\": \"${uri}/api/service_templates/${itemID}\"${KPS} } }"

((slp=$groupWait * 60))
t=1
g=1
while [ $t -le $totalRequests ]; do
    c=1

    get_token

    while [ $c -le $groupCount -a $t -le $totalRequests ]; do
        echo "Deploying request $t in group $g"
        curl -s -H "X-Auth-Token: $tok" \
             -H "Content-Type: application/json" \
             -X POST \
             $uri/api/service_catalogs/$catalogID/service_templates -d "$PAYLOAD" \
            | python -m json.tool
        (( c = $c + 1 ))
        (( t = $t + 1 ))
        sleep $apiWait
    done

    if [ $t -le $totalRequests ]; then
        echo "Sleeping $slp seconds..."
        (( g = $g + 1 ))
        sleep $slp
    fi
done
