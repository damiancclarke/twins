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


noteT1 = ('\\textbf{Effect of Maternal Health on Twinning} This table displa' + 
'ys results from Ordinary Least Square regressions of a child\'s birth type ' +
'(twin or singleton) on the mother\'s health behaviours and conditions. The ' +
'outcome variable is a binary variable for twin (=1) or singleton (=0) multi' +
'plied by 100, so all coefficients are expressed in terms of the percent inc' +
'rease in twinning.  All variables are standardised so coefficients can be i' +
'terpreted as the percent change in twin births associated with a 1 standard' +
' deviation (1 $\\sigma$) increase in the variable of interest. All models i' +
'nclude fixed effects for age and birth order, and where possible, for gesta' +
'tion of the birth in weeks (panels A and C). Stars next to the coefficients' +
'nts indicate significance levels, with: *p$<$0.1  **p$<$0.05  ***p$<$0.01. ' +
'95\% confidence intervals are displayed in parentheses. Further details reg' +
'arding estimation samples and variable construction can be found in Supplem' +
'entary Information')

noteS1 = ('Effect of Maternal Health on Twinning (Unconditional Results) Thi' +
's table displa ys results from Ordinary Least Square regressions of a child' +
'\'s birth type (twin or singleton) on the mother\'s health behaviours and c' +
'onditions. Each cell represents a seperate regression, where only the varia' +
'ble of interest and fixed effects for control variables are included. The o' +
'utcome variable is a binary variable for twin (=1) or singleton (=0) multip' +
'lied by 100, so all coefficients are expressed in terms of the percent incr' + 
'rease in twinning.  Height is measured in centimetres, BMI is measured in  ' +
'$\\frac{kilograms}{metres^2}$, availability measures in panel B refer to the' +
'proportion of births in the women\'s survey cluster which were attended/una' +
'ttended, and all remaining variables are binary.  In each case the interpre' +
'tion of the coefficient is the effect that a 1 unit increase of the variabl' +
'e will have on the probability that a woman gives birth to twins. All model' +
's include fixed effects for age and birth order, and where possible, for ge' +
'station of the birth in weeks (panels A and C). Stars next to the coefficie' +
'ntsnts indicate significance levels, with: *p$<$0.1  **p$<$0.05  ***p$<$0.0' +
'1. 95\% confidence intervals are displayed in parentheses. Further details ' +
'regarding estimation samples and variable construction can be found in the ' +
'Supplementary Information provided above.')

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
CHIi = open(RIN +  'worldEstimatesChile.csv').readlines()[1:-1]
#UKSi = open(RIN + ).readlines()[1:-1]

tabl = open(OUT + 'twinEffectsCond.tex', 'w')

tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{' + noteT1 + '}\n'
           '\scalebox{0.92}{'
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
    print line
    line = formatLine(line,1)
    if i==0: 
        n1 = 'Mother\'s Height&'   + line + '&'
    elif i==1: 
        n2 = 'Mother\'s BMI&'      + line + '&'
    elif i==3: 
        n3 = 'Doctor Availability&'+ line + '\\\\'
    elif i==4: 
        n4 = 'Nurse Availability&' + line + '\\\\'
    elif i==5: 
        n5 = 'No Prenatal Care&'   + line + '\\\\'

tabl.write(n1+n3 + '\n' + n2+n4+ '\n' + '&&&'+n5+'\n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: Swedish Medical Birth Registry}} \\\\ \n')
for i,line in enumerate(SWEi):
    line = formatLine(line,1)
    if i==0: 
        n1 = 'Asthma&'              + line + '\\\\'
    if i==1: 
        n2 = 'Diabetes (pre)&'      + line + '\\\\'
    if i==2: 
        ne = 'Kidney Disease (pre)&'+ line + '\\\\'
    if i==3: 
        n3 = 'Hypertension (pre)&'  + line + '\\\\'
    if i==4: 
        n4 = 'Smoked Trimester 1&'  + line + '&'
    if i==5: 
        n5 = 'Smoked Trimester 3&'  + line + '&'
    if i==6: 
        n6 = 'Mother\'s Height&'    + line + '&'
    if i==7: 
        n7 = 'Mother\'s Weight&'    + line + '&'

