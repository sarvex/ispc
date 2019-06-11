#!/bin/bash -x
# Overwrite branch name & commit msg for benny
git config --global user.name "Mr. Gitlab Runner"
git config --global user.email "sys_ispc@intel.com"
git commit --amend -m "IGC_VER: $IGC_VER, ISPC: $CI_PIPELINE_ID | $CI_COMMIT_MESSAGE"

export PATH=/tools/benchmark_client:$PATH

# SGEMM
cd $BENCH_BIN_DIR/sgemm/
benny insert code_context 'ISPC' $CI_PROJECT_DIR --save-json ./code_context.json
benny insert run_context $BENNY_SYS_TOKEN ./code_context.json --save-json ./run_context.json
./bench-sgemm --benchmark_out=sgemm-results.json
benny insert googlebenchmark ./run_context.json Examples SGEMM ./sgemm-results.json
