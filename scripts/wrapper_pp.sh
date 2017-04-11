#!/bin/bash
#
# This wrapper is called by Dakota:
# ./wrapper_pp.sh params results
#
# writes data/Li.atompaw and based on data/Li.atompaw.template,
# writes data/F.atompaw and based on data/F.atompaw.template,
# runs job sript, which does gcut sweep, calculates objectives,
# and writes results.tmp (if it finishes)
#
# $Header: /home/brockc/cvsroot/opal/scripts/wrapper_pp.sh,v 1.32 2016/07/24 19:08:51 brockc Exp $
# $Name:  $

# gives group access to work directory
chmod g+rx .

#Waits a random amount of time between 1 second and 2 minutes so that atompaw calls are not all trying to start at the same time
#
# this also prevents the first design points in each generation from starting together. the points in each generationare sorted by increasing value of the first esign variable (usually a cutoff radius in our case). This means the first points have the smallest RC and are likely to not converge when creating the pseudopotential. When a bunch of them don't converge at the same time, dakota sometimes doesn't catch the results files before the directories compress for some reason
sleep_time=$(( (RANDOM % 120 ) + 1 ))
sleep $sleep_time

# read element list from opal.in
element_string=$( awk '$1=="ELEMENTS" { getline; print $0 }' ../opal.in )
# convert space-delimited string to list (array?)
element_list=($element_string)


# PREPROCESSING FOR ATOMPAW
# uses Dakota's dprepro utility
#dprepro $1  Si.atompaw.template  Si.atompaw
#dprepro $1  Ge.atompaw.template  Ge.atompaw
for elem in "${element_list[@]}"; do
  dprepro $1  ${elem}.atompaw.template  ${elem}.atompaw
done


# remove old gcut log so monitor works later in script
#rm -f gcut_sweep.log
#rm -f results results.tmp  #remove possible old results

# remove CVS directories that got copied from templatedir_pp
rm -rf CVS
rm -rf templatedir_gcut/CVS
rm -rf templatedir_gcut/templatedir/CVS
rm -rf templatedir_gcut/templatedir/data/CVS

# CREATE PSEUDOPOTENTIALS
#element_list=('Si' 'Ge')
for elem in "${element_list[@]}"; do
  # set up directory for pseudopotential
  mkdir ${elem}_pseudopotential
  cd    ${elem}_pseudopotential
  ln -s ../${elem}.atompaw

  # if fewer than 20 create_pp scripts (which run atompaw) already running, run create_pp.py
  # otherwise wait and retry
  # this absolutely does not work perfectly, but it should keep the number of atompaws *about* 24 or less
  # what we're really trying to avoid is 100 or 1000 atompaws running simultaneously
  while :
  do  
    num_create_pp=$(pgrep -f create_pp.py | wc -l)
    if [ $num_create_pp -lt "20" ] ; then 
      python ../../scripts/create_pp.py $elem
      break
    else
      sleep 60
    fi
  done

  # if atompaw did not create scattering* files, there was a problem. return 103s and quit this run
  # checks only for scattering.0 since all pseudopotentials should produce this file
  if [[ ! -e scattering.0 ]]; then
    cd ..
    printf "103 accu_obj\n103 work_obj\n" > results.tmp
    mv results.tmp $2
    # allow dakota time to detect existence of results file
    sleep 600
    # tar up workdir
    this_workdir=${PWD##*/}
    cd ..
    nice -n 19 ionice -c2 -n7 tar -zcf ${this_workdir}.tar.gz  ${this_workdir}
    rm -rf $this_workdir
    exit
  fi   

  # if atompaw didn't converge, return 100s and quit this run
  if [[ -e atompaw_not_converged ]]; then
    cat atompaw_not_converged
    cd ..
    printf "100 accu_obj\n100 work_obj\n" > results.tmp
    mv results.tmp $2
    # allow dakota time to detect existence of results file
    sleep 600
    # tar up workdir
    this_workdir=${PWD##*/}
    cd ..
    nice -n 19 ionice -c2 -n7 tar -zcf ${this_workdir}.tar.gz  ${this_workdir}
    #tar -zcf ${this_workdir}.tar.gz  ${this_workdir}
    rm -rf $this_workdir
    exit
  fi

  cd ..
  ln -s ${elem}_pseudopotential/PAW.${elem}

done  

# SUBMIT AND MONITOR GCUT SWEEP JOB
bash ../scripts/submit_batch_job.sh

gcut_sweep_log_file="slurm-"$(awk '{print $4}' jobid.log)".out"

# if gcut sweep didn't finish in alotted walltime, return 99s
if [[ -e "job_canceled_walltime" ]]; then
  printf "99 accu_obj\n99 work_obj\n" >results.tmp
  rm job_canceled_walltime
fi


# if the dakota position sweep caught a failure and aborted, return 102s
did_exceed=$(grep "Failure captured: aborting..." $gcut_sweep_log_file)
if [[ $did_exceed != "" ]]; then
  printf "102 accu_obj\n102 work_obj\n" >results.tmp
fi

# if results.tmp file nonexistent for some reason, return 96s
#did_results=$(ls | grep results)
#if [[ $did_results == "" ]]; then
if [[ ! -e "results.tmp" ]]; then
  printf "96 accu_obj\n96 work_obj\n" >results.tmp
fi

# move tmp file to dakota results file
mv results.tmp $2
# allow dakota time to detect existence of results file
sleep 600

# tar up workdir
this_workdir=${PWD##*/}
cd ..
# make sure the directory to be compressed and then deleted is actually a workdirectory
# trying to prevent deleting actual data
# I've been burned by this before when I hit my file number hard limit 
if [[ $this_workdir == "workdir_pp."* ]]  # if the file name contains workdir_pp.
then
  nice -n 19 ionice -c2 -n7 tar -zcf ${this_workdir}.tar.gz  ${this_workdir}
  #tar -zcf ${this_workdir}.tar.gz  ${this_workdir}
  rm -rf $this_workdir
fi