tabl.write(n4+n2+'\n' + n5+n3+'\n' + n6+n1+'\n' + n7+ne)

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chilean Survey of Early Infancy}} \\\\ \n')
for i,line in enumerate(CHIi):
    print line
    line = formatLine(line,1)
    if i==0: 
        n1 = 'Obese (pre)&'        + line + '\\\\'
    if i==1: 
        n2 = 'Underweight (pre)&'  + line + '\\\\'
    if i==2: 
        n3 = 'Gestation Diabetes&' + line + '\\\\'
    if i==3: 
        n4 = 'Gestation Depression&'+ line + '\\\\'
    if i==4:
        n5 = 'Smoked in Pregnancy&' + line + '&'
    if i==5:
        n6 = 'Drugs (Moderate) &'   + line + '&'
    if i==6:
        n7 = 'Drugs (High) &'       + line + '&'
    if i==7:
        n8 = 'Alcohol (Moderate) &' + line + '&'
    if i==8:
        n9 = 'Alcohol (High) &'     + line + '&'

tabl.write(n5+n1+'\n' + 
           n6+n2+'\n' +
           n7+n3+'\n' +
           n8+n4+'\n' +
           n9+'&&\\\\')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Somerset Birth Survey (United Kingdom)}} \\\\ \n')





tabl.write('\\bottomrule \n \\end{tabular}} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()


#==============================================================================
#== (2a) Write Unconditional unstandardised 
#==============================================================================
#CHIi = open(RIN + ).readlines()
#UKSi = open(RIN + ).readlines()

tabl = open(OUT + 'twinEffectsUncond.tex', 'w')

tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n \\caption{ ' + noteS1 + '}\n'
           '\scalebox{0.92}{'
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
    if i==0: 
        n1 = 'Mother\'s Height&'   + line + '&'
    elif i==1: 
        n2 = 'Mother\'s BMI&'      + line + '&'
    elif i==3: 
        n3 = 'Doctor Availability&'+ line + '\\\\'
    elif i==4: 
        n4 = 'Nurse Availability&' + line + '\\\\'
    elif i==5: 
        n5 = 'No Prenatal Care&'   + line + '\\\\'

tabl.write(n1+n3 + '\n' + n2+n4+ '\n' + '&&&'+n5+'\n')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: Swedish Medical Birth Registry}} \\\\ \n')
for i,line in enumerate(SWEi):
    line = formatLine(line,2)
    if i==0: 
        n1 = 'Asthma&'              + line + '\\\\'
    if i==1: 
        n2 = 'Diabetes (pre)&'      + line + '\\\\'
    if i==2: 
        ne = 'Kidney Disease (pre)&'+ line + '\\\\'
    if i==3: 
        n3 = 'Hypertension (pre)&'  + line + '\\\\'
    if i==4: 
        n4 = 'Smoked Trimester 1&'  + line + '&'
    if i==5: 
        n5 = 'Smoked Trimester 3&'  + line + '&'
    if i==6: 
        n6 = 'Mother\'s Height&'    + line + '&'
    if i==7: 
        n7 = 'Mother\'s Weight&'    + line + '&'

tabl.write(n4+n2+'\n' + n5+n3+'\n' + n6+n1+'\n' + n7+ne)

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chilean Survey of Early Infancy}} \\\\ \n')
for i,line in enumerate(CHIi):
    if i>-1:
        line = formatLine(line,2)
        if i==0: 
            n1 = 'Obese (pre)&'        + line + '\\\\'
        if i==1: 
            n2 = 'Underweight (pre)&'  + line + '\\\\'
        if i==2: 
            n3 = 'Gestation Diabetes&' + line + '\\\\'
        if i==3: 
            n4 = 'Gestation Depression&'+ line + '\\\\'
        if i==4:
            n5 = 'Smoked in Pregnancy&' + line + '&'
        if i==5:
            n6 = 'Drugs (Moderate) &'   + line + '&'
        if i==6:
            n7 = 'Drugs (High) &'       + line + '&'
        if i==7:
            n8 = 'Alcohol (Moderate) &' + line + '&'
        if i==8:
            n9 = 'Alcohol (High) &'     + line + '&'

tabl.write(n5+n1+'\n' + 
           n6+n2+'\n' +
           n7+n3+'\n' +
           n8+n4+'\n' +
           n9+'&&\\\\')

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Somerset Birth Survey (United Kingdom)}} \\\\ \n')

tabl.write('\\bottomrule \n \\end{tabular}} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()




print "Terminated Correctly."
