# scienceTabs.py v 0.0.0         damiancclarke             yyyy-mm-dd:2014-04-29
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

from sys import argv
import re
import os
import locale
locale.setlocale(locale.LC_ALL, 'en_US')

script, ftype = argv
print('\n\nHey DCC. The script %s is making %s files \n' %(script, ftype))

#==============================================================================
#== (1a) File names (comes from Twin_Regressions.do)
#==============================================================================
Results  = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/"
Results2 = "/home/damiancclarke/investigacion/Activa/Twins/Scientific/Results/"
Tables   = "/home/damiancclarke/investigacion/Activa/Twins/Scientific/Tables/"

DHS      = "Twin_Predict_none.xls"
Chile    = "twinELPI.xls"
Scotland = "twinScotland.csv"

os.chdir(Results)

#==============================================================================
#== (1b) Options (tex or csv out)
#==============================================================================
if ftype=='tex':
    dd   = "&"
    dd1  = "&\\begin{footnotesize}"
    dd2  = "\\end{footnotesize}&\\begin{footnotesize}"
    dd3  = "\\end{footnotesize}"
    end  = "tex"
    foot = "$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01"
    ls   = "\\\\"
    mr   = '\\midrule'
    hr   = '\\hline'
    tr   = '\\toprule'
    br   = '\\bottomrule'
    mc1  = '\\multicolumn{'
    mcsc = '}{l}{\\textsc{'
    mcbf = '}{l}{\\textbf{'    
    mc2  = '}}'
    twid = ['4']
    tcm  = ['}{p{11cm}}']
    mc3  = '{\\begin{footnotesize}\\textsc{Notes:} '
    lname = "Fertility$\\times$desire"
    tname = "Twin$\\times$desire"
    tsc  = '\\textsc{' 
    ebr  = '}'
    R2   = 'R$^2$'
    mi   = '$\\'
    mo   = '$'
    lineadd = '\\begin{footnotesize}\\end{footnotesize}&'*6+ls
    lA   = '\\begin{footnotesize}\\end{footnotesize}&'*9+'\\begin{footnotesize}\\end{footnotesize}'+ls
    hs   = '\\hspace{5mm}'

    rTwi = '\\label{TWINtab:twinreg1}'

elif ftype=='csv':
    dd   = ";"
    dd1  = ";"
    dd2  = ";"
    dd3  = ";"
    end  = "csv"
    foot = "* p<0.1, ** p<0.05, *** p<0.01"
    ls   = ""
    mr   = ""
    hr   = ""
    br   = ""
    tr   = ""
    mc1  = ''
    mcsc = ''
    mcbf = ''   
    mc2  = ''
    twid = ['','']
    tcm  = ['','']
    mc3  = 'NOTES: '
    lname = "Fertility*desire"
    tname = "Twin*desire"
    tsc  = '' 
    ebr  = ''
    R2   = 'R-squared'
    mi   = ''
    mo   = ''
    lineadd = ''
    lA   = '\n'
    hs   = ''

    rTwi = '11'

#==============================================================================
#== (1) Read in DHS twin predict table, LaTeX format
#==============================================================================
DHSi = open(Results+"Twin/"+DHS, 'r')
DHSo = open(Tables+"TwinReg."+end, 'w')

if ftype=='tex':
    DHSo.write("\\begin{landscape}\\begin{table}[htpb!] \n"
    "\\caption{Probability of Giving Birth to Twins} \\label{TWINtab:twinreg1} \n"
    "\\begin{center}\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
    +dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin$\\times$100"+dd+"All"+dd+"\\multicolumn{2}{c}{Income}"+dd+
    "\\multicolumn{2}{c}{Time}"+dd+"Prenatal"+ls+"\n "
    "\\cmidrule(r){3-4} \\cmidrule(r){5-6} \n"
    +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr+ "\n"
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+ls+"\n")
elif ftype=='csv':
    DHSo.write(dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin*100"+dd+"All"+dd+"Income"+''+dd+dd+"Time"+''+dd+dd+"Prenatal"+ls+"\n"
    +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr+"\n\n")

