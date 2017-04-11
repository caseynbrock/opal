# atan weight = min(force_obj)/min(atan_obj)
# input name of all_accuraon command lone
#
# input file name should be specified on command line and should contain the force, atan, and total accuracy objectives. This file is usually created with scripts/extract_all_accu.sh

import sys
import numpy as np

# read data from all_accuracy_objectives.dat
if len(sys.argv) > 1:
    input_file = sys.argv[1]
else:
    print 'no input file specified...exiting'
    exit()
all_accu = np.loadtxt(input_file, comments='#')
force_obj = all_accu[:,1]
atan_obj = all_accu[:,2]
total_obj = all_accu[:,3]

# find min force objective
min_force_obj = min(force_obj)
print "minimum_atan_objective", min_force_obj

# find min atan objective
min_atan_obj = min(atan_obj)
print "minimum atan objective", min_atan_obj

atan_weight = min_force_obj/min_atan_obj
print "atan weight", atan_weight
