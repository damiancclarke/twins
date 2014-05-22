# twinTabs.py v 0.0.0            damiancclarke             yyyy-mm-dd:2014-03-29
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
Results  = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/IV/"
Results1 = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/OLS"
Results2 = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/"
Tables   = "/home/damiancclarke/investigacion/Activa/Twins/Tables/"

base = 'Base_IV_none.xls'
bord = 'Base_IV_bord.xls'
lowi = 'Income_IV_low_none.xls'
midi = 'Income_IV_mid_none.xls'
thre = 'Desire_IV_reg_all_none.xls'
twIV = 'Base_IV_twins_none.xls'
tbIV = 'Base_IV_twins_bord.xls'
gend = ['Gender_IV_F_none.xls','Gender_IV_M_none.xls']
geni = ['IVgender_alt.xls', 'GenderAll_IV_twin_none.xls']
genf = 'GenderAll_IV_firststage_twin_none.xls'

firs = 'Base_IV_firststage_none.xls'
fbor = 'Base_IV_firststage_bord.xls'
flow = 'Income_IV_firststage_low_none.xls'
fmid = 'Income_IV_firststage_mid_none.xls'
ftwi = 'Base_IV_twins_firststage_none.xls'
fdes = 'Desire_IV_firststage_reg_all_none.xls'

ols  = "QQ_ols_none.txt"
bala = "Balance_mother.tex"
twin = "Twin_Predict_none.xls"
summ = "Summary.txt"
sumc = "SummaryChild.txt"
sumf = "SummaryMortality.txt"
coun = "Count.txt"
dhss = "Countries.txt"

conl = "ConleyResults.txt"
imrt = "PreTwinTest_none.xls"

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
    twid = ['5','7','4','5','9','9','4','6','10','7']
    tcm  = ['}{p{10cm}}','}{p{15.8cm}}','}{p{10.4cm}}','}{p{11.6cm}}',
            '}{p{13.8cm}}','}{p{14.2cm}}','}{p{10.6cm}}','}{p{13.8cm}}',
            '}{p{18.0cm}}','}{p{13.4cm}}']
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

    rIV2 = '\\ref{TWINtab:IVTwoplus}'
    rIV3 = '\\ref{TWINtab:IVThreeplus}'
    rIV4 = '\\ref{TWINtab:IVFourplus}'
    rIV5 = '\\ref{TWINtab:IVFiveplus}'
    rTwi = '\\label{TWINtab:twinreg1}'
    rSuS = '\\label{TWINtab:sumstats}'
    rFSt = '\\ref{TWINtab:FS}'
    rCou = '\\ref{TWINtab:countries}'
    rGen = '\\ref{TWINtab:IVgend}'

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
    twid = ['','','','','','','','','','']
    tcm  = ['','','','','','','','','','']
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

    rIV2 = '5'
    rIV3 = '6'
    rIV4 = '12'
    rIV5 = '13'
    rTwi = '11'
    rSuS = '1'
    rFSt = '15'
    rCou = '10'
    rGen = '14'

#==============================================================================
#== (2) Function to return fertilility beta and SE for IV tables
#==============================================================================
def plustable(ffile,n1,n2,searchterm,alt,n3):
    beta = []
    se   = []
    N    = []

    f = open(ffile, 'r').readlines()

    for i, line in enumerate(f):
        if re.match(searchterm, line):
            beta.append(i)
            se.append(i+1)
        if re.match("N", line):
            N.append(i)
    
    TB = []
    TS = []
    TN = []
    if alt=='alt':
        for i,n in enumerate(beta):
            if i==0:
                TB.append(f[n].split()[n1:n2])
            elif i==1:
                TB.append(f[n].split()[n3])
        for i,n in enumerate(se):
            if i==0:
                TS.append(f[n].split()[n1-1:n2-1])
            elif i==1:
                TS.append(f[n].split()[n3-1])
    else:
        for n in beta:
            TB.append(f[n].split()[n1:n2])
        for n in se:
            TS.append(f[n].split()[n1-1:n2-1])
    for n in N:
        TN.append(f[n].split()[n1:n2])

    return TB, TS, TN


