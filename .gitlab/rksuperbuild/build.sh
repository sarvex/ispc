#!/bin/bash -e

git clone https://github.com/RenderKit/superbuild
cd superbuild

mkdir build
cd build
cmake -DISPC_URL=$CI_PROJECT_DIR/build/ispc-trunk-linux.tar.gz -DISPC_VERSION=1.17.0dev ..
cmake --build .
