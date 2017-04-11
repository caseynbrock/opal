#!/bin/bash
#
# batch script for submitting job with slurm scheduler
# 
# $Header: /home/brockc/cvsroot/opal/scripts/gcut_sweep.slurm,v 1.2 2015/06/18 17:31:32 brockc Exp $
# $Name:  $

# empty file so submit_batch_job.sh can tell when job starts
touch job_started

start_time=$(date +%s) # to calculate wall time later

# write some useful info about job
# some of this may not be necessary now that I'm creating the sacct log file
echo "Start date:"
date
echo "Running on"
hostname
printf "Run Directory: \n"
pwd
printf "Job ID: $SLURM_JOBID \n\n"


../scripts/gcut_sweep.sh

# empty file so submit_batch_job.sh can tell when gcut sweep ended
touch job_completed

# calculate wall time used
end_time=$(date +%s)
run_time=$((end_time-start_time))
printf "\nTOTAL GCUT SWEEP EXECUTION TIME:  %s seconds\n" $run_time 
