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

def formatLine(line, vers):
    if vers==1:
        beta = float(line.split(";")[2])
        se   = float(line.split(";")[3])
        lCI  = format(float(line.split(";")[5]),'.3f')
        uCI  = format(float(line.split(";")[4]),'.3f')
    elif vers==2:
        beta = float(line.split(";")[6])
        se   = float(line.split(";")[7])
        lCI  = format(float(line.split(";")[9]),'.3f')
        uCI  = format(float(line.split(";")[8]),'.3f')

    t    = abs(beta/se)
    if t>2.576:
        beta = format(beta,'.3f')+'$^{***}$'
    elif t>1.96:
        beta = format(beta,'.3f')+'$^{**}$'
    elif t>1.645:
        beta = format(beta,'.3f')+'$^{*}$'
    else:
        beta = format(beta,'.3f')
    
    lineOUT = beta + '&[' + lCI + ',' + uCI + ']'
    return lineOUT

#==============================================================================
#== (2a) Write Conditional Standardised 
#==============================================================================
DHSi = open(RIN +    'worldEstimatesDHS.csv').readlines()[1:-1]
USAi = open(RIN +       'worldEstimates.csv').readlines()[1:-1]
SWEi = open(RIN + 'worldEstimatesSweden.csv').readlines()[1:-1]
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
    line = formatLine(line,1)
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
    line = formatLine(line,1)
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
for i,line in enumerate(SWEi):
    line = formatLine(line,1)
    if i==1: 
        n1 = 'Asthma&'             + line + '\\\\'
    if i==2: 
        n2 = 'Diabetes (pre)&'     + line + '\\\\'
    if i==3: 
        n3 = 'Hypertension (pre)&' + line + '\\\\'
    if i==4: 
        n4 = 'Smoked Trimester 1&' + line + '&'
    if i==5: 
        n5 = 'Smoked Trimester 3&' + line + '&'
    if i==6: 
        n6 = 'Mother\'s Height&'   + line + '&'
    if i==7: 
        n7 = 'Mother\'s Weight&'   + line + '&'

tabl.write(n4+n2+'\n' + n5+n3+'\n' + n6+n1+'\n' + n7+'&&\\\\')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chilean Survey of Early Infancy}} \\\\ \n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Somerset Birth Survey (United Kingdom)}} \\\\ \n')





tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()


#==============================================================================
#== (2a) Write Unconditional unstandardised 
#==============================================================================
#CHIi = open(RIN + ).readlines()
#UKSi = open(RIN + ).readlines()

tabl = open(OUT + 'twinEffectsUncond.tex', 'w')

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
    line = formatLine(line,2)
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
    line = formatLine(line,2)
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
for i,line in enumerate(SWEi):
    line = formatLine(line,2)
    if i==1: 
        n1 = 'Asthma&'             + line + '\\\\'
    if i==2: 
        n2 = 'Diabetes (pre)&'     + line + '\\\\'
    if i==3: 
        n3 = 'Hypertension (pre)&' + line + '\\\\'
    if i==4: 
        n4 = 'Smoked Trimester 1&' + line + '&'
    if i==5: 
        n5 = 'Smoked Trimester 3&' + line + '&'
    if i==6: 
        n6 = 'Mother\'s Height&'   + line + '&'
    if i==7: 
        n7 = 'Mother\'s Weight&'   + line + '&'

tabl.write(n4+n2+'\n' + n5+n3+'\n' + n6+n1+'\n' + n7+'&&\\\\')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chilean Survey of Early Infancy}} \\\\ \n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Somerset Birth Survey (United Kingdom)}} \\\\ \n')

tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()




print "Terminated Correctly."