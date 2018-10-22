#!/bin/bash
#set -o xtrace

################################################################
# Install dependencies
################################################################
echo 'Installing dependencies...'
sudo apt-get -qq update 1>/dev/null
sudo apt-get -qq install jq 1>/dev/null
sudo apt-get -qq install figlet 1>/dev/null


figlet 'wskdeploy'

wskdeployVersion="0.9.7"
tarfile="openwhisk_wskdeploy-$wskdeployVersion-linux-amd64.tgz"
wskdeployArchive="wskdeploy-$wskdeployVersion-linux-amd64.tgz"
wskdeployURL="https://github.com/apache/incubator-openwhisk-wskdeploy/releases/download/$wskdeployVersion/$tarfile"

mkdir -p wskdeploy-install
if curl -L $wskdeployURL -o wskdeploy-install/${tarfile}
then
    echo "Download complete. Preparing..."
else
    echo "Download failed. Quit installation."
    exit 1
fi

tar -xf wskdeploy-install/${tarfile} --directory wskdeploy-install
chmod +x wskdeploy-install/wskdeploy





################################################################
# Fetch auth credentials
################################################################

figlet 'IBM Cloud'

echo 'Retrieving Cloud Functions authorization key...'

# Retrieve the Functions authorization key
CF_ACCESS_TOKEN=`echo $CF_CONFIG_JSON | jq -r .AccessToken | awk '{print $2}'`

# Docker image should be set by the pipeline, use a default if not set
if [ -z "$FUNCTIONS_API_HOST" ]; then
  echo 'FUNCTIONS_API_HOST was not set in the pipeline. Using default value.'
  export FUNCTIONS_API_HOST=openwhisk.ng.bluemix.net
fi
FUNCTIONS_KEYS=`curl -XPOST -k -d "{ \"accessToken\" : \"$CF_ACCESS_TOKEN\", \"refreshToken\" : \"$CF_ACCESS_TOKEN\" }" \
  -H 'Content-Type:application/json' https://$FUNCTIONS_API_HOST/bluemix/v2/authenticate`


SPACE_KEY=`echo $FUNCTIONS_KEYS | jq -r '.namespaces[] | select(.name == "'$CF_ORG'_'$CF_SPACE'") | .key'`
SPACE_UUID=`echo $FUNCTIONS_KEYS | jq -r '.namespaces[] | select(.name == "'$CF_ORG'_'$CF_SPACE'") | .uuid'`
FUNCTIONS_AUTH=$SPACE_UUID:$SPACE_KEY

BEARER_PREFIX="bearer "
APIGW_ACCESS_TOKEN=${CF_ACCESS_TOKEN%.$BEARER_PREFIX}

echo "writing .wskprops..."

printf "APIVERSION=v1 \n\
APIHOST=$FUNCTIONS_API_HOST \n\
AUTH=$FUNCTIONS_AUTH \n\
NAMESPACE=_ \n\
APIGW_ACCESS_TOKEN=$APIGW_ACCESS_TOKEN" > $HOME/.wskprops





################################################################
# Deploy 
################################################################

figlet 'Deploy'

echo "Running wskdeploy..."
wskdeploy-install/wskdeploy -m "manifest.yml" --param "services.cloudant.url" "$DATABASE_URL" --param "services.cloudant.database" "$DATABASE"



