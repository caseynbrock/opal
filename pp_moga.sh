#!/bin/bash
# main script to run moga
# 07/18/14
# Casey Brock
#
# $Id: pp_moga.sh,v 1.7 2016/04/19 17:42:23 brockc Exp $
#
# $Name:  $

# remove possible leftovers from previous run
rm -f JEGAGlobal.log
rm -rf workdir_pp*   #remove workdirs from possible previous run 
rm -f  dakota_tabular.dat 

# makes sure reference solution exists before starting
if [ ! -e "elk_force.dat" ]; then
    echo "elk_force.dat does not exist...aborting"
    exit
fi 

# write info about socorro, <elk>, atompaw, and dakota
bash scripts/get_exe_info.sh > exe.info

# put configurations and other info from configurations.in into dakota_r.in
python scripts/prepro_configs.py configurations.in scripts/dakota_r.in.template scripts/dakota_r.in

# run dakota
dakota scripts/dakota_pp.in

