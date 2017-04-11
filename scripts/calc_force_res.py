# THIS FILE IS NOT COMPLETE, BUT I MAY NEVER USE IT
#
#
#
# converge_gcut.py
# 10/16/14
# Casey Brock
#
# reads force.dat files from each workdir.* 
# calculates and outputs residuals
# This is called after each gcut is tested
#
# reads force components from socorru runs at different gcuts and determines converged gcut
#
# example:
# $ python converge_gcut.py  num_configs gcut_dir_old  gcut_dir_new
# num_configs is the number of atomic configurations
# num_atoms is the number of atoms in the unit cell
# gcut_dir_old is the directory where the previous gcut was tested 
# gcut_dir_new is the directory where the latest gcut was tested. 
#
# residuals come from comparing values calculated in gcut_dir_old with values calculated in gcut_dir_new
#
# $Id: calc_force_res.py,v 1.2 2014/10/19 04:28:04 brockc Exp $
#
# $Name:  $


import numpy as np
import sys
import os

n_conf   = int(sys.argv[1])
gcut_dir_old    = sys.argv[2]
gcut_dir_new    = sys.argv[3]

# name of all the force output files to read
force_file_name = 'forces.dat'
# prefix name of working directories for individual configurations
r_dir_prefix  = 'workdir.'

# creates list of all position working directories by listing all files/directories and 
# finding the ones containing r_dir_prefix
r_dir_list=[]
complete_dir_list = os.listdir(os.getcwd())
for dir_i in complete_dir_list:
  if r_dir_prefix in dir_i:
    r_dir_list.append(dir_i)
r_dir_list.sort() # just in case

# read arbitrary forces.dat file to determine number of atoms in unit cell (rows in file)
num_atoms = np.loadtxt(os.path.join(gcut_dir_old,r_dir_prefix+'1',force_file_name),skiprows=1).shape[0]

# initialize residual arrays
f_res           = np.zeros((num_atoms,3,len(r_dir_list))
f_res_sqrd      = np.zeros((num_atoms,3,len(r_dir_list))
f_res_norm      = np.zeros((num_atoms,3,len(r_dir_list))
f_res_norm_sqrd = np.zeros((num_atoms,3,len(r_dir_list))


# for each configuration, calculate force residuals
for i, r_dir in enumerate(r_dir_list):
  # read forces from {gcut_dir_old}/r_dir_i/{force_file_name} 
  force_file_old = os.path.join( gcut_dir_old,  r_dir,  force_file_name)
  forces_old = np.loadtxt(force_file_old, skiprows=1)
  
  # read forces from {gcut_dir_new}/r_dir_i/{force_file_name} 
  force_file_new = os.path.join( gcut_dir_new,  r_dir,  force_file_name)
  forces_new = np.loadtxt(force_file_new, skiprows=1)

  # calcuate force residuals
  f_res[:,:,i] = forces_new-forces_old

  # calculate force residuals squared
  f_res_sqrd[:,:,i] = f_res**2.

  # calculate normalized force residuals
  f_res_norm[:,:,i] = f_res/forces_old

  # calculate normalized squared force residuals 
  f_res_norm_sqrd[:,:,i] = (f_res/forces_old)**2.

  



