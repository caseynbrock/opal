# plots histogram of walltimes from moga_test_walltimes.dat file
#
# first, generate moga_test_walltimes.dat, which is a file containing a single column of wall times in seconds. These wall times are read from the slurm*.out file in each work directory.
# The script extract_walltimes.sh can be used to generate this data

import numpy as np
import matplotlib.pyplot as plt

# read data
x = np.loadtxt('../moga_test_walltimes.dat')
num_samples = len(x)
print 'Number of samples: ', num_samples

# the histogram of the data
n, bins, patches = plt.hist(x/60., 50, normed=1, facecolor='green', alpha=0.75)

plt.xlabel('wall time (minutes)')
plt.ylabel('probablity')
plt.title('distribution of wall times, SiO2')
plt.grid(True)

# show/save figure
#plt.savefig('SiO2_walltimes.png', format='png')
plt.show(block=False)
raw_input('Press enter to close plot...')
