# reads forces from socorro for all atoms
# reads from file diaryf and writes to file specified on command line
#
# example
# python soc_read_forces.py force.dat
# will write the three force components on each atom to the file 'force.dat'
#
# 10/13/14
# Casey Brock
#
# $Id: soc_get_forces.py,v 1.2 2014/10/19 04:28:05 brockc Exp $
#
# $Name:  $


import sys

output_file=sys.argv[1]

with open('diaryf', 'r') as f:
    diary = f.readlines()

# finds first_force_line, which is the first line where atomic forces are printed
for indx, line in enumerate(diary):
  if line == '   Atomic forces:\n':
    first_force_line=indx+3


fout = open(output_file,'w')
fout.write('# F_x        F_y        F_z\n')
force_line=first_force_line
while True:
  Fx=diary[force_line].split()[1]
  Fy=diary[force_line].split()[2]
  Fz=diary[force_line].split()[3]
  fout.write('%s  %s  %s\n' % (Fx, Fy, Fz))  
  
  force_line=force_line+1
  if diary[force_line] == '\n':
    break

fout.close()