for i,line in enumerate(DHSi):
    if i>2:
        line = line.replace("\t",dd)
        line = line.replace("\n", ls)
        line = line.replace("\"", "")
        line = line.replace("made.\\\\", "made.")
        line = line.replace("made.&&&&&&\\\\", "made.")
        line = line.replace("antenatal", "Antenatal Visits")
        line = line.replace("prenate_doc", "Prenatal (Doctor)")
        line = line.replace("prenate_nurse", "Prenatal (Nurse)")
        line = line.replace("prenate_none", "Prenatal (None)")
        line = line.replace("Notes:", 
        "\\hline\\hline\\multicolumn{7}{p{14.3cm}}{\\begin{footnotesize}\\textsc{Notes:}")
        line = line.replace("r2", dd*6+ls+"R-squared")
        line = line.replace("N&", "Observations &")
        line = re.sub(r"(?<=\d),(?=\d)",".", line)
        if ftype=='csv':
            line=line.replace(';;;;;;R-squared','R-squared')
            line=line.replace('\\hline\\hline\\multicolumn{7}{p{14.3cm}}','')
            line=line.replace('{\\begin{footnotesize}\\textsc{Notes:}','NOTES:')
        DHSo.write(line+'\n')

if ftype=='csv':
    DHSo.write(foot)
elif ftype=='tex':
    DHSo.write(foot+"\n \\end{footnotesize}}\\\\ \\hline \\normalsize "
    "\\end{tabular}\\end{center}\\end{table}\\end{landscape} \n")

DHSo.close()


#==============================================================================
#== (2) Read in Chile twin predict table
#==============================================================================
Chilei = open(Results2+Chile, 'r').readlines()
Chileo = open(Tables+"ChileTwin."+end, 'w')

coefs = []

if ftype=='tex':
    Chileo.write("\\begin{table}[htpb!] \n"
    "\\caption{Probability of Giving Birth to Twins (Chile)} \n"
    "\\label{TWINtab:Chile} \n"
    "\\begin{center}\\begin{tabular}{lclc} \\toprule \\toprule \n"
    +dd+"(1)"+dd+dd+ls+"\n"
    "Twin$\\times$100"+dd+dd+dd+ls+"\\midrule\n"
    "\\multicolumn{2}{l}{\\textsc{Pre-Pregnancy}}&"
    "\\multicolumn{2}{l}{\\textsc{Pregnancy}}"+ls+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+ls+"\n")
elif ftype=='csv':
    Chileo.write(dd+"(1)"+dd+dd+dd+ls+"\n"
    "Twin*100"+dd+"Pre-pregnancy"+dd+dd+"Pregnancy"+ls+"\n\n")

#FIX THIS USING PYTHON FLAVOUR SWITCH STATEMENT.
#CHECK STACKOVERFLOW WHEN CONNECTED (perhaps a dict?)
for i,line in enumerate(Chilei):
    if re.match("Msecondary",line):
        coefs.append(i)
    if re.match("Mtertiary",line):
        coefs.append(i)
    if re.match("incomepc",line):
        coefs.append(i)
    if re.match("lowWeightPre",line):
        coefs.append(i)
    if re.match("obesePre",line):
        coefs.append(i)
    if re.match("pregNoAttention",line):
        coefs.append(i)
    if re.match("pregDiabetes",line):
        coefs.append(i)
    if re.match("pregDepression",line):
        coefs.append(i)
    if re.match("pregLowWeight",line):
        coefs.append(i)
    if re.match("pregObese",line):
        coefs.append(i)
    if re.match("pregSmoked",line):
        coefs.append(i)
    if re.match("2.pregDrugs",line):
        coefs.append(i)
    if re.match("3.pregDrugs",line):
        coefs.append(i)
    if re.match("2.pregAlcohol",line):
        coefs.append(i)
    if re.match("3.pregAlcohol",line):
        coefs.append(i)
    if re.match("pregHosp",line):
        coefs.append(i)
    if re.match("m\_age",line):
        coefs.append(i)
    if re.match("indig",line):
        coefs.append(i)
    if re.match("r2",line):
        coefs.append(i)
    if re.match("N",line):
        coefs.append(i)

