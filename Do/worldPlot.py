# worldPlot.py v0.00             damiancclarke             yyyy-mm-dd:2015-12-30
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Imports data exported as a csv from worldTwins.do and creates plots using matp
# lotlib.
#

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.ticker as mtick


#-------------------------------------------------------------------------------
#--- (1) Import data
#-------------------------------------------------------------------------------
loc    = '/home/damiancclarke/investigacion/Activa/Twins/Results/Sum/'
fname  = 'countryEstimatesGDP.csv'
fname  = 'countryEstimatesGDP_SD.csv'
sav    = '/home/damiancclarke/investigacion/Activa/Twins/Results/World/'
data   = np.genfromtxt(loc+fname, delimiter=',', skip_header=0,  
                      skip_footer=10, names=True)


#-------------------------------------------------------------------------------
#--- (2) Graph settings
#-------------------------------------------------------------------------------
area       = data['twinProp']*40000
labels     = ['East Asia and Pacific','Europe and Central Asia',
              'Latin America and Caribbean','Middle East and North Africa',
              'South Asia','Sub-Saharan Africa']

#-------------------------------------------------------------------------------
#--- (3) Graph function
#-------------------------------------------------------------------------------
def gdpplot(varname, axislabel, savename,limits):
    colors     = np.r_[np.linspace(0.1, 1, 6), np.linspace(0.1, 1, 6)]
    mymap      = plt.get_cmap("gist_rainbow")
    fig, axes  = plt.subplots(1,1)
    my_colors  = mymap(colors)
    for n in range(6):
        axes.scatter(data['logGDP'][data['rcode']==(n+1)],
                     data[varname][data['rcode']==(n+1)],
                     s=area,color=my_colors[n],label=labels[n],alpha=0.5,
                     marker='o',edgecolor='black', linewidth='1')
    plt.legend(scatterpoints=1,markerscale=0.35,fontsize=10,loc=2)
    axes.axhline(0, linestyle='--', color='k') 
    axes.yaxis.set_major_formatter(mtick.FormatStrFormatter('%.2f'))
    axes.xaxis.set_major_formatter(mtick.FormatStrFormatter('%.2f'))
    plt.xlabel('log(GDP) per capita')
    plt.ylabel(axislabel)
    plt.ylim(limits)
    plt.savefig(sav+savename, bbox_inches='tight')
    plt.clf()
    return


#-------------------------------------------------------------------------------
#--- (4) Plots
#-------------------------------------------------------------------------------
heightlab  = 'Height Difference in cm (twin $-$ non-twin)'
educlab    = 'Education Difference in years (twin $-$ non-twin)'
uWeightlab = 'Difference in Proportion of Underweight Mothers (twin $-$ non-twin)'


#gdpplot('heightEst'     , heightlab ,'heightGDP.png'     , [-0.5,3.5])
#gdpplot('educfEst'      , educlab   ,  'educGDP.png'     , [-0.5,2])
#gdpplot('underweightEst', uWeightlab,'underweightGDP.png', [-0.06,0.08])
gdpplot('heightEst'     , heightlab ,'heightGDPsd.png'     , [-0.1,0.6])
gdpplot('educfEst'      , educlab   ,  'educGDPsd.png'     , [-0.1,0.5])
gdpplot('underweightEst', uWeightlab,'underweightGDPsd.png', [-0.3,0.2])

