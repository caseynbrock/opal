#!/bin/bash
#
# This wrapper reads perturbation input from Dakota, 
# writes data/crystal based on data/crystal.template,
# runs socorro,
# read forces from socorro,
# writes force output to Dakota results file 
#
# $Header: /home/brockc/cvsroot/opal/scripts/wrapper_r.sh,v 1.12 2016/03/29 20:52:09 brockc Exp $
# $Name:  $

# gives group access to this this work directory
chmod g+rx .

# read Dakota params file and input parameters into crystal file for socorro
# uses dprepro utility
dprepro $1 data/crystal.template data/crystal
rm data/crystal.template

#link pseudopotentials
cd data; 
ln -s ../../../PAW.* .
cd ..


# run socorro
echo -e "Running Socorro \n\n"
# read command to run socorro from opal.in
srun_flags=$(awk '$1=="SRUN_FLAGS" { getline; print $0 }' ../../../opal.in)
# call srun until it works
while :
do
  # srun --exclusive --mem=5000M -n 1 socorro &> socorro.log
  srun $srun_flags socorro &> socorro.log
  # if output doesn't contain errors, break
  srun_errors=$(grep "srun: error:" socorro.log)
  if [[ $srun_errors != "" ]]; then
    echo "srun returned errors, retrying..."
  else
    break
  fi
done
 


# If socorro didn't ouptut forces or energy, it didn't complete successfully
did_force=$(grep "Atomic force" diaryf)
if [[ $did_force == "" ]]; then
  echo fail >$2
  exit
fi

# write force components on each atom to forces.dat by reading diaryf
python ../../../scripts/soc_get_forces.py forces.dat
# write cell energy to energy.dat by reading diaryf
python ../../../scripts/soc_get_energy.py energy.dat

# If socorro output asterisks for energy,the forces were unrealistically large
# thus bad design point
did_asterisk=$(grep "\*\*\*\*\*" forces.dat)
if [[ $did_asterisk != "" ]]; then
  echo fail >$2
  exit
fi

# read forces from forces.dat and write to results file
# the results file signals to DAKOTA that this evaluation has completed,
# but otherwise is not used by the moga scripts
tail -n+2 forces.dat | awk '{print $1; print $2; print $3}' > results.tmp

# # move tmp file to dakota results file
mv results.tmp $2

# write dummy results file
# echo 0 dummy_results > results
