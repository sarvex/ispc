#!/bin/bash -x
set -e
ARTIFACTORY_BASE_URL=$ARTIFACTORY_ISPC_URL/ispc
ISPC_BUILD_JOB_NAME=$1
PACKAGE_NAME=$2
ISPC_PROJECT_ID=$CI_PROJECT_ID
ISPC_PIPELINE_ID=$CI_PIPELINE_ID

job_id=`curl -g --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://gitlab.devtools.intel.com/api/v4/projects/$ISPC_PROJECT_ID/pipelines/$ISPC_PIPELINE_ID/jobs?scope[]=success&per_page=100" | jq ".[] | select(.name==\"${ISPC_BUILD_JOB_NAME}\") | .id"`
curl --location --output /tmp/$PACKAGE_NAME.zip --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://gitlab.devtools.intel.com/api/v4/projects/$ISPC_PROJECT_ID/jobs/$job_id/artifacts"
curl --fail-early -H "X-JFrog-Art-Api:$ARTIFACTORY_ISPC_API_KEY" -X PUT "$ARTIFACTORY_BASE_URL/$ISPC_PIPELINE_ID/$PACKAGE_NAME.zip" -T /tmp/$PACKAGE_NAME.zip
