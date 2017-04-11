# runs atompaw to create pseudopotentials
# runs gcut sweep
# finds gcut for converged solution
# calculates work/accuracy objectives and writes to results.tmp
# if atompaw can't create pseudopotentials, return high objectives to dakota
#
# $Id: gcut_sweep.sh,v 1.13 2015/07/30 20:23:03 brockc Exp $
#
# $Name:  $


# remove old workdirs if they exist
rm -rf gcut_dir.* 

# array of gcut values
# note convergence criteria is based on a gcut step of 10. I may eventually need to generalize for different gcut step sizes
#gcut_values=(10.  20.  30.  40.  50.  60.  70.  80.  90. 100.)
#fourgcut_values=(40.  80. 120. 160. 200. 240. 280. 320. 360. 400.)
gcut_values=(10.  20.  30.  40.  50.  60.  70.)
fourgcut_values=(40.  80. 120. 160. 200. 240. 280.)

is_converged='no' # initialize boolean

# FOR EACH GCUT, CALCULATE FORCES AND CHECK FOR CONVERGENCE
for i in `seq 1 ${#gcut_values[@]}`; do
  # create working directory for current gcut 
  # and insert gcut into socorro's argvf input file
  mkdir gcut_dir.${i}
  cp -r templatedir_gcut/* gcut_dir.${i}
  cd gcut_dir.${i}
  sed "s/{gcut}/${gcut_values[$i-1]}/g" templatedir/argvf.template > templatedir/argvf
  sed -i "s/{4gcut}/${fourgcut_values[$i-1]}/g" templatedir/argvf
  
  # run Dakota position sweep to calculate force at each configuration
  echo -e "Calling Dakota position sweep in"; pwd;
  dakota ../../scripts/dakota_r.in > dakota_r.log
  
  # if any configurations exited with errors, report fail
  did_fail=$(grep fail workdir*/results)
  if [[ $did_fail != "" ]]; then
    echo fail #>$2
    exit
  fi
  
  cd ..
  
  # determine if solution has converged at this gcut
  # if gcut converged, then break
  energy_res_file='energy_res.dat'
  
  # if first gcut tested
  if [ $i == 1 ]; then
    # write header to residual file
    # there are no relative residuals until 2nd gcut is tested
    echo "# squared normalized relative residuals : [ (e(j)-e(j-1)) / e(j-1) ]^2">$energy_res_file
    echo "# gcut dir,      config 1,           config 2,           ...">>$energy_res_file

  # if second or higher gcut tested
  else
    # calculate and write residuals
    python ../scripts/calc_energy_res.py gcut_dir.$((i-1)) gcut_dir.${i} $energy_res_file
    
    # check if converged
    tolerance="1.e-8"
    #tolerance="1.e-300"
    is_converged=$(python ../scripts/is_gcut_converged.py $energy_res_file  $tolerance)
    printf "\nIs solution converged? $is_converged\n\n\n"

    # if converged, set converged gcut index
    if [ $is_converged == 'yes' ]; then
      gcut_index=$i
      break
    fi
    
    # if there was a problem calculating residuals, return 101s as objectives
    if [ $is_converged == "error" ]; then
      printf "101 accu_obj\n101 work_obj\n" > results.tmp
      printf "\nThere was a problem calculating residuals! Returning 101s as objectives.\n"
      exit
    fi

  fi
done


# if didn't converge, return 95s as objectives
if [ $is_converged == 'no' ]; then
  printf "95 accu_obj\n95 work_obj\n" > results.tmp
  printf "\nSolution did not converge with gcuts tested! Returning 95s as objectives.\n"
  exit
fi

# if converged

# print converged gcut
printf "Solution converged at gcut = %s\n" \
    $(cat gcut_dir.${gcut_index}/templatedir/argvf | grep wf_cutoff | awk '{print $2}')
printf "Converged solution in gcut_dir.${gcut_index} \n"
printf "Extracting forces from gcut_dir.${gcut_index} and writing to converged_forces.dat\n"

# read converged force results from converged gcut directory 
# and write to 'converged_forces.dat'
python ../scripts/get_converged_forces.py $gcut_index

printf "Calculating accuracy objective\n"
# calculate accuracy objective and write to results.tmp
python ../scripts/calc_accuracy.py  > accuracy_obj.log
accu_obj=$(awk '/total_accuracy_objective/ {print $3}' accuracy_obj.log)
# write accuracy objective to tmp file
echo $accu_obj accu_obj > results.tmp


printf "Calculating work objective\n"
# get timing info from workdir of converged solution
cd gcut_dir.${gcut_index}
for dir in $( ls | grep "workdir.*" ); do
  cd $dir
  ../../../scripts/calc_nflops > nflops.dat
  cd ..
done
# add nflops from each position
work_obj=$(cat workdir.*/nflops.dat |grep "Approximate Flop" |awk '{printf $4; printf "+"}' |sed '$s/.$/\n/' |bc)
cd ..
# write work objective to tmp file
echo $work_obj work_obj >> results.tmp


printf "Gcut sweep complete\n"


