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
RIN  = "/home/damian/investigacion/Activa/Twins/Results/World/"
SUM  = "/home/damian/investigacion/Activa/Twins/Results/Sum/"
OUT  = "/home/damian/investigacion/Activa/Twins/paper/twinsHealth/tex/"


noteE1 = ('\\textbf{Effect of Maternal Health on Twinning} {\\footnotesize  ' +
'Results from OLS regressions of a child\'s birth type (twin or singleton)  ' +
'on the mother\'s health behaviours and conditions are displayed. These     ' +
'results accompany figure 1 in the main text.  The outcome variable is a    ' +
'binary variable for a twin (=1) or singleton (=0) birth, multiplied by 100,' +
' so all coefficients are expressed in terms of the percent increase in     ' +
'twinning. Dependent variables are standardised so coefficients can be      ' +
'interpreted as the percent change in twin births associated with a 1       ' +
'standard deviation (1 $\\sigma$) increase in the variable of interest. All ' +
'models include fixed effects for age and birth order, and where possible,  ' +
'for gestation of the birth in weeks (panels A and C). Asterisks indicate   ' +
'significance levels of p-values, with: *p$<$0.1  **p$<$0.05  ***p$<$0.01.  ' +
'95\% confidence intervals are displayed in parentheses. Further details    ' +
'regarding estimation samples and variable construction are available in    '
'Supplementary Information.}')
noteE2 = ('\\textbf{Effect of Maternal Health on Twinning (Conditional      ' +
'Results)} \\footnotesize{ Results from OLS regressions of a child\'s birth ' +
'type (twin or singleton) on the mother\'s health behaviours and conditions ' +
'are displayed.  Specifications are identical to those in extended data     ' +
'table 5, however each variable ubdependent variable is included together   ' +
'in estimated regression. Asterisks indicate significance levels of p-values,'+
'with: *p$<$0.1  **p$<$0.05  ***p$<$0.01. 95\% confidence intervals are     ' +
'displayed in parentheses. Further details regarding estimation samples and ' +
'variable construction are available in Supplementary Information.}')
noteE3 = ('\\textbf{Effect of Maternal Health on Twinning (Unstandardised   ' +
'Variables)} \\footnotesize{ Results from OLS regressions of a child\'s     ' +
'birth type (twin or singleton) on the mother\'s health behaviours and      ' +
'conditions are displayed. Specifications are identical to those in extended' +
' data table 5, however each independent variable is unstandardised, so     ' +
'all coefficients are interpreted as the effect of a 1 unit increase in the ' +
'indepdent variable. Asterisks indicate significance levels of p-values,    ' +
'with: *p$<$0.1  **p$<$0.05  ***p$<$0.01. 95\% confidence intervals are     ' +
'displayed in parentheses. Further details regarding estimation samples and ' +
'variable construction are available in Supplementary Information.}')
noteS1 = ('\\textbf{Summary Statistics: All Samples (Panels A-C)} {         ' +
'\\footnotesize Each panel presents descriptive statistics of data from each' +
'context examined. Panel A comes from the United States Vital Statistics    ' +
'System for all non-ART users from 2009-2013, Panel B consists of all births' +
' from the Swedish Medical Birth Register from 1990-2011, and Panel C comes ' +
'Avon Longitudinal Study of Parents and Children.  Full data collection     ' +
'details are avilable in supplementary methods. All variables are either    ' +
'binary measures, or with units indicated in the variable name.} ' )
noteS2 = ('\\textbf{Summary Statistics: All Samples (Panels D-E)} {         ' +
'\\footnotesize Each panel presents descriptive statistics of data from each' +
' context examined. Panel D comes from the Chilean longitudinal study of    ' +
'early infancy, and panel E comes from all pooled publicly available        ' +
'Demographic and Health Surveys.  Full data collection details are avilable ' +
'in supplementary methods. All variables are either binary measures, or with' +
' units indicated in the variable name. }' )


#==============================================================================
#== (1b) Options
#==============================================================================
foot = "$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01"