Chileo.write("Income p.c."+dd+Chilei[coefs[2]].split()[1]+dd+
"Smoked"+dd+Chilei[coefs[11]].split()[1]+ls+"\n"
+dd+Chilei[coefs[2]+1]+dd+dd+Chilei[coefs[11]+1]+ls+"\n"
"Income p.c. squared"+dd+Chilei[coefs[3]].split()[1]+dd+
"Drugs (infrequent)"+dd+Chilei[coefs[12]].split()[1]+ls+"\n"
+dd+Chilei[coefs[3]+1]+dd+dd+Chilei[coefs[12]+1]+ls+"\n"
"Secondary Education"+dd+Chilei[coefs[0]].split()[1]+dd+
"Drugs (frequent)"+dd+Chilei[coefs[13]].split()[1]+ls+"\n"
+dd+Chilei[coefs[0]+1]+dd+dd+Chilei[coefs[13]+1]+ls+"\n"
"Tertiary Education"+dd+Chilei[coefs[1]].split()[1]+dd+
"Alcohol (infrequent)"+dd+Chilei[coefs[14]].split()[1]+ls+"\n"
+dd+Chilei[coefs[1]+1]+dd+dd+Chilei[coefs[14]+1]+ls+"\n"
"Low Weight"+dd+Chilei[coefs[4]].split()[1]+dd+
"Alcohol (frequent)"+dd+Chilei[coefs[15]].split()[1]+ls+"\n"
+dd+Chilei[coefs[4]+1]+dd+dd+Chilei[coefs[15]+1]+ls+"\n"
"Obese"+dd+Chilei[coefs[5]].split()[1]+dd+
"No Check-ups"+dd+Chilei[coefs[6]].split()[1]+ls+"\n"
+dd+Chilei[coefs[5]+1]+dd+dd+Chilei[coefs[6]+1]+ls+"\n"
"Mother's Age"+dd+Chilei[coefs[17]].split()[1]+dd+
"Hospital Birth"+dd+Chilei[coefs[16]].split()[1]+ls+"\n"
+dd+Chilei[coefs[17]+1]+dd+dd+Chilei[coefs[16]+1]+ls+"\n"
"Mother's Age Squared"+dd+Chilei[coefs[18]].split()[1]+dd+
"Diabetes"+dd+Chilei[coefs[7]].split()[1]+ls+"\n"
+dd+Chilei[coefs[18]+1]+dd+dd+Chilei[coefs[7]+1]+ls+"\n"
"Indigenous"+dd+Chilei[coefs[19]].split()[1]+dd+
"Depression"+dd+Chilei[coefs[8]].split()[1]+ls+"\n"
+dd+Chilei[coefs[19]+1]+dd+dd+Chilei[coefs[8]+1]+ls+"\n"
+dd+dd+dd+ls+"\n"
"Observations"+dd+Chilei[coefs[21]].split()[1]
+dd+"R-squared"+dd+Chilei[coefs[20]].split()[1]+ls+"\n"
)


Chileo.write(mr+mc1+twid[0]+tcm[0]+mc3+"Data comes from the Encuesta "
"Longitudinal de Primera Infancia (ELPI) from Chile. Education at each "
"level are dummy variables, primary education is the omitted base. "
"Regional controls and child age fixed effects are omitted for clarity. "
"Heteroscedasticity robust standard errors are presented in parenthesis."
+foot)
if ftype=='tex':
    Chileo.write("\\end{footnotesize}}\\\\ \\hline \\normalsize "
    "\\end{tabular}\\end{center}\\end{table}\n")


Chileo.close()

#==============================================================================
#== (3) Read in Scotland twin predict table
#==============================================================================
Scoti = open(Results2+Scotland, 'r').readlines()
Scoto = open(Tables+"ScotlandTwin."+end, 'w')

coefs = []

if ftype=='tex':
    Scoto.write("\\begin{table}[htpb!] \n"
    "\\caption{Probability of Giving Birth to Twins (Scotland)} \n"
    "\\label{TWINtab:Scotland} \n"
    "\\begin{center}\\begin{tabular}{lclc} \\toprule \\toprule \n"
    +dd+"(1)"+dd+dd+ls+"\n"
    "Twin$\\times$100"+dd+dd+dd+ls+"\\midrule\n"
    "\\multicolumn{2}{l}{\\textsc{Pre-Pregnancy}}&"
    "\\multicolumn{2}{l}{\\textsc{Pregnancy}}"+ls+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+dd+
    "\\begin{footnotesize}\\end{footnotesize}"+ls+"\n")
