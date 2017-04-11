# is_gcut_converged.py
#10/17/14
#Casey Brock
#
# Reads residuals from file and determines if converged
#
# How to run:
# python is_gcut_converged.py res_file tolerance
# where res_file is the file containing the energy residuals
# and tolerance is the convergence tolerance
#
# for solution to be converged, the residual at EACH CONFIGURATION must be less than tolerance
#
# $Id: is_gcut_converged.py,v 1.4 2014/10/19 05:11:40 brockc Exp $
#
# $Name:  $

import sys

res_file  = sys.argv[1]
tolerance = float(sys.argv[2])

# read last line from residual file
with open(res_file,'r') as f:
  lines = f.readlines()
  last_line = lines[-1]
last_line = last_line.split(' ', 1)[1]
last_line=last_line.split()

if last_line == []:
  print "error"
  exit()

#check if all residuals below tolerance
is_converged='yes'
for res in last_line:
  if float(res) > tolerance: 
    is_converged='no'
print is_converged