def formatLine(line, vers):
    if vers==1:
        beta = float(line.split(";")[1])
        se   = float(line.split(";")[2])
        lCI  = format(float(line.split(";")[4]),'.3f')
        uCI  = format(float(line.split(";")[3]),'.3f')
    elif vers==2:
        beta = float(line.split(";")[5])
        se   = float(line.split(";")[6])
        lCI  = format(float(line.split(";")[8]),'.3f')
        uCI  = format(float(line.split(";")[7]),'.3f')

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
#== (1c) Sum stats
#==============================================================================
DHSs = open(SUM +   'DHSSum.tex').readlines()[1:-1]
USAs = open(SUM +   'USASum.tex').readlines()[1:-1]
UKAs = open(SUM +   'UKASum.tex').readlines()[1:-1]
CHIs = open(SUM + 'ChileSum.tex').readlines()[1:-1]
SWEs = open(SUM +   'SweSum.tex').readlines()[1:-1]

tabl = open(OUT + 'summaryStatsWorld.tex', 'w')
tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n'
           '\\caption{' + noteS1 + '}\n'
           '\\begin{tabular}{lccccc}\n \\toprule \n'
           '&N&Mean&Std.Dev.&Min&Max \\\\ \n'
           '\\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States}} \\\\ \n')
for i,line in enumerate(USAs):
    if i>0:
        tabl.write(line)

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Sweden}} \\\\ \n')
for i,line in enumerate(SWEs):
    if i>0:
        tabl.write(line)

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: United Kingdom (Avon)}} \\\\ \n')
for i,line in enumerate(UKAs):
    if i>0:
        tabl.write(line)
tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()


tabl = open(OUT + 'summaryStatsWorld_DE.tex', 'w')
tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n'
           '\\caption{' + noteS2 + '}\n'
           '\\begin{tabular}{lccccc}\n \\toprule \n'
           '&N&Mean&Std.Dev.&Min&Max \\\\ \n'
           '\\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chile}} \\\\ \n')
for i,line in enumerate(CHIs):
    if i>0:
        tabl.write(line)
tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel E: Developing Countries}} \\\\ \n')
for i,line in enumerate(DHSs):
    if i>0:
        tabl.write(line)

        
tabl.write('\\bottomrule \n \\end{tabular} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()

#==============================================================================
#== (2a) Write Unconditional Standardised 
#==============================================================================
DHSi = open(RIN + 'DHS_est_std_ucond.csv').readlines()[1:-1]
USAi = open(RIN + 'USA_est_std_ucond.csv').readlines()[1:-1]
CHIi = open(RIN + 'CHI_est_std_ucond.csv').readlines()[1:-1]
SWEi = open(RIN + 'SWE_est_std_ucond.csv').readlines()[1:-1]
UKAi = open(RIN + 'UKA_est_std_ucond.csv').readlines()[1:-1]

tabl = open(OUT + 'twinEffectsUncond.tex', 'w')

nameUSA = ['Height','Education', 'Smoked Before Pregnancy','Smoked Trimester 1',
           'Smoked Trimester 2', 'Smoked Trimester 3','Diabetes','Hypertension',
           'Underweight','Obese']
nameUKA = ['BMI','Height','Diabetes','Hypertension','Infections',
           'Drug Addiction','Alcoholism','Healthy Foods','Fresh Fruit']
nameSWE = ['Asthma','Diabetes','Kidney Disease','Hypertension','Smoked (12 weeks)',
           'Smoked (30-32 weeks)','Height','Underweight','Obese']
nameCHI = ['Smoked during Pregnancy','Drugs (Infrequently)','Drugs (Frequently)',
           'Alcohol (Infrequently)','Alcohol (Frequently)','Obese','Underweight',
           'Education']
nameDHS = ['Height','Underweight','Obese','Education','Doctor Availability',
           'Nurse Availability','Prenatal Care Availability']
lineUSA = []
lineUKA = []
lineCHI = []
lineSWE = []
lineDHS = []


tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{' + noteE1 + '}\n'
           '\scalebox{0.92}{'
           '\\begin{tabular}{llcllc}\n \\toprule'
           '\\multicolumn{3}{c}{Health Behaviours / Access} &'
           '\\multicolumn{3}{c}{Health Stocks and Conditions } \\\\ \n'
           '\\cmidrule(r){1-3} \\cmidrule(r){4-6} \n'
           'Variable & Estimate & [95\\% CI] &Variable & Estimate & [95\\% CI]'
           '\\\\ \\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States}} \\\\ \n')

