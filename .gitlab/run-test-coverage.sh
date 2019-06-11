#!/bin/bash


mkdir ./examples_cpu
find ./examples/ -name "*.ispc" | grep -v "xpu" | xargs -I{} cp -u {} ./examples_cpu/
mkdir ./examples_gpu
find ./examples/ -name "*.ispc" | grep "xpu" | xargs -I{} cp -u {} ./examples_gpu/


declare -A opts
opts[0]='-O0'
opts[1]='-O2'
opts[2]='-O2 -g'

targets=( gen9-x8 gen9-x16 sse4-i32x4 avx2-i32x8 avx512skx-i32x16 )
for opt_key in "${!opts[@]}"
do
    opt_value=${opts[$opt_key]}
    for target in "${targets[@]}"
    do
        # Compile and gather cov file for each file
	# tests
        for filename in $CI_PROJECT_DIR/tests/*.ispc; do
           export COVFILE=$filename.$target.$opt_key.cov
           cp $CI_PROJECT_DIR/build/test.cov $COVFILE

           echo "Compiling file $filename..."
           ispc $opt_value --target=$target $filename -o $filename.o -h $filename.h &>/dev/null &
        done
        wait

	# tests_errors
        for filename in $CI_PROJECT_DIR/tests_errors/*.ispc; do
           export COVFILE=$filename.$target.$opt_key.error.cov
           cp $CI_PROJECT_DIR/build/test.cov $COVFILE

           echo "Compiling file $filename..."
           ispc $opt_value --target=$target $filename -o $filename.o -h $filename.h &>/dev/null &
        done
        wait

	# examples
        if [[ $target == *genx* ]]
        then
            for filename in $CI_PROJECT_DIR/examples_gpu/*.ispc; do
               export COVFILE=$filename.$target.$opt_key.examples_gpu.cov
               cp $CI_PROJECT_DIR/build/test.cov $COVFILE

               echo "Compiling file $filename..."
               ispc $opt_value --target=$target $filename -o $filename.o -h $filename.h &>/dev/null &
            done
            wait
        else
            for filename in $CI_PROJECT_DIR/examples_cpu/*.ispc; do
               export COVFILE=$filename.$target.$opt_key.examples_cpu.cov
               cp $CI_PROJECT_DIR/build/test.cov $COVFILE

               echo "Compiling file $filename..."
               ispc $opt_value --target=$target $filename -o $filename.o -h $filename.h &>/dev/null &
            done
            wait
        fi
    done
done


# ISPCRT tests
mkdir -p ispcrt/ut
cp -r $CI_PROJECT_DIR/build/bin/* ispcrt/ut/
export COVFILE=$CI_PROJECT_DIR/ispcrt/ut/ispcrt-ut.cov
cp $CI_PROJECT_DIR/build/ispcrt/test.cov $COVFILE
export ZE_ENABLE_NULL_DRIVER=1
export ISPCRT_MOCK_DEVICE=y
ispcrt/ut/ispcrt_mock_tests

# Merge cov files
mkdir $CI_PROJECT_DIR/cov
mkdir $CI_PROJECT_DIR/cov/ispcrt

cp $CI_PROJECT_DIR/tests*/*.cov $CI_PROJECT_DIR/cov
cp $CI_PROJECT_DIR/examples_*/*.cov $CI_PROJECT_DIR/cov
cp $CI_PROJECT_DIR/ispcrt/ut/*.cov $CI_PROJECT_DIR/cov/ispcrt

merge_cmd="covmerge -c -ftotal.cov"
for filename in $CI_PROJECT_DIR/cov/*.cov; do
   echo "Adding file $filename..."
   merge_cmd+=" "
   merge_cmd+=${filename##*/}
done

cd $CI_PROJECT_DIR/cov/
$merge_cmd

# Generate reports
covhtml -f$CI_PROJECT_DIR/cov/total.cov $CI_PROJECT_DIR/cov-report
covhtml -f$CI_PROJECT_DIR/cov/ispcrt/ispcrt-ut.cov $CI_PROJECT_DIR/cov-report-ispcrt

covbr -f $CI_PROJECT_DIR/cov/total.cov > $CI_PROJECT_DIR/cov/covbr.log
covbr -f $CI_PROJECT_DIR/gitlab/total.baseline.cov > $CI_PROJECT_DIR/cov/covbr.baseline.log

echo "*****************************************************"
echo -e "--------------- Diff to baseline --------------------"
diff $CI_PROJECT_DIR/cov/covbr.baseline.log $CI_PROJECT_DIR/cov/covbr.log
echo "*****************************************************"
echo "https://www.bullseye.com/help/ref-covbr.html to see meanings of these X T t k symbols"
echo "*****************************************************"

# Display short report
covsrc -f$CI_PROJECT_DIR/cov/total.cov


