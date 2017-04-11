#!/bin/bash

#echo 'need to update for general number of directories. exiting now'
#exit

if [ -z $1 ]; then 
  echo "no output file specified...exiting"; 
  exit
fi

# f=all_accuracy_objectives.dat
f=$1 
rm -f $f


echo '# force_obj    atan_obj    total_obj' >  $f

for i in `seq 1 7500`; do
  if [[ -e workdir_pp.${i}/accuracy_obj.log ]]; then
    echo -n "${i}  "  >> $f
    cat workdir_pp.${i}/accuracy_obj.log | grep force_obj | awk '{print $3}' | tr '\n' '  ' >> $f
    cat workdir_pp.${i}/accuracy_obj.log | grep atan_obj  | awk '{print $3}' | tr '\n' '  ' >> $f
    cat workdir_pp.${i}/accuracy_obj.log | grep total     | awk '{print $3}'               >> $f
  fi
done