elif ftype=='csv':
    Scoto.write(dd+"(1)"+dd+dd+dd+ls+"\n"
    "Twin*100"+dd+"Pre-pregnancy"+dd+dd+"Pregnancy"+ls+"\n\n")

for i,line in enumerate(Scoti):
    if re.match("age mother",line):
        coefs.append(i)
    if re.match("married",line):
        coefs.append(i)
    if re.match("index",line):
        coefs.append(i)
    if re.match("diabetes",line):
        coefs.append(i)
    if re.match("maternal",line):
        coefs.append(i)
    if re.match("curr",line):
        coefs.append(i)
    if re.match("prev",line):
        coefs.append(i)
    if re.match("smok",line):
        coefs.append(i)
    if re.match("alc",line):
        coefs.append(i)
    if re.match("Obs",line):
        coefs.append(i)
    if re.match("R-",line):
        coefs.append(i)



Scoto.write("Deprivation Index (Quintile 2)"+dd+Scoti[coefs[3]].split(',')[1]
+dd+"Smoker"+dd+Scoti[coefs[14]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[3]+1].split(',')[1]+dd+dd+Scoti[coefs[14]+1].split(',')[1]+ls+"\n"
"Deprivation Index (Quintile 3)"+dd+Scoti[coefs[4]].split(',')[1]
+dd+"Previous Smoker"+dd+Scoti[coefs[15]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[4]+1].split(',')[1]+dd+dd+Scoti[coefs[15]+1].split(',')[1]+ls+"\n"

"Deprivation Index (Quintile 4)"+dd+Scoti[coefs[5]].split(',')[1]
+dd+"Alcohol (1-2 per week)"+dd+Scoti[coefs[17]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[5]+1].split(',')[1]+dd+dd+Scoti[coefs[17]+1].split(',')[1]+ls+"\n"

"Deprivation Index (Quintile 5)"+dd+Scoti[coefs[6]].split(',')[1]
+dd+"Alcohol (3+ per week)"+dd+Scoti[coefs[18]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[6]+1].split(',')[1]+dd+dd+Scoti[coefs[18]+1].split(',')[1]+ls+"\n"

"Height"+dd+Scoti[coefs[10]].split(',')[1]
+dd+"Overweight"+dd+Scoti[coefs[11]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[10]+1].split(',')[1]+dd+dd+Scoti[coefs[11]+1].split(',')[1]+ls+"\n"

"Married"+dd+Scoti[coefs[2]].split(',')[1]
+dd+"Obese"+dd+Scoti[coefs[12]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[2]+1].split(',')[1]+dd+dd+Scoti[coefs[12]+1].split(',')[1]+ls+"\n"

"Age"+dd+Scoti[coefs[0]].split(',')[1]
+dd+"Diabetes"+dd+Scoti[coefs[4]].split(',')[1]+ls+"\n"
+dd+Scoti[coefs[0]+1].split(',')[1]+dd+dd+Scoti[coefs[4]+1].split(',')[1]+ls+"\n"

"Age Squared"+dd+Scoti[coefs[1]].split(',')[1]
+dd+dd+ls+"\n"
+dd+Scoti[coefs[1]+1].split(',')[1]+dd+dd+ls+"\n"

+dd+dd+dd+ls+"\n"
"Observations"+dd+Scoti[coefs[20]].split(',')[1]
#+dd+"R-squared"+dd+Scoti[coefs[21]].split(',')[1]+ls+"\n"
+dd+"R-squared&0.01"+ls+"\n"
)




Scoto.write(mr+mc1+twid[0]+tcm[0]+mc3+"Data comes from the ADD NOTE HERE!."
+foot)
if ftype=='tex':
    Scoto.write("\\end{footnotesize}}\\\\ \\hline \\normalsize "
    "\\end{tabular}\\end{center}\\end{table}\n")

Scoto.close()


#==============================================================================
print "Terminated Correctly.\n"
#==============================================================================