for i,line in enumerate(USAi):
    line = formatLine(line,1)
    for j in range(0,10):
        if i==j:
            lineUSA.append(nameUSA[j]+'&'+line)

tabl.write(lineUSA[2]+'&'+lineUSA[0]+'\\\\' +
           lineUSA[3]+'&'+lineUSA[8]+'\\\\' +
           lineUSA[4]+'&'+lineUSA[9]+'\\\\' +
           lineUSA[5]+'&'+lineUSA[6]+'\\\\' +
           lineUSA[1]+'&'+lineUSA[7]+'\\\\' )

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Sweden}} \\\\ \n')
for i,line in enumerate(SWEi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineSWE.append(nameSWE[j]+'&'+line)

tabl.write(lineSWE[4]+'&'+lineSWE[6]+'\\\\' +
           lineSWE[5]+'&'+lineSWE[7]+'\\\\' +
           '&&&'         +lineSWE[8]+'\\\\' +
           '&&&'         +lineSWE[0]+'\\\\' +
           '&&&'         +lineSWE[1]+'\\\\' +  
           '&&&'         +lineSWE[2]+'\\\\' +            
           '&&&'         +lineSWE[3]+'\\\\' )

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: United Kingdom (Avon)}} \\\\ \n')
for i,line in enumerate(UKAi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineUKA.append(nameUKA[j]+'&'+line)

tabl.write(lineUKA[7]+'&'+lineUKA[1]+'\\\\' +
           lineUKA[8]+'&'+lineUKA[0]+'\\\\' +
           lineUKA[5]+'&'+lineUKA[2]+'\\\\' +
           lineUKA[6]+'&'+lineUKA[3]+'\\\\' +
           '&&&'         +lineUKA[4]+'\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chile}} \\\\ \n')
for i,line in enumerate(CHIi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineCHI.append(nameCHI[j]+'&'+line)

tabl.write(lineCHI[0]+'&'+lineCHI[6]+'\\\\' +
           lineCHI[1]+'&'+lineCHI[5]+'\\\\' +
           lineCHI[2]+'&&&\\\\' +
           lineCHI[3]+'&&&\\\\' +
           lineCHI[4]+'&&&\\\\' +
           lineCHI[7]+'&&&\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Developing Countries}} \\\\ \n')
for i,line in enumerate(DHSi):
    line = formatLine(line,1)
    for j in range(0,7):
        if i==j:
            lineDHS.append(nameDHS[j]+'&'+line)

tabl.write(lineDHS[4]+'&'+lineDHS[0]+'\\\\' +
           lineDHS[5]+'&'+lineDHS[1]+'\\\\' +
           lineDHS[6]+'&'+lineDHS[2]+'\\\\' +
           lineDHS[3]+'&&&\\\\')            

tabl.write('\\bottomrule \n \\end{tabular}} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()

#==============================================================================
#== (2b) Write Unconditional Unstandardised 
#==============================================================================
DHSi = open(RIN + 'DHS_est_non_ucond.csv').readlines()[1:-1]
USAi = open(RIN + 'USA_est_non_ucond.csv').readlines()[1:-1]
CHIi = open(RIN + 'CHI_est_non_ucond.csv').readlines()[1:-1]
SWEi = open(RIN + 'SWE_est_non_ucond.csv').readlines()[1:-1]
UKAi = open(RIN + 'UKA_est_non_ucond.csv').readlines()[1:-1]

tabl = open(OUT + 'twinEffectsUncondUnstand.tex', 'w')

lineUSA = []
lineUKA = []
lineCHI = []
lineSWE = []
lineDHS = []


tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{' + noteE3 + '}\n'
           '\scalebox{0.92}{'
           '\\begin{tabular}{llcllc}\n \\toprule'
           '\\multicolumn{3}{c}{Health Behaviours / Access} &'
           '\\multicolumn{3}{c}{Health Conditions } \\\\ \n'
           '\\cmidrule(r){1-3} \\cmidrule(r){4-6} \n'
           'Variable & Estimate & [95\\% CI] &Variable & Estimate & [95\\% CI]'
           '\\\\ \\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States}} \\\\ \n')

for i,line in enumerate(USAi):
    line = formatLine(line,1)
    for j in range(0,10):
        if i==j:
            lineUSA.append(nameUSA[j]+'&'+line)

tabl.write(lineUSA[2]+'&'+lineUSA[0]+'\\\\' +
           lineUSA[3]+'&'+lineUSA[8]+'\\\\' +
           lineUSA[4]+'&'+lineUSA[9]+'\\\\' +
           lineUSA[5]+'&'+lineUSA[6]+'\\\\' +
           lineUSA[1]+'&'+lineUSA[7]+'\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Sweden}} \\\\ \n')
for i,line in enumerate(SWEi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineSWE.append(nameSWE[j]+'&'+line)

tabl.write(lineSWE[4]+'&'+lineSWE[6]+'\\\\' +
           lineSWE[5]+'&'+lineSWE[7]+'\\\\' +
           '&&&'         +lineSWE[8]+'\\\\' +
           '&&&'         +lineSWE[0]+'\\\\' +
           '&&&'         +lineSWE[1]+'\\\\' +  
           '&&&'         +lineSWE[2]+'\\\\' +            
           '&&&'         +lineSWE[3]+'\\\\' )

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: United Kingdom (Avon)}} \\\\ \n')
for i,line in enumerate(UKAi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineUKA.append(nameUKA[j]+'&'+line)

tabl.write(lineUKA[7]+'&'+lineUKA[1]+'\\\\' +
           lineUKA[8]+'&'+lineUKA[0]+'\\\\' +
           lineUKA[5]+'&'+lineUKA[2]+'\\\\' +
           lineUKA[6]+'&'+lineUKA[3]+'\\\\' +
           '&&&'         +lineUKA[4]+'\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chile}} \\\\ \n')
for i,line in enumerate(CHIi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineCHI.append(nameCHI[j]+'&'+line)

tabl.write(lineCHI[0]+'&'+lineCHI[6]+'\\\\' +
           lineCHI[1]+'&'+lineCHI[5]+'\\\\' +
           lineCHI[2]+'&&&\\\\' +
           lineCHI[3]+'&&&\\\\' +
           lineCHI[4]+'&&&\\\\' +
           lineCHI[7]+'&&&\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Developing Countries}} \\\\ \n')
for i,line in enumerate(DHSi):
    line = formatLine(line,1)
    for j in range(0,7):
        if i==j:
            lineDHS.append(nameDHS[j]+'&'+line)

tabl.write(lineDHS[4]+'&'+lineDHS[0]+'\\\\' +
           lineDHS[5]+'&'+lineDHS[1]+'\\\\' +
           lineDHS[6]+'&'+lineDHS[2]+'\\\\' +
           lineDHS[3]+'&&&\\\\')            

tabl.write('\\bottomrule \n \\end{tabular}} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()

#==============================================================================
#== (2c) Write Conditional Standardised 
#==============================================================================
DHSi = open(RIN + 'DHS_est_std_cond.csv').readlines()[1:-1]
USAi = open(RIN + 'USA_est_std_cond.csv').readlines()[1:-1]
CHIi = open(RIN + 'CHI_est_std_cond.csv').readlines()[1:-1]
SWEi = open(RIN + 'SWE_est_std_cond.csv').readlines()[1:-1]
UKAi = open(RIN + 'UKA_est_std_cond.csv').readlines()[1:-1]

tabl = open(OUT + 'twinEffectsCond.tex', 'w')

lineUSA = []
lineUKA = []
lineCHI = []
lineSWE = []
lineDHS = []


tabl.write('\\begin{spacing}{1}\n\n \\begin{table}[htpb!]\n'
           '\\begin{center}\n\\caption{' + noteE2 + '}\n'
           '\scalebox{0.92}{'
           '\\begin{tabular}{llcllc}\n \\toprule'
           '\\multicolumn{3}{c}{Health Behaviours / Access} &'
           '\\multicolumn{3}{c}{Health Conditions } \\\\ \n'
           '\\cmidrule(r){1-3} \\cmidrule(r){4-6} \n'
           'Variable & Estimate & [95\\% CI] &Variable & Estimate & [95\\% CI]'
           '\\\\ \\midrule \n'
           '\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel A: United States}} \\\\ \n')

for i,line in enumerate(USAi):
    line = formatLine(line,1)
    for j in range(0,10):
        if i==j:
            lineUSA.append(nameUSA[j]+'&'+line)

tabl.write(lineUSA[2]+'&'+lineUSA[0]+'\\\\' +
           lineUSA[3]+'&'+lineUSA[8]+'\\\\' +
           lineUSA[4]+'&'+lineUSA[9]+'\\\\' +
           lineUSA[5]+'&'+lineUSA[6]+'\\\\' +
           lineUSA[1]+'&'+lineUSA[7]+'\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel B: Sweden}} \\\\ \n')
for i,line in enumerate(SWEi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineSWE.append(nameSWE[j]+'&'+line)

tabl.write(lineSWE[4]+'&'+lineSWE[6]+'\\\\' +
           lineSWE[5]+'&'+lineSWE[7]+'\\\\' +
           '&&&'         +lineSWE[8]+'\\\\' +
           '&&&'         +lineSWE[0]+'\\\\' +
           '&&&'         +lineSWE[1]+'\\\\' +  
           '&&&'         +lineSWE[2]+'\\\\' +            
           '&&&'         +lineSWE[3]+'\\\\' )

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel C: United Kingdom (Avon)}} \\\\ \n')
for i,line in enumerate(UKAi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineUKA.append(nameUKA[j]+'&'+line)

tabl.write(lineUKA[7]+'&'+lineUKA[1]+'\\\\' +
           lineUKA[8]+'&'+lineUKA[0]+'\\\\' +
           lineUKA[5]+'&'+lineUKA[2]+'\\\\' +
           lineUKA[6]+'&'+lineUKA[3]+'\\\\' +
           '&&&'         +lineUKA[4]+'\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Chile}} \\\\ \n')
for i,line in enumerate(CHIi):
    line = formatLine(line,1)
    for j in range(0,9):
        if i==j:
            lineCHI.append(nameCHI[j]+'&'+line)

tabl.write(lineCHI[0]+'&'+lineCHI[6]+'\\\\' +
           lineCHI[1]+'&'+lineCHI[5]+'\\\\' +
           lineCHI[2]+'&&&\\\\' +
           lineCHI[3]+'&&&\\\\' +
           lineCHI[4]+'&&&\\\\' +
           lineCHI[7]+'&&&\\\\' )            

tabl.write('\\rowcolor{LightCyan} \\multicolumn{6}{c}'
           '{\\textbf{Panel D: Developing Countries}} \\\\ \n')
for i,line in enumerate(DHSi):
    line = formatLine(line,1)
    for j in range(0,7):
        if i==j:
            lineDHS.append(nameDHS[j]+'&'+line)

tabl.write(lineDHS[4]+'&'+lineDHS[0]+'\\\\' +
           lineDHS[5]+'&'+lineDHS[1]+'\\\\' +
           lineDHS[6]+'&'+lineDHS[2]+'\\\\' +
           lineDHS[3]+'&&&\\\\')            

tabl.write('\\bottomrule \n \\end{tabular}} \n \\end{center} \\end{table} \n'
           '\n \\end{spacing}')

tabl.close()



print "Terminated Correctly."
