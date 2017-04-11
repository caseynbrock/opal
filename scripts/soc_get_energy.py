# reads energy from socorro's diaryf output file and writes to output  file specified on command line
#
# example:
# python soc_read_energies.py energy.dat
# will write the cell energy to file 'energy.dat'
#
#
# 10/17/14
# Casey Brock
#
# $Id: soc_get_energy.py,v 1.2 2014/10/19 04:28:05 brockc Exp $
#
# $Name:  $


import sys

output_file=sys.argv[1]

with open('diaryf', 'r') as f:
    diary = f.readlines()


fout = open(output_file,'w')
fout.write('# cell energy\n')

# finds line with final cell energy and writes to file
for line in diary:
  if 'cell energy   ' in line:
    fout.write('%s\n' % line.split()[3] )
    # I didn't break here so I'll catch it if extra cell energies are printed

fout.close()
