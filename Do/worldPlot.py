# worldPlot.py v0.00             damiancclarke             yyyy-mm-dd:2015-12-30
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Imports data exported as a csv from worldTwins.do and creates plots using matp
# lotlib.
#

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

#-------------------------------------------------------------------------------
#--- (1) Import data
#-------------------------------------------------------------------------------
loc    = '/home/damiancclarke/investigacion/Activa/Twins/Results/Sum/'
fname  = 'countryEstimatesGDP.csv'
data   = np.genfromtxt(loc+fname, delimiter=',', skip_header=0,  
                      skip_footer=10, names=True)
%data['rcode'] = data['rcode']/6

#-------------------------------------------------------------------------------
#--- (2) Graph settings
#-------------------------------------------------------------------------------
colors     = np.r_[np.linspace(0.1, 1, 6), np.linspace(0.1, 1, 6)]
mymap      = plt.get_cmap("Reds")
fig, axes  = plt.subplots(1,1)
my_colors  = mymap(colors)
area       = data['twinProp']
area       = area*20000

#-------------------------------------------------------------------------------
#--- (3) Graph              
#-------------------------------------------------------------------------------
for n in range(6):
    axes.scatter(data['logGDP'][data['rcode']==(n+1)],
                 data['heightEst'][data['rcode']==(n+1)],
                 s=area,color=my_colors[n],label="point %d" %(n))
plt.legend(scatterpoints=1)
plt.show()
