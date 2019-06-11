#!/bin/bash -e

output_dir_name=$1

rm -rf $output_dir_name && mkdir $output_dir_name
output_dir=`realpath $output_dir_name`

rm -rf tmp && mkdir tmp
tmp_dir=`realpath tmp`

# get all failed jobs in test stage
job_ids_line=`curl --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://$CI_SERVER_HOST/api/v4/projects/$CI_PROJECT_ID/pipelines/$CI_PIPELINE_ID/jobs?scope[]=failed&scope[]=success&&per_page=100" | jq ".[] | select(.stage | contains(\"test\")) | select(.artifacts_file) | .id"`
job_ids=($job_ids_line)

for job_id in "${job_ids[@]}"
do
    echo "Downloading artifacts from test job id: $job_id"
    curl --fail --location --output $tmp_dir/$job_id.zip --header "PRIVATE-TOKEN: $AUTOMATE_TOKEN" "https://$CI_SERVER_HOST/api/v4/projects/$CI_PROJECT_ID/jobs/$job_id/artifacts"

    # extract archive and move diff files
    cd $tmp_dir
    unzip -q $job_id.zip
    mv $tmp_dir/fail_db.diff $output_dir/fail_db_$job_id.diff || echo "Job id: $job_id doesn't have fail_db.diff in artifacts"
    rm -rf $tmp_dir/*
    cd -
done
rm -rf $tmp_dir
