# prepro_configs.py
#
# created 10/24/14
# Casey Brock
#
# This python script writes all of this information to dakota_r.in by reading dakota_r.in.template and writing the updated text to dakota_r.in
#The dakota_r.in file will be used by Dakota for the postion sweeps. 
#The dakota_r.in file tells dakota how many coordinates there are for a configuration (3*num_atoms), what the descriptors are for each coordinate (arbitrary names), and what the coordinates are for each config (under list_of_points).
#
# The coordinates for the configurations are read from config_file, which contains a row for each configuration and a column for each coordinate (3*num_atom columns)
#
#
# Example:
# python prepro_configs.py /path2/file/configs.dat /path2/file/dakota_r.in.template /path2/file/dakota_r.in
# will read the configurations from configs.dat and write to dakota_r.in using dakota_r.in.template as a template
#
# $Id: prepro_configs.py,v 1.4 2015/06/01 19:05:27 brockc Exp $

import numpy as np
import os
import sys

config_file = sys.argv[1]
dakota_r_template = sys.argv[2]
dakota_r_file = sys.argv[3]

# read configurations from file
configurations = np.loadtxt(config_file,comments='#', ndmin=2)

# read template file
with open(dakota_r_template,'r') as f:
  template=f.readlines()

# insert number of coordinates into template

num_coords = configurations.shape[1]
for i in range(0,len(template)):
  line=template[i]
  if line.lstrip() != '':
    if line.lstrip().split()[0] == 'continuous_design':
      template[i] = line[:-1] + str(num_coords) + '\n'
    if line.lstrip().split()[0] == 'num_objective_functions':
      template[i] = line[:-1] + str(num_coords) + '\n'


# The Dakota input file for the configuration sweep requires a line of "descriptors" for the design varaibles.
# This writes a string of descriptors to dakota_r.in
#create descriptor string:
num_atoms = num_coords/3
descriptor_string=''
for i in range(1,num_atoms+1):
  descriptor_string += '\'r' + str(i) + '_a\' '
  descriptor_string += '\'r' + str(i) + '_b\' '
  descriptor_string += '\'r' + str(i) + '_c\' '

# add descriptor string to template:
for i in range(0,len(template)):
  line=template[i]
  if line.lstrip() != '':
    if line.lstrip().split()[0] == 'descriptors':
      template[i] = line[:-1] +  descriptor_string + '\n'

# add configuration coordinates to template
for i in range(0,len(template)):
  line = template[i]
  if line.lstrip() != '':
    if line.lstrip().split()[0] == 'list_of_points':
      for j in range(0,configurations.shape[0]):
        template.insert(i+j+1, ' '.join(map(str, configurations[j])) + '\n' )
      break

# write edited template to dakota_r.in
fout = open(dakota_r_file, 'w')
for line in template:
  fout.write(line)
fout.close()
