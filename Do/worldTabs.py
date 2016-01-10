# worldTabs.py v0.00             damiancclarke             yyyy-mm-dd:2016-01-09
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

import re
import os
import locale
locale.setlocale(locale.LC_ALL, 'en_US.utf8')

print('\n\n FORMATTING WORLD TWIN TABLES \n\n')

#==============================================================================
#== (1a) File names (comes from Twin_Regressions.do)
#==============================================================================
RIN  = "/home/damiancclarke/investigacion/Activa/Twins/Results/World/"
OUT  = "/home/damiancclarke/investigacion/Activa/Twins/paper/twinsHealth/tex/"


#==============================================================================
#== (1b) Options
#==============================================================================
foot = "$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01"


#==============================================================================
#== (2a) Write Conditional Unstandardised 
#==============================================================================
DHSi = open(RIN + 'worldEstimatesDHS.csv').readlines()
#USAi = open(RIN + ).readlines()
#SWEi = open(RIN + ).readlines()
#CHIi = open(RIN + ).readlines()
#UKSi = open(RIN + ).readlines()

tabl = open(OUT + 'twinEffectsCond.tex', 'w')

tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{Twin Effects}\n'
           '\\begin{tabular}{lcclcc}\n \\toprule'
           '\\multicolumn{3}{c}{Health Behaviours} &'
           '\\multicolumn{3}{c}{Health Conditions} \\\\ \n'
           '\\cmidrule(r){1-3} \\cmidrule(r){4-6} \n'
           'Variable & Estimate & [95\\% CI] &Variable & Estimate & [95\\% CI]'
           '\\\\ \\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States Birth Certificates}} \\\\ \n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Pooled Demographic and Health Surveys}} \\\\ \n')
for line in DHSi:
    print line
    

tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()




print "Terminated Correctly."
