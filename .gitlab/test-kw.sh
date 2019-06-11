#!/bin/bash
set -e

KW_PATH=/tools/kw
KW_SERVER_PATH=$KW_PATH/server
KW_CLIENT_PATH=$KW_PATH/client

# check number of critical issues
KW_CRITICAL_OUTPUT_PATH=/tmp/critical.out
KW_BUILD_NUMBER=$(cat $CI_PROJECT_DIR/kw_build_number)
echo "Checking for critical issues in $KW_BUILD_NUMBER ..."
curl -k -f --data "action=search&project=$KW_PROJECT_NAME&query=build:'$KW_BUILD_NUMBER'%20severity:Critical,Error%20status:Analyze,Fix&user=$KW_USER&ltoken=$KW_LTOKEN" https://$KW_SERVER:$KW_SERVER_PORT/review/api -o $KW_CRITICAL_OUTPUT_PATH
ISSUES_COUNT=$(cat $KW_CRITICAL_OUTPUT_PATH | wc -l)
if [ "$ISSUES_COUNT" -gt "0" ]; then
        echo "Issues found - $ISSUES_COUNT in $KW_BUILD_NUMBER";
        cat $KW_CRITICAL_OUTPUT_PATH | jq .url
        exit 1;
else
        echo "No issues were found in $KW_BUILD_NUMBER"
fi
