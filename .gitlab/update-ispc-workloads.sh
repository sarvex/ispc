#!/bin/bash -x

# stop execution if any command fails
set -e

docker pull $DOCKER_REGISTRY/gen-workloads:$DEPENDENCIES_PIPELINE_ID_OS-$CI_PIPELINE_ID
docker tag $DOCKER_REGISTRY/gen-workloads:$DEPENDENCIES_PIPELINE_ID_OS-$CI_PIPELINE_ID $DOCKER_REGISTRY/gen-workloads:latest
docker push $DOCKER_REGISTRY/gen-workloads:latest

docker pull $DOCKER_REGISTRY/gen-int-workloads:$DEPENDENCIES_PIPELINE_ID_INT-$CI_PIPELINE_ID
docker tag $DOCKER_REGISTRY/gen-int-workloads:$DEPENDENCIES_PIPELINE_ID_INT-$CI_PIPELINE_ID $DOCKER_REGISTRY/gen-int-workloads:latest
docker push $DOCKER_REGISTRY/gen-int-workloads:latest

docker pull $DOCKER_REGISTRY/gen-os-workloads:$DEPENDENCIES_PIPELINE_ID_OS_INT-$CI_PIPELINE_ID
docker tag $DOCKER_REGISTRY/gen-os-workloads:$DEPENDENCIES_PIPELINE_ID_OS_INT-$CI_PIPELINE_ID $DOCKER_REGISTRY/gen-os-workloads:latest
docker push $DOCKER_REGISTRY/gen-os-workloads:latest

ISPC_WORKLOADS_PROJECT_ID=92078

curl --fail --request PUT --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://gitlab.devtools.intel.com/api/v4/projects/$ISPC_WORKLOADS_PROJECT_ID/variables/ISPC_PIPELINE_ID" --form "value=$CI_PIPELINE_ID"
curl --fail --request PUT --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://gitlab.devtools.intel.com/api/v4/projects/$ISPC_WORKLOADS_PROJECT_ID/variables/DEPENDENCIES_PIPELINE_ID" --form "value=$DEPENDENCIES_PIPELINE_ID_INT"
