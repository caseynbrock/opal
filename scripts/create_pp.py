# create_pp.py
#
# script to create pseudopotentials
#
# accepts element name as input and creates pseudopoential using ${element}.atompaw input script that should exist in directory
# Example:
# python create_pp.py Li
# will create the pseudopotential PAW.Li using Li.atompaw as an input file.
# If atompaw doesn't converge, the file atompaw_not_converged is created. This file can be used by another script to check for nonconvergence.
#
# created 10/24/14
# Casey Brock
#
# $Id: create_pp.py,v 1.10 2016/05/31 04:04:43 brockc Exp $

import os
import sys
import glob
import errno

# DECIDED NOT TO ERASE EXTRA FILES IN CASE I WANT TO POST-PROCESS
# from stack overflow, function to remove a file that may or may not exist
#def silentremove(filename):
#    try:
#        os.remove(filename)
#    except OSError as e: # this would be "except OSError, e:" before Python 2.6
#        if e.errno != errno.ENOENT: # errno.ENOENT = no such file or directory
#            raise # re-raise exception if a different error occured


element = sys.argv[1]


atompaw_input_file = element + '.atompaw'
atompaw_log_file = element + '_atompaw.log'
# run atompaw
os.system('nice -n 19 ionice -c2 -n7 atompaw3 < ' + atompaw_input_file + ' > ' + atompaw_log_file)

### SEE COMMENT ABOVE
# # remove unnecessary atompaw output, which may or may not exist
# silentremove('density')
# silentremove('dummy')
# for file in glob.glob('logderiv.*'):
#   silentremove(file)
# silentremove('NC')
# silentremove('OCCWFN')
# for file in glob.glob('PAWwfn*'):
#   silentremove(file)
# silentremove('potAE0')
# silentremove('potential')
# silentremove('potSC1')
# silentremove('rvf')
# silentremove('rVx')
# for file in glob.glob('tprod.*'):
#   silentremove(file)
# silentremove('vloc')
# for file in glob.glob('wfn*'):
#   silentremove(file)
# silentremove(element)

### FOR ATOMPAW VERSION 4
# # write 100s to results.tmp and exit if pseudopotential not created correctly:
# if 'Error in EvaluateTP -- no convergence' in open(atompaw_log_file).read():
#   # write results.tmp
#   with open('atompaw_not_converged','w') as fout:
#     fout.write('no convergence for ' + element + ' \n')
#   exit()

### FOR ATOMPAW VERSION 3
# write 100s to results.tmp and exit if pseudopotential not created correctly:
if '-- no convergence' in open(atompaw_log_file).read():
  # write results.tmp
  with open('atompaw_not_converged','w') as fout:
    fout.write('no convergence for ' + element + ' \n')
  exit()

# if pseudopotential created and converged,  
# rename pseudopotential file
### FOR ATOMPAW 4
#pseudopotential_file = element+'.SOCORRO.atomicdata'
### FOR ATOMPAW 3
pseudopotential_file = element+'.atomicdata'
os.rename(pseudopotential_file, 'PAW.'+element)

