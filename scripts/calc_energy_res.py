# calc_energy_res.py
# 10/17/14
# Casey Brock
#
# reads energy.dat files from each position working directory
# calculates and outputs residuals
# This is called after each gcut is tested
#
# example:
# $ python calc_energy_res.py  gcut_dir_old  gcut_dir_new  out_file
# gcut_dir_old is the directory where the previous gcut was tested 
# gcut_dir_new is the directory where the latest gcut was tested
# out_file is file to write residuals to 
#
# residuals calculated using energies in gcut_dir_old and energies in gcut_dir_new
#
# $Id: calc_energy_res.py,v 1.2 2014/10/19 04:28:04 brockc Exp $
#
# $Name:  $

import numpy as np
import sys
import os

gcut_dir_old    = sys.argv[1]
gcut_dir_new    = sys.argv[2]
out_file        = sys.argv[3]

# name of all the force output files to read
energy_file_name = 'energy.dat'
# prefix name of working directories for individual configurations
r_dir_prefix  = 'workdir.'

# creates list of all position working directories by listing all files/directories in 
#   gcut_dir_old and finding the directory names containing r_dir_prefix
r_dir_list=[]
complete_dir_list = os.listdir( os.path.join(os.getcwd(), gcut_dir_old) )
for dir_i in complete_dir_list:
  if r_dir_prefix in dir_i:
    r_dir_list.append(dir_i)
r_dir_list.sort() # just in case


# initialize residual arrays
e_res           = np.zeros(len(r_dir_list))
e_res_sqrd      = np.zeros(len(r_dir_list))
e_res_norm      = np.zeros(len(r_dir_list))
e_res_norm_sqrd = np.zeros(len(r_dir_list))

# for each configuration, calculate force residuals
for i, r_dir in enumerate(r_dir_list):
  # read forces from {gcut_dir_old}/r_dir_i/{force_file_name}
  energy_file_old = os.path.join( gcut_dir_old,  r_dir,  energy_file_name)
  energy_old = np.loadtxt(energy_file_old, skiprows=1)
  
  # read forces from {gcut_dir_new}/r_dir_i/{force_file_name} 
  energy_file_new = os.path.join( gcut_dir_new,  r_dir,  energy_file_name)
  energy_new = np.loadtxt(energy_file_new, skiprows=1)

  # calcuate force residuals
  e_res[i] = energy_new-energy_old

  # calculate normalized squared force residuals 
  e_res_norm_sqrd[i] = (e_res[i]/energy_old)**2.


# append e_res_norm_sqrd fo this gcut to e_res_norm_sqrd.dat
fout2 = open(out_file, 'a')
fout2.write('%s       ' % gcut_dir_new)
for e in e_res_norm_sqrd:
  fout2.write('%s   ' % e)
fout2.write('\n')
fout2.close()



