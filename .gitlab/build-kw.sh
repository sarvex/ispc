#!/bin/bash
set -e

KW_PATH=/tools/kw
KW_SERVER_PATH=$KW_PATH/server
KW_CLIENT_PATH=$KW_PATH/client

export KLOCWORK_LTOKEN=/tmp/ltoken
echo "$KW_SERVER;$KW_SERVER_PORT;$KW_USER;$KW_LTOKEN" > $KLOCWORK_LTOKEN
set -x
mkdir build && cd build && cmake -DISPC_INCLUDE_TESTS=OFF -DISPC_INCLUDE_EXAMPLES=OFF -DXE_ENABLED=ON -DISPC_INCLUDE_XE_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install -D__INTEL_EMBARGO__=OFF -DXE_DEPS_DIR=/home/deps ../

$KW_SERVER_PATH/bin/kwdeploy sync --url https://$KW_SERVER:$KW_SERVER_PORT
$KW_CLIENT_PATH/bin/kwinject make -j`nproc`
$KW_SERVER_PATH/bin/kwbuildproject --url https://$KW_SERVER:$KW_SERVER_PORT/$KW_PROJECT_NAME --tables-directory $CI_PROJECT_DIR/release/kw_tables kwinject.out
