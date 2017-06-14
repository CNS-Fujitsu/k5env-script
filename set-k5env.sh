#!/bin/bash
set -a
OPTIND=1

# Check if we have any k5creds files, if not set K5CREDS false so we can prompt for them
for f in ./k5creds_*.txt; do
    [ -e "$f" ] && K5CREDS=true || K5CREDS=false
    break
done

# Check if called with -n (add new credentials), if so set K5CREDS false so we can prompt for them
while getopts :n option
do
  case "${option}" in
    n) K5CREDS=false;;
    \?) echo "Invalid option -${OPTARG}";;
  esac
done

if $K5CREDS ; then
  # build array of choices using k5creds_*.txt files
  read -r -a CREDS <<< $(find . -name k5creds_\*.txt | cut -f 2- -d '_' | cut -f 1 -d '.' | sort)

  # present choices to user and wait for selection
  echo "Choose credentials to use:"
  for INDEX in "${!CREDS[@]}"
  do
      echo -e "$(($INDEX+1)) \t ${CREDS[INDEX]}"
  done
  read CHOICE
  CHOICE=$(($CHOICE-1))

  # read the chosen creds file and set auth vars
  FILE="./k5creds_${CREDS[$CHOICE]}.txt"
  while IFS= read LINE || [[ -n "$LINE" ]]
  do
    export "$LINE"
  done <"$FILE"
else
  echo "Building k5creds file: "
  echo -n "Enter a friendly name to identify these credentials: "
  read CREDFILE
  echo -n "Enter your contract id: "
  read CONTRACT
  echo CONTRACT=$CONTRACT > k5creds_${CREDFILE}.txt
  echo -n "Enter your project name: "
  read PROJECT
  echo PROJECT=$PROJECT >> k5creds_${CREDFILE}.txt
  echo -n "Enter your user name: "
  read USER
  echo USER=$USER >> k5creds_${CREDFILE}.txt
  echo -n "Enter your password: "
  read PW
  echo PW=$PW >> k5creds_${CREDFILE}.txt
  echo -n "Enter your region: "
  read REGION
  echo REGION=$REGION >> k5creds_${CREDFILE}.txt
fi

# Set auth api endpoint for required region
IDENTITYV3="https://identity.$REGION.cloud.global.fujitsu.com/v3"

# Get an unscoped token
RETURN=$(curl -k -X POST -si $IDENTITYV3/auth/tokens -H "Content-Type:application/json" -H "Accept:application/json" -d '{"auth":{"identity":{"methods":["password"],"password":{"user":{"domain":{"name":"'$CONTRACT'"}, "name":"'$USER'", "password": "'"$PW"'"}}}}}')
OS_AUTH_TOKEN=$(echo "$RETURN" | awk '/X-Subject-Token/ {print $2}')

# Set the user id from the returned auth JSON
USER_ID=$(echo "$RETURN" | grep "\"token\"" | jq -r .token.user.id )

# Extract all the projects listed in the returned auth JSON
CSV=$(curl -X GET -k -s $IDENTITYV3/users/$USER_ID/projects -H "X-Auth-Token: $OS_AUTH_TOKEN" | jq -r '[(.projects[] | {name,description,enabled,id})] | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv')

# Save the projects to a csv in the current folder
echo "$CSV" > "./${CONTRACT}_projects.csv"

# Find the project id for the project name from the creds file
PROJECT_ID=$(echo "$CSV" | grep "\"$PROJECT\"" | cut -f 4 -d ',' | tr -d '"')
if [ -z "$PROJECT_ID" ]; then
  echo "Project: $PROJECT not found!"
  # Project not found, no point continuing...
  
else
  echo "Project Name: $PROJECT"
  echo "Project ID:   $PROJECT_ID"
fi

# Get a scoped token using the project id
RETURN=$(curl -k -X POST -si $IDENTITYV3/auth/tokens -H "Content-Type:application/json" -H "Accept:application/json" -d '{"auth":{"identity":{"methods":["password"],"password":{"user":{"domain":{"name":"'$CONTRACT'"}, "name":"'$USER'", "password": "'"$PW"'"}}}, "scope": { "project": {"id":"'$PROJECT_ID'"}}}}')
OS_AUTH_TOKEN=$(echo "$RETURN" | awk '/X-Subject-Token/ {print $2}')
echo "OS_AUTH_TOKEN: $OS_AUTH_TOKEN"

# Get the api endpoints from the returned auth JSON
ENDPOINTS=$(echo "$RETURN" | grep '"token"' | jq -r '[.token.catalog[].endpoints[] | {name,url}] | (.[0] | keys_unsorted) as $keys | map([.[ $keys[] ]])[] | @csv' | sort)

# Check to see if API endpoints have been set, and if so, are they still correct?
EPREQ=false
if [ -z "$OBJECTSTORAGE" ]; then
  EPREQ=true
else
  if ! grep -q $OBJECTSTORAGE <<< "$ENDPOINTS"; then
    EPREQ=true
  fi
fi

# If api endpoints need setting, set them
if $EPREQ ; then
  echo "Setting Endpoints..."
  for ENDPOINT in $ENDPOINTS
  do
    EP_NAME=$(echo $ENDPOINT | cut -f 1 -d ',' | tr '[:lower:]' '[:upper:]' | tr -d '"'  | tr '-' '_')

    # Full endpoint URL including version and project id where applicable
    EP_URL=$(echo $ENDPOINT | cut -f 2 -d ',' | tr -d '"')

    # endpoint URL without version or project id, same as init.sh used in the K5 examples
    # EP_URL=$(echo $ENDPOINT | cut -f 2 -d ',' | cut -f 1-3 -d '/' | tr -d '"')

    export $EP_NAME=$EP_URL
    echo "$EP_NAME=$EP_URL"
  done
fi

# Set vars for python clients etc
export OS_USERNAME=$USER
export OS_PASSWORD=$PW
export OS_REGION_NAME=$REGION
export OS_USER_DOMAIN_NAME=$CONTRACT
export OS_PROJECT_NAME=$PROJECT
export OS_PROJECT_ID=$PROJECT_ID
export OS_AUTH_URL=$IDENTITYV3
export OS_VOLUME_API_VERSION=2
export OS_IDENTITY_API_VERSION=3

# Tidy up
unset K5CREDS
unset CREDS
unset EPREQ
unset ENDPOINT
unset ENDPOINTS
unset EP_NAME
unset EP_URL


