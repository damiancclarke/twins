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

def formatLine(line):
    beta = float(line.split(";")[2])
    se   = float(line.split(";")[3])
    lCI  = str(float(line.split(";")[5]))
    uCI  = str(float(line.split(";")[4]))

    t    = abs(beta/se)
    if t>2.576:
        beta = str(beta)+'$^{***}$'
    elif t>1.96:
        beta = str(beta)+'$^{**}$'
    elif t>1.645:
        beta = str(beta)+'$^{*}$'
    else:
        beta=str(beta)
    
    lineOUT = beta + '&[' + lCI + ',' + uCI + ']'
    return lineOUT

#==============================================================================
#== (2a) Write Conditional Unstandardised 
#==============================================================================
DHSi = open(RIN + 'worldEstimatesDHS.csv').readlines()
USAi = open(RIN +    'worldEstimates.csv').readlines()
#SWEi = open(RIN + ).readlines()
#CHIi = open(RIN + ).readlines()
#UKSi = open(RIN + ).readlines()

tabl = open(OUT + 'twinEffectsCond.tex', 'w')

tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{Twin Effects}\n'
           '\\begin{tabular}{llcllc}\n \\toprule'
           '\\multicolumn{3}{c}{Health Behaviours} &'
           '\\multicolumn{3}{c}{Health Conditions} \\\\ \n'
           '\\cmidrule(r){1-3} \\cmidrule(r){4-6} \n'
           'Variable & Estimate & [95\\% CI] &Variable & Estimate & [95\\% CI]'
           '\\\\ \\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States Birth Certificates}} \\\\ \n')

for i,line in enumerate(USAi):
    if i>0 and i<13:
        line = formatLine(line)
        if i==1:
            n1 = 'Mother\'s Height&'   + line + '\\\\'
        elif i==4:
            n2 = 'Smoked Trimester 1&' + line + '&'
        elif i==5:
            n3 = 'Smoked Trimester 2&' + line + '&'
        elif i==6:
            n4 = 'Smoked Trimester 3&' + line + '&'
        elif i==7:
            n5 = 'Diabetes (pre)&'     + line + '\\\\'
        elif i==8:
            n6 = 'Gestation Diabetes&' + line + '\\\\'
        elif i==9:
            n7 = 'Eclampsia&'          + line + '\\\\'
        elif i==10:
            n8 = 'Hypertension (pre)&' + line + '\\\\'
        elif i==11:
            n9 = 'Gestation Hyperten&' + line + '\\\\'
tabl.write(n2+n1+'\n' + n3+n5+'\n' + n4+n8+'\n' + '&&&'+n6+'\n' 
           + '&&&'+n7+'\n' + '&&&'+n9+'\n')


tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Pooled Demographic and Health Surveys}} \\\\ \n')
for i,line in enumerate(DHSi):
    if i>0 and i<7:
        line = formatLine(line)

        if i==1: 
            n1 = 'Mother\'s Height&'   + line + '&'
        elif i==2: 
            n2 = 'Mother\'s BMI&'      + line + '&'
        elif i==4: 
            n3 = 'Doctor Availability&'+ line + '\\\\'
        elif i==5: 
            n4 = 'Nurse Availability&' + line + '\\\\'
        elif i==6: 
            n5 = 'No Prenatal Care&'   + line + '\\\\'

tabl.write(n1+n3 + '\n' + n2+n4+ '\n' + '&&&'+n5+'\n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: Swedish Medical Birth Registry}} \\\\ \n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chilean Survey of Early Infancy}} \\\\ \n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Somerset Birth Survey (United Kingdom)}} \\\\ \n')





tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()




print "Terminated Correctly."
