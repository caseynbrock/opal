# get_converged_forces.py 
# 10/17/14
# Casey Brock
#
# How to run:
# python get_converged_forces.py gcut_index
# where gcut_index is the number suffix of the gcut directory containing the converged solution
#
# reads forces.dat files from each configuration in the converged gcut directory and writes to file converged_forces.dat
# 
# each row is a configuration
# each group of three columns is an atom, with the three columns representing the x, y, and z components of force on thta atom
#
#
# $Id: get_converged_forces.py,v 1.2 2014/10/19 04:28:05 brockc Exp $
#
# $Name:  $

import sys
import numpy as np
import os

gcut_index=sys.argv[1]

# working directory names
gcut_dir_prefix='gcut_dir.'
r_dir_prefix='workdir.'

force_file_name='forces.dat'

out_file_name = 'converged_forces.dat'

# change to gcut dir with converged solution
#os.chdir(gcut_dir_prefix+gcut_index)

# creates list of all position working directories by listing all files/directories in
#   gcut_dir_old and finding the directory names containing r_dir_prefix
r_dir_list=[]
complete_dir_list = os.listdir(os.path.join(os.getcwd(), gcut_dir_prefix+gcut_index))
for dir_i in complete_dir_list:
  if r_dir_prefix in dir_i:
    r_dir_list.append(dir_i)
r_dir_list.sort() # just in case


fout = open(out_file_name, 'w')
fout.write('# forces taken from %s\n' % (gcut_dir_prefix+gcut_index))
fout.write('#          Fx_atom1   Fy_atom1   Fz_atom1   Fx_atom2  ...\n')

for i, r_dir in enumerate(r_dir_list):
  # read forces from {gcut_dir_old}/r_dir_i/{force_file_name}
  force_file = os.path.join(gcut_dir_prefix+gcut_index, r_dir,  force_file_name)
  force_array  = np.loadtxt(force_file, skiprows=1)
  
  fout.write('%s  ' % r_dir) 
  for row in force_array:
    for j in row:
      fout.write('%f  ' % j)
  fout.write('\n')

fout.close()
