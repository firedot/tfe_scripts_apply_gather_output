#!/usr/bin/env bash


# The organization name is passed as a first argument to the script
# The workspace name is passaed as a second argument to the script


# The following block of code is going to retrieve your TFE Workspace ID
WSPACE_ID="$(curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/"$1"/workspaces/"$2" 2>/dev/null | jq '.data | .id' | tr -d \")"

# The following is added for debugging purposes. Will be removed in the final version
echo -e "Your workspace ID is: \n $WSPACE_ID \n"

# The following block of code is going to retrieve the current run ID of your TFE Workspace
CURRENT_RUN_ID="$(curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/workspaces/"$WSPACE_ID"/runs 2>/dev/null | jq '.data | .[0] | .id' | tr -d \")"


# The following is added for debugging purposes. Will be removed in the final version

echo -e "Your Current Run ID is: \n $CURRENT_RUN_ID \n"

# The following block of code is going to retrieve the configuration ID of the current run on your TFE Workspace

CONF_ID="$(curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/runs/"$CURRENT_RUN_ID"/configuration-version 2>/dev/null | jq '.data | .id' | tr -d \")"


# The following is added for debugging purposes. Will be removed in the final version
echo -e "Your Configuration ID is: \n $CONF_ID \n"


# Create a payload file

INPUT_FILE="/vagrant/templates/payload_template"
OUTPUT_FILE="/tmp/payload.json"

cat $INPUT_FILE | sed "s/WSPACE_ID/"$WSPACE_ID"/g; s/CONF_ID/"$CONF_ID"/g" > $OUTPUT_FILE

# The following block of code is for debugging purposes only, it will be removed in the final version
#cat $OUTPUT_FILE | grep "$WSPACE_ID" > /dev/null

if cat $OUTPUT_FILE | grep "$WSPACE_ID" > /dev/null; then
    echo -e "SUCCESS: Your payload file was created \n"
else
    echo -e "FAILURE: Something went wrong \n"
fi

# The following block of code is going to create a new run within your TFE Workspace

curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @/tmp/payload.json \
  https://app.terraform.io/api/v2/runs 2>/dev/null | jq '.data | .id' | tr -d \" > /tmp/new_tfe_run_id

NEW_TFE_RUN="$(cat /tmp/new_tfe_run_id)"
# The following is added for debugging purposes. Will be removed in the final version
echo -e "Your New Run ID is: \n "$NEW_TFE_RUN" \n"


