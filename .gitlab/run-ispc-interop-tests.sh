#!/bin/bash -e
git clone https://$ISPC_INTEROP_TOKEN@github.com/intel-sandbox/aneshlya.ispc-dpcpp-interop.git
cd aneshlya.ispc-dpcpp-interop
./run_tests.sh