#==============================================================================
#== (3) Call functions, print table for plus groups
#==============================================================================
for i in ['Two', 'Three', 'Four', 'Five']:
    if i=="Two":
        num1=1
        num2=4
        t='two'
        des='first-born children' 
        IVf   = open(Tables+'TwoPlusIV.'+end, 'w')
    elif i=="Three":
        num1=4
        num2=7
        t='three'
        des='first- and second-born children' 
        IVf = open(Tables+'ThreePlusIV.'+end, 'w')
    elif i=="Four":
        num1=7
        num2=10
        t='four'
        des='first- to third-born children' 
        IVf = open(Tables+'FourPlusIV.'+end, 'w')
    elif i=="Five":
        num1=10
        num2=13
        t='five'
        des='first- to fourth-born children' 
        IVf = open(Tables+'FivePlusIV.'+end, 'w')

    TB1, TS1, TN1 = plustable(base, num1, num2,"fert",'normal',1000)
    TB2, TS2, TN2 = plustable(bord, num1, num2,"fert",'normal',1000)
    TB3, TS3, TN3 = plustable(lowi, num1, num2,"fert",'normal',1000)
    TB4, TS4, TN4 = plustable(midi, num1, num2,"fert",'normal',1000)
    TB5, TS5, TN5 = plustable(thre, num1, num2,"fert",'normal',1000)
    
    TB6, TS6, TN6 = plustable(twIV, num1, num2,"fert",'normal',1000)
    TB7, TS7, TN7 = plustable(tbIV, num1, num2,"fert",'normal',1000)

    FB, FS, FN    = plustable(firs, 1, 4,'twin\_'+t+'\_fam','normal',1000)

    print "Table for " + i + " Plus:"
    print ""

    if ftype=='tex':
        IVf.write("\\begin{table}[!htbp] \\centering \n"
        "\\caption{Instrumental Variables Estimates: "+i+" Plus} \n"
        "\\label{TWINtab:IV"+i+"plus} \n"
        "\\begin{tabular}{lcccc} \\toprule \\toprule \n")

    IVf.write(dd+"Base" + dd + dd + dd+ ls + "\n"
    +dd+"Controls"+dd+"Socioec"+dd+"Health"+dd+"Obs."+ls+mr+"\n"
    +mc1+twid[0]+mcsc+"Pre-Twins"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Fertility"+dd+TB1[0][0]+dd+TB1[0][1]+dd+TB1[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+TS1[0][0]+dd+TS1[0][1]+dd+TS1[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n" 
    +mc1+twid[0]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
    "Fertility"+dd+TB2[0][0]+dd+TB2[0][1]+dd+TB2[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+TS2[0][0]+dd+TS2[0][1]+dd+TS2[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Low-Income Countries"+mc2+ls+" \n"
    "Fertility"+dd+TB3[0][0]+dd+TB3[0][1]+dd+TB3[0][2]+
    dd+format(float(TN3[0][2]), "n")+ls+"\n"
    "         "+dd+TS3[0][0]+dd+TS3[0][1]+dd+TS3[0][2]+dd+ls+"\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Middle-Income Countries"+mc2+ls+" \n"
    "Fertility"+dd+TB4[0][0]+dd+TB4[0][1]+dd+TB4[0][2]+
    dd+format(float(TN4[0][2]), "n")+ls+"\n"
    "         "+dd+TS4[0][0]+dd+TS4[0][1]+dd+TS4[0][2]+dd+ls+"\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Desired-Threshold"+mc2+ls+" \n"
    "Fertility"+dd+TB5[0][0]+dd+TB5[0][1]+dd+TB5[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+TS5[0][0]+dd+TS5[0][1]+dd+TS5[0][2]+dd+ls+ "\n"
    +lname+dd+TB5[1][0]+dd+TB5[1][1]+dd+TB5[1][2]+dd+ls+"\n"
    "         "+dd+TS5[1][0]+dd+TS5[1][1]+dd+TS5[1][2]+dd+ls+"\n"+mr
    +mc1+twid[0]+mcsc+"Twins and Pre-Twins"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Fertility"+dd+TB6[0][0]+dd+TB6[0][1]+dd+TB6[0][2]+
    dd+format(float(TN6[0][2]), "n")+ls+"\n"
    "         "+dd+TS6[0][0]+dd+TS6[0][1]+dd+TS6[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
    "Fertility"+dd+TB7[0][0]+dd+TB7[0][1]+dd+TB7[0][2]+
    dd+format(float(TN6[0][2]), "n")+ls+"\n"
    "         "+dd+TS7[0][0]+dd+TS7[0][1]+dd+TS7[0][2]+dd+ls+ "\n"+mr
    +mc1+twid[0]+mcsc+"First Stage (Pre-Twins)"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Twins"+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+ls+ "\n"
    +hr+
    mc1+twid[0]+tcm[0]+mc3
    +i+"-plus refers to all "+des+ " in families with "+t+" or "
    "more children.  Each cell presents the coefficient of a 2SLS "
    "regression where fertility is instrumented by twinning at birth order "
    +t+".  Base controls include child age, mother's age, and mother's age "
    "at birth fixed effects plus country and year-of-birth FEs.  The sample "
    "is made up of all children aged between 6-18 years from families in the "
    "DHS who fulfill " +t+"-plus requirements. Birth order dummies are "
    "included only if explicitly stated.  First-stage results in the final "
    "panel correspond to the second stage in row 1.  Full first stage results "
    "for each row are available in table "+rFSt+". Standard "
    "errors are clustered by mother. \n"
    +foot)
    if ftype=='tex':
        IVf.write("\\end{footnotesize}}\n"+ls+br+
        "\\normalsize\\end{tabular}\\end{table} \n")

    IVf.close()

#==============================================================================
#== (4) Function to return fertilility beta and SE for OLS tables
#==============================================================================
os.chdir(Results1)

def olstable(ffile,n1,n2,n3):
    beta = []
    se   = []
    N    = []
    R    = []

    f = open(ffile, 'r').readlines()

    for i, line in enumerate(f):
        if re.match("fert", line):
            beta.append(i)
            se.append(i+1)
        if re.match("Observations", line):
            N.append(i)
        if re.match("R-squared", line):
            R.append(i)

    TB = []
    TS = []
    TN = []
    TR = []

    for i,n in enumerate(beta):
        if i==0:
            TB.append(f[n].split()[n1:n2])
        elif i==1:
            TB.append(f[n].split()[n3:n3+1])
    for i,n in enumerate(se):
        if i==0:
            TS.append(f[n].split()[n1-1:n2-1])
        elif i==1:
            TS.append(f[n].split()[n3-1:n3])
    for n in N:
        TN.append(f[n].split()[n1:n2])
    for n in R:
        TR.append(f[n].split()[n1:n2])

    A1 = float(re.search("-\d*\.\d*", TB[0][0]).group(0))
    A2 = float(re.search("-\d*\.\d*", TB[0][1]).group(0))
    A3 = float(re.search("-\d*\.\d*", TB[0][2]).group(0))
    AR1 = str(round(A2/(A1-A2), 3))
    AR2 = str(round(A3/(A1-A3), 3))

    return TB, TS, TN, TR, AR1, AR2


TBa, TSa, TNa, TRa, A1a, A2a = olstable(ols, 1, 5, 1)
TBl, TSl, TNl, TRl, A1l, A2l = olstable(ols, 5, 9, 2)
TBm, TSm, TNm, TRm, A1m, A2m = olstable(ols, 9, 13, 3)

#==============================================================================
#== (5) Write OLS table
#==============================================================================
OLSf = open(Tables+'OLS.'+end, 'w')

if ftype=='tex':
    OLSf.write("\\begin{landscape}\\begin{table}[!htbp] \\centering \n"
    "\\caption{OLS Estimates of the Q-Q Trade-off} \n "
    "\\label{TWINtab:OLS} \n"
    "\\begin{tabular}{lcccccc} \\toprule \\toprule \n")

OLSf.write(dd+"Base"+dd+"+"+dd+"+"+dd+"Desired"+dd+"Altonji"+dd+"Altonji"+ls+"\n"
+dd+"Controls"+dd+"Socioec"+dd+"Health"+dd+dd+"Ratio 1"+dd+"Ratio 2"+ls+mr+"\n"
+tsc+"Panel A: All Countries"+ebr+dd+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBa[0][0]+dd+TBa[0][1]+dd+TBa[0][2]+dd+TBa[0][3]+dd+A1a+dd+A2a+ls+"\n"
+            dd+TSa[0][0]+dd+TSa[0][1]+dd+TSa[0][2]+dd+TSa[0][3]+dd+dd+ls+  "\n"
+lname+dd+dd+dd+dd+TBa[1][0]+dd+dd+ls+"\n"
+            dd+dd+dd+dd+TSa[1][0]+dd+dd+ls+  "\n"
+dd+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNa[0][0])+dd+str(TNa[0][1])+dd+str(TNa[0][2])+dd
+str(TNa[0][3])+dd+dd+ls+"\n"
+R2+dd+str(TRa[0][0])+dd+ str(TRa[0][1])+dd+str(TRa[0][2])+dd+str(TRa[0][3])+dd+dd+ls
+mr+"\n"

+tsc+"Panel B: Low Income"+ebr+dd+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBl[0][0]+dd+TBl[0][1]+dd+TBl[0][2]+dd+TBl[0][3]+dd+A1l+dd+A2l+ls+"\n"
+            dd+TSl[0][0]+dd+TSl[0][1]+dd+TSl[0][2]+dd+TSl[0][3]+dd+dd+ls+  "\n"
+lname+dd+dd+dd+dd+TBl[1][0]+dd+dd+ls+"\n"
+            dd+dd+dd+dd+TSl[1][0]+dd+dd+ls+  "\n"
+dd+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNl[0][0])+dd+str(TNl[0][1])+dd+str(TNl[0][2])+dd
+str(TNl[0][3])+dd+dd+ls+"\n"
+R2+dd+str(TRl[0][0])+dd+ str(TRl[0][1])+dd+str(TRl[0][2])+dd+str(TRl[0][3])+dd+dd+ls
+mr+"\n"

+tsc+"Panel C: Middle Income"+ebr+dd+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBm[0][0]+dd+TBm[0][1]+dd+TBm[0][2]+dd+TBm[0][3]+dd+A1m+dd+A2m+ls+"\n"
+            dd+TSm[0][0]+dd+TSm[0][1]+dd+TSm[0][2]+dd+TSm[0][3]+dd+dd+ls+  "\n"
+lname+dd+dd+dd+dd+TBm[1][0]+dd+dd+ls+"\n"
+            dd+dd+dd+dd+TSm[1][0]+dd+dd+ls+  "\n"
+dd+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNm[0][0])+dd+str(TNm[0][1])+dd+str(TNm[0][2])+dd
+str(TNm[0][3])+dd+dd+ls+"\n"
+R2+dd+str(TRm[0][0])+dd+ str(TRm[0][1])+dd+str(TRm[0][2])+dd+str(TRm[0][3])+dd+dd+ls
+hr+hr+"\n"
+mc1+twid[1]+tcm[1]+mc3+
"Base controls consist of child gender, mother's age and age squared "
"mother's age at first birth, child age, country, and year of birth "
"dummies.  Socioeconomic augments `Base' to include mother's education "
"and education squared, and Health includes mother's height and BMI. " 
"``Desire'' takes 1 if the child is born before the family reaches it's "
"desired size, and 0 if the child is born after the desired size is reached. "
"The \\citet{Altonjietal2005} ratio determines how important unobservable "
"factors must be compared with included observables to imply that the true "
"effect of fertilty on educational attainment is equal to zero.  Ratio 1 "
"compares no controls to socioeconomic controls, while ratio 2 compares no "
"controls to socioeconomic and health controls. Standard errors are clustered "
"at the level of the mother.\n" + foot)

if ftype=='tex':
    OLSf.write("\\end{footnotesize}}\\\\  \n"
    "\\bottomrule \\normalsize\\end{tabular}\\end{table}\\end{landscape} \n")

OLSf.close()


#==============================================================================
#== (6) Read in balance table, fix formatting
#==============================================================================
bali = open(Results2+bala, 'r').readlines()
balo = open(Tables+"Balance_mother."+end, 'w')

for i,line in enumerate(bali):
    if ftype=='tex' or i>6:
        line = line.replace("&", dd)
        line = line.replace("\\\\", ls)
#        line = line.replace("\\begin{tabular}", "\\vspace{5mm}\\begin{tabular}")
        line = line.replace("\\toprule", "\\toprule\\toprule & Non-Twin & Twin & Diff.\\\\")
        line = line.replace("mu\_1", "Family")
        line = line.replace("mu\_2", "Family")
        line = line.replace("d/d\\_se", "(Diff. SE)")
        line = line.replace("\\end{tabular}", "")    
        line = line.replace("\\end{table}", "")    
        line = line.replace("\\bottomrule", mr+mr)    
        if ftype=='csv':
            line = line.replace('\\sym{','')
            line = line.replace('}','')
            line = line.replace('$','')
        balo.write(line)

balo.write(mc1+twid[2]+tcm[2]+mc3+
"All variables are at the level of the mother.  Education is measured in years," 
" mother's height in centimetres, and BMI is weight in kilograms over height in"
" metres squared.  Wealth "
"quintiles are determined by DHS methodology and are based on presence/absence"
" of particular goods in the household. Diff. SE is calculated using a "
"two-tailed t-test.  Sample is identical to that in table "+rSuS+"."
+foot)
if ftype=='tex':
    balo.write("\\end{footnotesize}}\n"+ls+br+
    "\\normalsize\\end{tabular}\\end{table} \n")

balo.close()

#==============================================================================
#== (7) Read in twin predict table, LaTeX format
#==============================================================================
twini = open(Results2+"Twin/"+twin, 'r')
twino = open(Tables+"TwinReg."+end, 'w')

if ftype=='tex':
    twino.write("\\begin{landscape}\\begin{table}[htpb!] \n"
    "\\caption{Probability of Giving Birth to Twins} \\label{TWINtab:twinreg1} \n"
    "\\begin{center}\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
    +dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin*100"+dd+"All"+dd+"\\multicolumn{2}{c}{Income}"+dd+
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
    twino.write(dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin*100"+dd+"All"+dd+"Income"+''+dd+dd+"Time"+''+dd+dd+"Prenatal"+ls+"\n"
    +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr+"\n\n")

for i,line in enumerate(twini):
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
        twino.write(line+'\n')

if ftype=='csv':
    twino.write(foot)
elif ftype=='tex':
    twino.write(foot+"\n \\end{footnotesize}}\\\\ \\hline \\normalsize "
    "\\end{tabular}\\end{center}\\end{table}\\end{landscape} \n")

twino.close()


#==============================================================================
#== (8) Read in summary stats, LaTeX format
#==============================================================================
counti = open(Results2+"Summary/"+coun, 'r')

addL = []
for i,line in enumerate(counti):
    if i<8:
        line=line.replace("(  ", "(")
        if ftype=='csv':
            line = line.replace('\\multicolumn{2}{c}{','')
            line = line.replace('}','')
            if i==4 or i==5 or i==6 or i==7:
                line = line.replace('&',';;')
            line = line.replace('&',';')
            line = line.replace('\\\\','')
        addL.append(line.replace("( ","("))
    elif i==8:
        nk = line
print nk

summi = open(Results2+"Summary/"+summ, 'r')
summc = open(Results2+"Summary/"+sumc, 'r')
summf = open(Results2+"Summary/"+sumf, 'r')
summo = open(Tables+"Summary."+end, 'w')

if ftype=='tex':
    summo.write("\\begin{table}[htpb!]\\caption{Summary Statistics} \n"
    "\\label{TWINtab:sumstats}\\begin{center}\\scalebox{0.95}{"
    "\\begin{tabular}{lccccc}\n\\toprule \\toprule \n"
    "&\\multicolumn{2}{c}{Low Income}&\\multicolumn{2}{c}{Middle Income}\\\\ \n" 
    "\\cmidrule(r){2-3} \\cmidrule(r){4-5}\n"
    "& Single & Twins & Single & Twins & All \\\\ \\midrule \n"
    "\\textsc{Fertility} & & & & & \\\\ \n")
elif ftype=='csv':
    summo.write(";Low Income;;Middle Income; \n" 
    "; Single ; Twins ; Single ; Twins; All \n"
    "FERTILITY ; ; ; ; ; \n")

for i,line in enumerate(summi):
    if i>2 and i%3!=2:
        line=re.sub(r"\s+", dd, line)
        line=re.sub(r"&$", ls+ls, line)
        #line=re.sub(r"&(\d+.\d+)&$", ls+ls, line)

        line = line.replace("bord"           , "Birth Order"            )
        line = line.replace("fert"           , "Fertility"              )
        line = line.replace("idealnumkids"   , "Desired Family Size"    )
        line = line.replace("agemay"         , "Age"                    )
        line = line.replace("educf"          , "Education"              )
        line = line.replace("height"         , "Height"                 )
        line = line.replace("bmi"            , "BMI"                    )
        line = line.replace("underweight"    , "Pr(BMI)$<$18.5"         )
        line = line.replace("exceedfam"      , "Actual Births$>$Desired")

        line = line.replace("Age", 
        addL[4]+ addL[5]+addL[6]+ addL[7]+
        "\\textsc{Mother's Characteristics}&&&&&\\\\ Age\n")


        if ftype=='csv':
            line=line.replace("\\textsc{Mother's Characteristics}&&&&&\\\\ Age\n",
            'MOTHER\'S CHARACTERISTICS \n Age')
            line=line.replace("$","")

        summo.write(line+'\n')
for i,line in enumerate(summc):
    if i>2 and i%3!=2:
        line=re.sub(r"\s+", dd, line)
        line=re.sub(r"&$", ls+ls, line)
        #line=re.sub(r"&(\d+.\d+)&$", ls+ls, line)
        line = line.replace("noeduc"         , "No Education (Percent)" )
        line = line.replace("educ"           , "Education (Years)"      )
        line = line.replace("school_zsc~e"   , "Education (Z-Score)"    )

        line = line.replace("Education (Years)", 
        "\\textsc{Children's Outcomes}&&&&&\\\\ Education (Years)\n")

        if ftype=='csv':
            line=line.replace("\\textsc{Children's Outcomes}&&&&&\\\\ Education (Years)\n",
            'CHILDREN\'S OUTCOMES \n Education (Years)')
            line=line.replace("$","")

        summo.write(line+'\n')

for i,line in enumerate(summf):
    if i>2 and i%3!=2:
        line=re.sub(r"\s+", dd, line)
        line=re.sub(r"&$", ls+ls, line)
        #line=re.sub(r"&(\d+.\d+)&$", ls+ls, line)
        line = line.replace("infantmort~y", "Infant Mortality")
        line = line.replace("childmorta~y", "Child Mortality" )

        if ftype=='csv':
            line=line.replace("$","")

        summo.write(line+'\n')

summo.write(
mr +'\n'+ addL[0] + addL[1] + addL[2] + addL[3] + mr + "\n"
+mc1+twid[7]+tcm[7]+mc3+"Summary statistics are presented for the full estimation "
" sample consisting of all children 18 years of age and under born to the " +nk+ 
" mothers responding to any publicly available DHS survey. Group "
"means are presented with standard deviation below in parenthesis.  Education" 
" is reported as total years attained, and Z-score presents educational "
"attainment relative to country and cohort (mean 0, std deviation 1).  Infant"
" mortality refers to the proportion of children who die before 1 year of age,"
"  while child mortality refers to the proportion who die before 5 years.  "
"Maternal height is reported in centimetres, and BMI is weight in kilograms "
"over height in metres squared.  For a full "
"list of country and years of survey, see appendix "
"table "+rCou+".")
if ftype=='tex':
    summo.write("\\end{footnotesize}} \\\\ \\bottomrule "
    "\\end{tabular}}\\end{center}\\end{table}")

summo.close()


#==============================================================================
#== (9) Create Conley et al. table
#==============================================================================
conli = open(Results2+"Conley/"+conl, 'r').readlines()
conlo = open(Tables+"Conley."+end, 'w')


if ftype=='tex':
    conlo.write("\\begin{table}[htpb!]\\caption{`Plausibly Exogenous' Bounds} \n"
    "\\label{TWINtab:Conley}\\begin{center}\\begin{tabular}{lcccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{2}{c}{UCI: $\\gamma\\in [0,\\delta]$}"
    "&\\multicolumn{2}{c}{LTZ: $\\gamma \\sim U(0,\\delta)$}\\\\ \n" 
    "\\cmidrule(r){2-3} \\cmidrule(r){4-5}\n")
elif ftype=='csv':
    conlo.write("UCI:;gamma in [0,delta];LTZ:;gamma ~ U(0,delta) \n")

for i,line in enumerate(conli):
    if i<5:
        line = re.sub('\s+', dd, line) 
        line = re.sub('&$', ls+ls, line)
        line = line.replace('Plus', ' Plus')
        line = line.replace('Bound', ' Bound')
        conlo.write(line + "\n")
    if i==5:
        delta = line.replace('deltas', '')
        delta = re.sub('\s+', ', ', delta) 
        delta = re.sub(', $', '.', delta)
        delta = re.sub('^,', ' ', delta)

conlo.write(mr+mc1+twid[3]+tcm[3]+mc3+
"This table presents upper and lower bounds of a 95\\% confidence interval "
"for the effects of family size on (standardised) children's education "
"attainment. These are estimated by the methodology of "
"\\citet{Conleyetal2012}  under various priors about the direct effect "
"that being from a twin family has on educational outcomes ("+mi+ "gamma"+
mo+"). In the UCI (union of confidence interval) approach, it is assumed "
"the true "+mi+"gamma\\in[0,\\delta]"+mo+", while in the LTZ (local to zero) "
"approach it is assumed that "+mi+"gamma\sim U(0,\\delta)"+mo+".  In each "
"case $\\delta$ is estimated by including twinning in the first stage  "
"equation and observing the effect size $\\hat\\gamma$.  Estimated "
"$\\hat\\gamma$'s are (respectively for two plus to five plus): "+delta)

if ftype=='tex':
    conlo.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\end{tabular}\\end{center}\\end{table} \n")


conlo.close()

#==============================================================================
#== (10) Create country list table
#==============================================================================
dhssi = open(Results2+"Summary/"+dhss, 'r').readlines()
dhsso = open(Tables+"Countries."+end, 'w')

if ftype=='tex':
    dhsso.write("\\end{spacing}\\begin{spacing}{1} \n"
    "\\begin{longtable}{llccccccc}\\caption{Full Survey Countries and Years} \\\\ \n"
    "\\toprule\\toprule\\label{TWINtab:countries} \n"
    "& & \\multicolumn{7}{c}{Survey Year} \\\\ \\cmidrule(r){3-9} \n"
    "\\textsc{Country}&\\textsc{Income}&1&2&3&4&5&6&7\\\\ \\midrule \n")
elif ftype=='csv':
    dhsso.write(";;Survey Year;;;;;; \n"
    "Country;Income;1;2;3;4;5;6;7 \n")

country = "Chile"
counter=7
for i,line in enumerate(dhssi):
    countryn = re.search("\w+[-\,\'\w* ]*", line).group(0)
    countryn = countryn.replace("-"," ")
    income = re.search('Middle|Low',line).group(0)
    if countryn!= country:
        dif=7-counter
        counter = 0
        country=countryn
        if i==0:
            dhsso.write(countryn+dd+income)
        else:
            dhsso.write(dd*dif+ls+'\n'+country+dd+income)
    year = re.search("\d+", line).group(0)
    dhsso.write(dd+year)
    counter = counter + 1

dhsso.write(ls+"\n"+mr+mc1+twid[4]+tcm[4]+mc3+
"Country income status is based upon World Bank classifications"
" described at http://data.worldbank.org/about/country-classifications "
"and available for download at "
"http://siteresources.worldbank.org/DATASTATISTICS/Resources/OGHIST.xls "
"(consulted 1 April, 2014).  Income status varies by country and time.  Where "
"a country's status changed between DHS waves only the most recent status is "
"listed above.  Middle refers to both lower-middle and upper-middle income "
"countries, while low refers just to those considered to be low-income economies.")
if ftype=='tex':
    dhsso.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\end{longtable}\\end{spacing}\\begin{spacing}{1.5}")


dhsso.close()

#==============================================================================
#== (11) Gender table
#==============================================================================
genfi = open(Results+gend[0],'r').readlines
genmi = open(Results+gend[1],'r').readlines

gendo = open(Tables+'Gender.'+end, 'w')


FB, FS, FN = plustable(Results+gend[0],1,13,"fert",'normal',1000)
MB, MS, MN = plustable(Results+gend[1],1,13,"fert",'normal',1000)


Ns = format(float(FN[0][0]), "n")+', '+format(float(MN[0][0]), "n")+', '
Ns = Ns + format(float(FN[0][3]),"n")+', '+format(float(MN[0][3]),"n")+', '
Ns = Ns + format(float(FN[0][8]),"n")+', '+format(float(MN[0][8]),"n")

if ftype=='tex':
    gendo.write("\\begin{table}[htpb!]\\caption{Q-Q IV Estimates by Gender} \n"
    "\\label{TWINtab:gend}\\begin{center}\\begin{tabular}{lcccccccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{4}{c}{Females}""&\\multicolumn{4}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-5} \\cmidrule(r){6-9} \n" 
    "&Base&Socioec&Health&Obs.&Base&Socioec&Health&Obs. \\\\ \\midrule \n"+lineadd)
elif ftype=='csv':
    gendo.write(";Females;;;Males;; \n"  
    ";Base;Socioec;Health;Obs.;Base;Socioec;Health;Obs. \n")


gendo.write(
"Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd+format(float(FN[0][0]), "n")+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+dd+format(float(MN[0][0]), "n")+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+dd+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][3]+dd+FB[0][4]+dd+FB[0][5]+dd+format(float(FN[0][3]), "n")+dd
+MB[0][3]+dd+MB[0][4]+dd+MB[0][5]+dd+format(float(MN[0][3]), "n")+ls+'\n'
+dd+FS[0][3]+dd+FS[0][4]+dd+FS[0][5]+dd+dd
+MS[0][3]+dd+MS[0][4]+dd+MS[0][5]+dd+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][6]+dd+FB[0][7]+dd+FB[0][8]+dd+format(float(FN[0][8]), "n")+dd
+MB[0][6]+dd+MB[0][7]+dd+MB[0][8]+dd+format(float(MN[0][8]), "n")+ls+'\n'
+dd+FS[0][6]+dd+FS[0][7]+dd+FS[0][8]+dd+dd
+MS[0][6]+dd+MS[0][7]+dd+MS[0][8]+dd+ls+'\n'
#+ lineadd +
#"Five Plus &"+FB[0][9]+'&'+FB[0][10]+'&'+FB[0][11]+'&'
#+MB[0][9]+'&'+MB[0][10]+'&'+MB[0][11]+'\\\\ \n'
#"&"+FS[0][9]+'&'+FS[0][10]+'&'+FS[0][11]+'&'
#+MS[0][9]+'&'+MS[0][10]+'&'+MS[0][11]+'\\\\ \n' 
+mr+mc1+twid[5]+tcm[5]+mc3+
"Female or male refers to the gender of the index child of the regression. \n"
"All regressions include full controls including socioeconomic and maternal "
"health variables.  The full lis of controls are available in \n"
"the notes to table "+rIV2+".  Full IV results for male and "
"female children are presented in table "+rGen+". Standard errors " 
"are clustered \n by mother."+foot+"\n")
if ftype=='tex':
    gendo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")

gendo.close()


#==============================================================================
#== (12) IMR Test table
#==============================================================================
imrti = open(Results2+"New/"+imrt, 'r').readlines()
imrto = open(Tables+"IMRtest."+end, 'w')

if ftype=='tex':
    imrto.write("\\begin{table}[htpb!]\n"
    "\\caption{Test of hypothesis that women who bear twins have better prior health}"
    "\\label{TWINtab:IMR}\\begin{center}\\begin{tabular}{lccc}\n"
    "\\toprule \\toprule \n"
    "\\textsc{Infant Mortality Rate}& Base & +S\\&H & Observations \\\\ \\midrule \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
elif ftype=='csv':
    imrto.write("IMR; Base ; +S&H ; Observations \n")
for i,line in enumerate(imrti):
    if re.match("treated", line):
        index=i
    if re.match("N", line):
        ind2=i


betas = imrti[index].split()
ses   = imrti[index+1].split()
Ns    = imrti[ind2].split()

imrto.write('Treated (2+)'+hs*6+dd+betas[1]+dd+betas[3]+dd+Ns[2]+ls+'\n'
+dd+ses[0]+dd+ses[2]+dd+ls+'\n'
'Treated (3+)'+hs+dd+betas[4]+dd+betas[6]+dd+Ns[4]+ls+'\n'
+dd+ses[3]+dd+ses[5]+dd+ls+'\n'
'Treated (4+)'+dd+betas[7]+dd+betas[9]+dd+Ns[7]+ls+'\n'
+dd+ses[6]+dd+ses[8]+dd+ls+'\n'
'Treated (5+)'+dd+betas[10]+dd+betas[12]+dd+Ns[10]+ls+'\n'
+dd+ses[9]+dd+ses[11]+dd+ls+
'\n'+mr+mc1+twid[6]+tcm[6]+mc3+
"The sample for these regressions consist of all children who have been entirely "
"exposed to the risk of infant mortality (ie those over 1 year of age). "
"Subsamples 2+, 3+, 4+ and 5+ are generated to allow comparison of children "
"born at similar birth orders.  For a full description of these groups see the "
"the body of the paper or notes to tables "+rIV2+", "+rIV3+", "+rIV4+" or "+rIV5+
" respectively. Treated=1 refers to children who are "
"born before a twin while Treated=0 refers to children of similar birth orders "
"not born before a twin.  Base and S+H controls are described in table "+rIV2+"."
+foot+" \n")
if ftype=='tex':
    imrto.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")


#==============================================================================
#== (14) First stage table
#==============================================================================
fstao = open(Tables+"firstStage."+end, 'w')

os.chdir(Results)

if ftype=='tex':
    fstao.write("\\begin{landscape}\\begin{table}[htpb!]"
    "\\caption{First Stage Results} \n\\label{TWINtab:FS}"
    "\\begin{center}\\begin{tabular}{lccccccccc}\n\\toprule \\toprule \n"
    "&\\multicolumn{3}{c}{2+}&\\multicolumn{3}{c}{3+}&\\multicolumn{3}{c}{4+}"
    "\\\\ \\cmidrule(r){2-4} \\cmidrule(r){5-7} \\cmidrule(r){8-10} \n"
    "\\textsc{Fertility}&Base&+S&+S\&H&Base&+S&+S\&H&Base&+S&+S\&H"
    "\\\\ \\midrule \n"
    +"\\begin{footnotesize}\\end{footnotesize}& \n"*9+
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
elif ftype=='csv':
    fstao.write(";2+;;;3+;;;4+;;;\n"
    "FERTILITY;Base;+S;+S&H;Base;+S;+S&H;Base;+S;+S&H \n")


PreB = []
PreS = []
BorB = []
BorS = []
LowB = []
LowS = []
MidB = []
MidS = []
DesB = []
DesS = []
De2B = []
De2S = []
TwiB = []
TwiS = []

for num in ['two','three','four']:
    searcher='twin\_'+num+'\_fam'
    searchup=searcher+'|twin'+num
    title = num.title()+'-Plus'

    FSB, FSS, FSN    = plustable(firs, 1, 4,searcher,'normal',1000)
    FBB, FBS, FBN    = plustable(fbor, 1, 4,searcher,'normal',1000)
    FLB, FLS, FLN    = plustable(flow, 1, 4,searcher,'normal',1000)
    FMB, FMS, FMN    = plustable(fmid, 1, 4,searcher,'normal',1000)
    FTB, FTS, FTN    = plustable(ftwi, 1, 4,searcher,'normal',1000)
    FDB, FDS, FDN    = plustable(fdes, 1, 4,searchup,'normal',1000)


    PreB.append(dd + FSB[0][0] + dd + FSB[0][1] + dd + FSB[0][2])
    PreS.append(dd + FSS[0][0] + dd + FSS[0][1] + dd + FSS[0][2])
    BorB.append(dd + FBB[0][0] + dd + FBB[0][1] + dd + FBB[0][2])
    BorS.append(dd + FBS[0][0] + dd + FBS[0][1] + dd + FBS[0][2])
    LowB.append(dd + FLB[0][0] + dd + FLB[0][1] + dd + FLB[0][2])
    LowS.append(dd + FLS[0][0] + dd + FLS[0][1] + dd + FLS[0][2])
    MidB.append(dd + FMB[0][0] + dd + FMB[0][1] + dd + FMB[0][2])
    MidS.append(dd + FMS[0][0] + dd + FMS[0][1] + dd + FMS[0][2])
    TwiB.append(dd + FTB[0][0] + dd + FTB[0][1] + dd + FTB[0][2])
    TwiS.append(dd + FTS[0][0] + dd + FTS[0][1] + dd + FTS[0][2])
    DesB.append(dd + FDB[0][0] + dd + FDB[0][1] + dd + FDB[0][2])
    DesS.append(dd + FDS[0][0] + dd + FDS[0][1] + dd + FDS[0][2])
    De2B.append(dd + FDB[1][0] + dd + FDB[1][1] + dd + FDB[1][2])
    De2S.append(dd + FDS[1][0] + dd + FDS[1][1] + dd + FDS[1][2])
    

fstao.write(mc1+twid[8]+mcbf+"Pre-Twins"+mc2+ls+" \n"
"Twin"+PreB[0]+PreB[1]+PreB[2]+ls+'\n'
+PreS[0]+PreS[1]+PreS[2]+ls+'\n'+lA+
mc1+twid[8]+mcbf+"Pre-Twins (+bord)"+mc2+ls+" \n"
"Twin"+BorB[0]+BorB[1]+BorB[2]+ls+'\n'
+BorS[0]+BorS[1]+BorS[2]+ls+'\n'+lA+
mc1+twid[8]+mcbf+"Low-Income"+mc2+ls+" \n"
"Twin"+LowB[0]+LowB[1]+LowB[2]+ls+'\n'
+LowS[0]+LowS[1]+LowS[2]+ls+'\n'+lA+
mc1+twid[8]+mcbf+"Middle-Income"+mc2+ls+" \n"
"Twin"+MidB[0]+MidB[1]+MidB[2]+ls+'\n'
+MidS[0]+MidS[1]+MidS[2]+ls+'\n'+lA+
mc1+twid[8]+mcbf+"Desired-Threshold"+mc2+ls+" \n"
"Twin"+DesB[0]+DesB[1]+DesB[2]+ls+'\n'
+DesS[0]+DesS[1]+DesS[2]+ls+'\n'
+tname+De2B[0]+De2B[1]+De2B[2]+ls+'\n'
+De2S[0]+De2S[1]+De2S[2]+ls+'\n'+lA+
mc1+twid[8]+mcbf+"Twins and Pre-twins"+mc2+ls+" \n"
"Twin"+TwiB[0]+TwiB[1]+TwiB[2]+ls+'\n'
+TwiS[0]+TwiS[1]+TwiS[2]+ls+'\n'+lA)


fstao.write('\n'+mr+mc1+twid[8]+tcm[8]+mc3+
"Each cell represents the coefficient from the first-stage of a two-stage "
"regression.  The first-stage represents the effect of twinning at parity "
"$N$ on total fertility where $N$ is 2, 3 or 4 for 2+, 3+ and 4+ groups "
"respectively.  The 2+ group includes all first borns in families with at "
"least 2 births, the 3+ group includes first and second borns in families "
"with at least 3 births, and the 4+ group includes all first to third borns "
"in families with at least four births.  In each regressions the sample is "
"made up of all children aged between 6-18 years from families in the DHS who "
"fulfill these birth order conditions.  Controls in each case are "
"identical to those described in table "+rIV2+".  Standard "
"errors are clustered at the level of the mother."+foot+" \n")
if ftype=='tex':
    fstao.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")


#==============================================================================
#== (14) Gender full IV
#==============================================================================
genio = open(Tables+'GenderIV.'+end, 'w')


FB1, FS1, FN1 = plustable(geni[0], 1, 6,"fert",'alt',1)
MB1, MS1, MN1 = plustable(geni[0], 6, 11,"fert",'alt',2)
FB2, FS2, FN2 = plustable(geni[0], 11, 16,"fert",'alt',3)
MB2, MS2, MN2 = plustable(geni[0], 16, 21,"fert",'alt',4)
FB3, FS3, FN3 = plustable(geni[0], 21, 26,"fert",'alt',5)
MB3, MS3, MN4 = plustable(geni[0], 26, 31,"fert",'alt',6)

AB, AS, AN = plustable(geni[1], 1, 13,"fert",'normal',1000)

B12, S12, N12 = plustable(genf, 1, 5,"twin_two_fam",'normal',1000)
B13, S13, N13 = plustable(genf, 1, 5,"twin_three_fam",'normal',1000)
B14, S14, N14 = plustable(genf, 1, 5,"twin_four_fam",'normal',1000)


if ftype=='tex':
    genio.write("\\begin{table}[!htbp] \\centering \n"
    "\\caption{Instrumental Variables Estimates: Female and Male Children} \n"
    "\\label{TWINtab:IVgend} \n"
    "\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
    "&\\multicolumn{3}{c}{Females}""&\\multicolumn{3}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-4} \\cmidrule(r){5-7} \n" 
    "&2+&3+&4+&2+&3+&4+ \\\\ \\midrule \n")
elif ftype=='csv':
    genio.write(";Females;;;Males;; \n"  
    ";2+;3+;4+;2+;3+;4+ \n")
genio.write(mc1+twid[9]+mcsc+"Pre-Twins"+mc2+ls+" \n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All Families"+mc2+ls+" \n"
"Fertility"+dd+FB[0][2]+dd+FB[0][5]+dd+FB[0][8]
+dd+MB[0][2]+dd+MB[0][5]+dd+MB[0][8]+ls+"\n"
""+dd+FS[0][2]+dd+FS[0][5]+dd+FS[0][8]+
dd+MS[0][2]+dd+MS[0][5]+dd+MS[0][8]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 
+mc1+twid[9]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
"Fertility"+dd+FB1[0][1]+dd+FB2[0][1]+dd+FB3[0][1]
+dd+MB1[0][1]+dd+MB2[0][1]+dd+MB3[0][1]+ls+"\n"
""+dd+FS1[0][1]+dd+FS2[0][1]+dd+FS3[0][1]+
dd+MS1[0][1]+dd+MS2[0][1]+dd+MS3[0][1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"Low-Income Countries"+mc2+ls+" \n"
"Fertility"+dd+FB1[0][2]+dd+FB2[0][2]+dd+FB3[0][2]
+dd+MB1[0][2]+dd+MB2[0][2]+dd+MB3[0][2]+ls+"\n"
""+dd+FS1[0][2]+dd+FS2[0][2]+dd+FS3[0][2]+
dd+MS1[0][2]+dd+MS2[0][2]+dd+MS3[0][2]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"Middle-Income Countries"+mc2+ls+" \n"
"Fertility"+dd+FB1[0][3]+dd+FB2[0][3]+dd+FB3[0][3]
+dd+MB1[0][3]+dd+MB2[0][3]+dd+MB3[0][3]+ls+"\n"
""+dd+FS1[0][3]+dd+FS2[0][3]+dd+FS3[0][3]+
dd+MS1[0][3]+dd+MS2[0][3]+dd+MS3[0][3]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"Desired-Threshold"+mc2+ls+" \n"
"Fertility"+dd+FB1[0][4]+dd+FB2[0][4]+dd+FB3[0][4]
+dd+MB1[0][4]+dd+MB2[0][4]+dd+MB3[0][4]+ls+"\n"
""+dd+FS1[0][4]+dd+FS2[0][4]+dd+FS3[0][4]+
dd+MS1[0][4]+dd+MS2[0][4]+dd+MS3[0][4]+ls+ "\n"
+lname     +dd+FB1[1]+dd+FB2[1]+dd+FB3[1]+
dd+MB1[1]+dd+MB2[1]+dd+MB3[1]+ls+"\n"
""+dd+FS1[1]+dd+FS2[1]+dd+FS3[1]+
dd+MS1[1]+dd+MS2[1]+dd+MS3[1]+ls+ "\n" +mr

+mc1+twid[0]+mcsc+"Twins and Pre-Twins"+mc2+ls+" \n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All Families"+mc2+ls+" \n"
"Fertility"+dd+AB[0][0]+dd+AB[0][4]+dd+AB[0][8]
+dd+AB[0][2]+dd+AB[0][6]+dd+AB[0][10]+ls+"\n"
"         "+dd+AS[0][0]+dd+AS[0][4]+dd+AS[0][8]
+dd+AS[0][2]+dd+AS[0][6]+dd+AS[0][10]+ls+"\n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
"Fertility"+dd+AB[0][1]+dd+AB[0][5]+dd+AB[0][9]
+dd+AB[0][3]+dd+AB[0][7]+dd+AB[0][11]+ls+"\n"
"         "+dd+AS[0][1]+dd+AS[0][5]+dd+AS[0][9]
+dd+AS[0][3]+dd+AS[0][7]+dd+AS[0][11]+ls+"\n" +mr

+mc1+twid[9]+mcsc+"First Stage (Pre-Twins)"+mc2+ls+" \n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All Families"+mc2+ls+" \n"
"Twins"+dd+B12[0][1]+dd+B13[0][1]+dd+B14[0][1]+
dd+B12[0][3]+dd+B13[0][3]+dd+B14[0][3]+ls+"\n"
"         "+dd+S12[0][1]+dd+S13[0][1]+dd+S14[0][1]+
dd+S12[0][3]+dd+S13[0][3]+dd+S14[0][3]+ls+ "\n"
+'\n'+mr+mc1+twid[9]+tcm[9]+mc3+
"Each cell presents the coefficient from a 2SLS regression of standardised "
"educational attainment on fertility.  2+, 3+ and 4+ refer to the birth "
"orders of children included in the regression.  For a full description of "
"these groups see tables "+rIV2+", "+rIV3+" and "+rIV4+
".  Each regression includes full controls "
"including maternal health and socioeconomic variables.  The sample is made "
"up of all children aged between 6-18 years from families in the DHS who "
"fulfill birth order and gender requirements indicated in the header.  "
"Standard errors are clustered by mother."
+foot+" \n")

if ftype=='tex':
    genio.write("\\end{footnotesize}}\n"+ls+br+
    "\\normalsize\\end{tabular}\\end{table} \n")
genio.close()


print "Terminated Correctly."
