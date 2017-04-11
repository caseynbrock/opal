#!/bin/bash
#
# this script handles batch job submission and monitoring. It will probably need to be changed for different computers
# called by wrapper_pp.sh
# April 13 2015
#
# THE EXPLANATION BELOW IS OUTDATED (as of 06/17/15), BUT IM LEAVING IT IN CASE I RUN INTO THE SAME PROBLEM AGAIN
# To find jobid, I used to redirect output from sbatch call into file and then parse job name from that file. This created problems because sometimes the job would submit correctly but still output error messages (and no jobid). To get around this, I now read the job ID from the slurm stout/stderr file. I have to read it every time in the while loop because, while the job is waiting in the queue, the stdout/stderr file doesn't exist (I think).
#
#
#
#
# $Header: /home/brockc/cvsroot/opal/scripts/submit_batch_job.sh,v 1.8 2015/07/07 19:05:38 brockc Exp $
# $Name:  $



max_time=$( awk '$1=="WALLTIME_LIMIT" { getline; print $0 }' ../opal.in ) # max time allowed in seconds (eventually read this from opal.in)

job_started_file=job_started
job_end_file=job_completed
job_canceled_file=job_canceled_walltime
rm -f $job_started_file $job_end_file

# submit batch job to run gcut sweep
# retries if job doesn't submit correctly
sbatch_retry_interval=5
sbatch_flags=$( awk '$1=="SBATCH_FLAGS" { getline; print $0 }' ../opal.in )
### I CANT MONITOR FOR CORRECT JOB SUBMISSION BECAUSE SOMETIMES THE JOB SUBMITS BUT STILL RETURNS ERROR MESSAGES. IN THIS CASE, THE JOB COULD SUBMIT TWICE AND BE RUNNING TWICE IN THE SAME DIRECTORY, READING AND WRITING TO THE SAME FILES. THIS WOULD OBVIOUSLY CAUSE PROBLEMS
#submitting_job=true
#while $submitting_job :
#do
  sbatch $sbatch_flags ../scripts/gcut_sweep.slurm &> jobid.log 
#  
#  # if submitted correctly
#  if [[ $(grep "Submitted batch job" jobid.log) != "" ]]; then
#    echo "batch job submitted successfully"
#    submitting_job=false
#  # if job din't submit correctly, retry
#  else
#    echo "batch job didn't submit correctly...retrying in $sbatch_retry_interval seconds"
#    sleep $sbatch_retry_interval
#  fi
#done

# read jobid from jobid.log
jobid=$(cat jobid.log | awk '{print $4}')


# check for batch job start by detecting job started file
job_start_check_interval=5
while :
do
  if [[ -e "job_started" ]]; then
    # job_start_time may be off by seconds because of job_start_check_interval
    job_start_time=$(date +%s) 
    break
  else
    sleep $job_start_check_interval
  fi
done
echo "$job_started_file file detected"
rm $job_started_file

# continually check for job_ended file or timeout
# loop will break once job file detected or max_time has passed 
job_end_check_interval=10
while [[ $elapsed_time -lt $max_time && ! -e $job_end_file ]]; do
   sleep $job_end_check_interval
   current_time=$(date +%s)
   elapsed_time=$((current_time-job_start_time))
done


# now job has completed or exceeded wall time...figure out which
if [ -e $job_end_file ]
then
   #echo "$job_end_file file detected: job completed under wall time limit"
   rm $job_end_file
else
   echo "$job_end_file file not detected: job did not complete within wall time limit"
   echo "creating $job_canceled_file"
   touch $job_canceled_file
   if [[ -e "$job_canceled_file" ]]; then
     echo "job canceled file created"
   else
     echo "job canceled file not created"
   fi
   echo "cancelling job $jobid"
   # THIS CANCELLATION MAY NOT BE NECESSARY AS LONG AS THE JOB CANCELLED FILE IS CREATED
   scancel $jobid
fi


# write job info such as memory used and elapsed time
# sacct -j $jobid --format=JobID,Nodelist,Submit,Eligible,Start,Elapsed,MaxRSS,ExitCode > job_usage.log
