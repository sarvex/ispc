#!/bin/bash
set -e

KW_PATH=/tools/kw
KW_SERVER_PATH=$KW_PATH/server
KW_CLIENT_PATH=$KW_PATH/client

export KLOCWORK_LTOKEN=/tmp/ltoken
echo "$KW_SERVER;$KW_SERVER_PORT;$KW_USER;$KW_LTOKEN" > $KLOCWORK_LTOKEN

set +e
set -x
counter=0
build_name=0
while :
do
    build_name=build-$CI_JOB_ID-$counter
    $KW_SERVER_PATH/bin/kwadmin load --url https://$KW_SERVER:$KW_SERVER_PORT --force --name $build_name $KW_PROJECT_NAME $CI_PROJECT_DIR/release/kw_tables
    if [ $? -eq 0 ]
    then
        break
    fi
    counter=$(( $counter + 1 ))
    # retry max 10 times
    if [ $counter -ge 10 ]
    then
        echo "Too many retries - exiting with error"
        exit 1
    fi
    random_number=$(shuf -i 10-240 -n 1)
    sleep_time=$(($random_number*$counter))
    sleep $sleep_time 
done
echo "$build_name" > $CI_PROJECT_DIR/kw_build_number
