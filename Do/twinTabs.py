# twinTabs.py v 0.0.0            damiancclarke             yyyy-mm-dd:2014-03-29
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

from sys import argv
import re
import os
import locale
locale.setlocale(locale.LC_ALL, 'en_US.utf8')

script, ftype = argv
print('\n\nHey DCC. The script %s is making %s files \n' %(script, ftype))

#==============================================================================
#== (1a) File names (comes from Twin_Regressions.do)
#==============================================================================
Results  = "/home/damian/investigacion/Activa/Twins/Results/Outreg/"
Tables   = "/home/damian/investigacion/Activa/Twins/Tables/"

base = 'All.txt'
lowi = 'LowIncome.xls'
midi = 'MidIncome.xls'
thre = 'Desire_IV_reg_all.xls'
twIV = 'Base_IV_twins.xls'
adjf = 'ADJAll.xls'
feei = 'fees.xls'
nfei = 'no-fees.xls'

gend = ['Girls.xls','Boys.xls']
genl = ['gendFLow.xls','gendMLow.xls']
genm = ['gendFMid.xls','gendMMid.xls']
gent = ['gendFWithTwin.xls','gendMWithTwin.xls']
gena = ['ADJGirls.xls','ADJBoys.xls']
fgen = ['Girls_first.xls','Boys_first.xls']
fgna = ['ADJGirls_first.xls','ADJBoys_first.xls']

firs = 'All_first.txt'
flow = 'LowIncome_first.xls'
fmid = 'MidIncome_first.xls'
ftwi = 'Base_IV_twins_firststage.xls'
fadj = 'ADJAll_first.xls'
fdes = 'Desire_IV_firststage_reg_all.xls'

ols  = "QQ_ols.txt"
ost  = "OsterValues.txt"
olsn = "QQ_plusgroups.txt"
olsn = "All.txt"
ostn = "OsterValues_nPlus.txt"

bala = "Balance_mother.tex"
twin = "Twin_Predict.xls"
twiP = "Twin_PredictProbit.xls"
samp = "Samples.txt"
summ = "Summary.txt"
sumc = "SummaryChild.txt"
sumf = "SummaryMortality.txt"
coun = "Count.txt"
dhss = "Countries.txt"

conl = "ConleyGamma.txt"
conU = "ConleyGammaNHIS.txt"
imrt = "PreTwinTest.xls"

gamT = "gammaEstimates.txt"
gamN = "gammaEstNigeria.txt"
os.chdir(Results+'IV/')

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
    twid = ['5','4','4','5','9','9','5','6','10','7','12','6','12','5','10']
    tcm  = ['}{p{10.0cm}}','}{p{9.2cm}}','}{p{10.4cm}}','}{p{11.6cm}}',
            '}{p{13.8cm}}','}{p{14.2cm}}','}{p{13.4cm}}','}{p{13.8cm}}',
            '}{p{18.0cm}}','}{p{12.8cm}}','}{p{18cm  }}','}{p{10.0cm}}',
            '}{p{18.8cm}}','}{p{12.4cm}}','}{p{20.2cm}}']
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
    lA2  = '\\begin{footnotesize}\\end{footnotesize}&'*11+'\\begin{footnotesize}\\end{footnotesize}'+ls

    hs   = '\\hspace{5mm}'

    rIVa = '\\ref{TWINtab:IVAll}'
    rIV2 = '\\ref{TWINtab:IVTwoplus}'
    rIV3 = '\\ref{TWINtab:IVThreeplus}'
    rIV4 = '\\ref{TWINtab:IVFourplus}'
    rIV5 = '\\ref{TWINtab:IVFiveplus}'
    rTwi = '\\label{TWINtab:twinreg1}'
    rSuS = '\\ref{TWINtab:sumstats}'
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
    twid = ['','','','','','','','','','','','']
    tcm  = ['','','','','','','','','','','','']
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
    lA2  = '\n'
    hs   = ''

    rIVa = '5'
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
#== (2) Function to return fertility beta and SE for IV tables
#==============================================================================
def plustable(ffile,n1,n2,searchterm,alt,n3,mult):
    beta = []
    se   = []
    N    = []
    R    = []
    FF   = []
    Fp   = []
    
    f = open(ffile, 'r').readlines()

    for i, line in enumerate(f):
        if re.match(searchterm, line):
            beta.append(i)
            se.append(i+1)
        if re.match("N", line):
            N.append(i)
        if re.match("r2", line):
            R.append(i)
        if re.match("KPF", line):
            FF.append(i)
        if re.match("KPp", line):
            Fp.append(i)
    
    TB = []
    TS = []
    TN = []
    TR = []
    FSF = []
    FSp = []    
    
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

    n1=n1+(mult-1)*4
    n2=n2+(mult-1)*4
    for n in N:
        TN.append(f[n].split()[n1:n2])
    for n in R:
        TR.append(f[n].split()[n1:n2])
    for n in FF:
        FSF.append(f[n].split()[n1:n2])
    for n in Fp:
        FSp.append(f[n].split()[n1:n2])

    return TB, TS, TN, TR, FSF, FSp

def olstable(ffile,n1,n2,n3,ofile):
    beta    = []
    se      = []
    N       = []
    R       = []
    Altonji = []
    Oster   = []
    
    f = open(ffile, 'r').readlines()
    if ofile!="N":
        o = open(ofile, 'r').readlines()
    
    for i, line in enumerate(f):
        if re.match("fert", line):
            beta.append(i)
            se.append(i+1)
        if re.match("N", line):
            N.append(i)
        if re.match("Observations", line):
            N.append(i)
        if re.match("r2", line):
            R.append(i)
        if re.match("R-squared", line):
            R.append(i)
        if re.match("Oster", line):
            Oster.append(i)

    TB = []
    TS = []
    TN = []
    TR = []
    TO = []
    
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
    if ofile=="N":
        for n in Oster:
            TO.append(f[n].split('\t')[n1:n2])
        ost   = '&'.join(TO[0])
    else:
        ost   = o[n3-1].replace(",","&")

    betas = '&'.join(TB[0])
    ses   = '&'.join(TS[0])
    Ns    = '&'.join(TN[0])
    Rs    = '&'.join(TR[0])    
    
    A1 = float(re.search("-\d*\.\d*", TB[0][0]).group(0))
    A2 = float(re.search("-\d*\.\d*", TB[0][1]).group(0))
    A3 = float(re.search("-\d*\.\d*", TB[0][2]).group(0))
    AR1 = str(round(A2/(A1-A2), 3))
    AR2 = str(round(A3/(A1-A3), 3))
    Alts  = '&&'+AR1+'&'+AR2
    #Osts  = '&&'+ost

    return betas, ses, Ns, Rs, Alts, ost, 

#==============================================================================
#== (3) OLS only table
#==============================================================================
os.chdir(Results+'OLS/')

TBa, TSa, TNa, TRa, A1a, A2a = olstable(ols, 1, 4, 1, ost)
TBl, TSl, TNl, TRl, A1l, A2l = olstable(ols, 5, 8, 2, ost)
TBm, TSm, TNm, TRm, A1m, A2m = olstable(ols, 9, 12,3, ost)

OLSf = open(Tables+'OLS_bounds.'+end, 'w')
OLSf.write("\\begin{table}[!htbp] \\centering \n"
           "\\caption{Pooled OLS Estimates of the Q-Q Trade-off (Developing Countries)} \n "
           "\\label{TWINtab:OLS} \n"
           "\\begin{tabular}{lccc} \\toprule \n"
           "& (1) & (2) & (3) \\\\  \n "
           "& Base & +H & + S\&H \\\\ \\midrule \n ")

OLSf.write("\\textbf{Panel A: All Countries}&&& \\\\ \n"
           "Fertility&"+TBa+"\\\\ \n"
           "&"+TSa+"\\\\ \n"
           "&&& \\\\ \n"
           "Observations &"+TNa+"\\\\ \n"
           "R-squared &"+TRa+"\\\\ \n"           
           "Altonji et al.\ Ratio"+A1a+"\\\\ \n"
           "Oster Ratio&&"+A2a+"\\\\ \\midrule \n")
OLSf.write("\\textbf{Panel B: Low Income}&&& \\\\ \n"
           "Fertility&"+TBl+"\\\\ \n"
           "&"+TSl+"\\\\ \n"
           "&&& \\\\ \n"
           "Observations &"+TNl+"\\\\ \n"
           "R-squared &"+TRl+"\\\\ \n"           
           "Altonji et al.\ Ratio"+A1l+"\\\\ \n"
           "Oster Ratio&&"+A2l+"\\\\ \\midrule \n")
OLSf.write("\\textbf{Panel C: Middle Income}&&& \\\\ \n"
           "Fertility&"+TBm+"\\\\ \n"
           "&"+TSm+"\\\\ \n"
           "&&& \\\\ \n"
           "Observations &"+TNm+"\\\\ \n"
           "R-squared &"+TRm+"\\\\ \n"           
           "Altonji et al.\ Ratio"+A1m+"\\\\ \n"
           "Oster Ratio&&"+A2m+"\\\\ \n")
OLSf.write("\\midrule \\multicolumn{4}{p{11cm}}{{\\footnotesize         "
           "Base controls consist of child gender, mother's age and age "
           "squared, mother's age at first birth, child age, country,   "
           "and year of birth fixed effects. The +H controls augment    "
           "`Base' to include mother's height and BMI, and +S\&H        "
           "additionally includes a quadratic for mother's education.   "
           "The \\citet{Altonjietal2005} ratio determines how important "
           "unobservable factors must be compared with included         "
           "observables to imply that the true effect of fertilty on    "
           "educational attainment is equal to zero.  The Oster ratio   "
           "extends the Altonji et al.\\ ratio to take into account     "
           "maximum R-squared in the underlying equation.  We defined   "
           "Oster's maximum R-squared as 2 times the observed R-squared."
           " The ratio in each column is with respects to the baseline  "
           "regression in column (1). Standard errors in parentheses are"
           " clustered at the level of the mother.\n" + foot +" }} \\\\")
OLSf.write("\\bottomrule \\end{tabular}\\end{table} \n")

OLSf.close()



#==============================================================================
#== (5b) DHS IV, bounds, and OLS
#==============================================================================
for t in ['All','Girls','Boys','MidIncome','LowIncome']:
    print t
    os.chdir(Results+'OLS')
    DHSa = open(Tables+'DHS-together'+t+'.tex', 'w')

    fn = t+'.txt'
    if t=="All":       tn=''
    if t=="Girls":     tn=' (Girls Only)'
    if t=="Boys":      tn=' (Boys Only)'
    if t=="MidIncome": tn=' (Middle Income Countries)'
    if t=="LowIncome": tn=' (Low Income Countries)'
    
    TB2, TS2, TN2, TR2, Al2, Os2 = olstable(fn, 1, 4, 1,"N")
    TB3, TS3, TN3, TR3, Al3, Os3 = olstable(fn, 5, 8, 2,"N")
    TB4, TS4, TN4, TR4, Al4, Os4 = olstable(fn, 9, 12, 3, "N")
    print Os2
    DHSa.write('\\begin{landscape}\\begin{table}[htpb!] \n'
               '\\caption{Developing Country Estimates: OLS, Bounds, and IV'+tn+'}'
               '\\label{TWINtab:DHSall}\n'
               '\\begin{center}\\begin{tabular}{lccccccccc}\n'
               '\\toprule \\toprule\n' 
               '&\\multicolumn{3}{c}{2+}&\\multicolumn{3}{c}{3+}&'
               '\\multicolumn{3}{c}{4+}\\\\ \\cmidrule(r){2-4}'
               '\\cmidrule(r){5-7} \\cmidrule(r){8-10}\n' 
               '&Base&+H&+S\\&H&Base&+H&+S\\&H&Base&+H&+S\\&H\\\\ \\midrule\n')
    DHSa.write('\\multicolumn{10}{l}{\\textsc{Panel A: OLS Results}}\\\\'
               "Fertility&"           +TB2+"&"+TB3+"&"+TB4+"\\\\ \n"
               "&"                    +TS2+"&"+TS3+"&"+TS4+"\\\\ \n"
               "&&&&&&&&& \\\\ \n"
               "Observations &"       +TN2+"&"+TN3+"&"+TN4+"\\\\ \n"
               "R-squared &"          +TR2+"&"+TR3+"&"+TR4+"\\\\ \n"
               "Altonji et al.\ Ratio"+Al2+Al3+Al4+"\\\\ \n"
               "Oster Ratio &"        +Os2+"&"+Os3+"&"+Os4+"\\\\ \\midrule \n")

    os.chdir(Results+'IV')
    AllB = []
    AllS = []
    AllN = []
    AllR = []
    for num in [2,6,10]:
        BB, BS, BN, BR,xx,yy = plustable(fn, num, num+3,'fert','normal',1000,1)
    
        AllB.append(dd + BB[0][0] + dd + BB[0][1] + dd + BB[0][2])
        AllS.append(dd + BS[0][0] + dd + BS[0][1] + dd + BS[0][2])
        AllN.append(dd + BN[0][0] + dd + BN[0][1] + dd + BN[0][2])
        AllR.append(dd + BR[0][0] + dd + BR[0][1] + dd + BR[0][2])

    DHSa.write('\\multicolumn{10}{l}{\\textsc{Panel B: IV Results}}\\\\'
               "Fertility"           +AllB[0]+AllB[1]+AllB[2]+"\\\\ \n"
               ""                    +AllS[0]+AllS[1]+AllS[2]+"\\\\ \n"
               "&&&&&&&&& \\\\ \n"
               "Observations "        +AllN[0]+AllN[1]+AllN[2]+"\\\\ \n"
               "R-Squared "           +AllR[0]+AllR[1]+AllR[2]+"\\\\ "
               "\\midrule \n")

    AllB = []
    AllS = []
    AllN = []
    AllF = []
    Allp = []
    m=1
    fn = t+'_first.txt'
    for num in ['two','three','four']:
        search = 'twin\_'+num+'\_fam'
        FB,FS,FN,FR,FF,Fp = plustable(fn, 1, 4,search,'normal',1000,m)
        m = m+1
        AllB.append(dd + FB[0][0] + dd + FB[0][1] + dd + FB[0][2])
        AllS.append(dd + FS[0][0] + dd + FS[0][1] + dd + FS[0][2])
        AllN.append(dd + FN[0][0] + dd + FN[0][1] + dd + FN[0][2])
        AllF.append(dd + FF[0][0] + dd + FF[0][1] + dd + FF[0][2])
        Allp.append(dd + Fp[0][0] + dd + Fp[0][1] + dd + Fp[0][2])


    DHSa.write('\\multicolumn{10}{l}{\\textsc{Panel C: First Stage}}\\\\'
               "Twins"               +AllB[0]+AllB[1]+AllB[2]+"\\\\ \n"
               ""                    +AllS[0]+AllS[1]+AllS[2]+"\\\\ \n"
               "&&&&&&&&& \\\\ \n"
               "Observations "        +AllN[0]+AllN[1]+AllN[2]+"\\\\ \n"
               "Kleibergen-Paap rk statistic" +AllF[0]+AllF[1]+AllF[2]+"\\\\ \n"
               "$p$-value of rk statistic" +Allp[0]+Allp[1]+Allp[2]+"\\\\ \n"
               #"R-Squared "           +AllR[0]+AllR[1]+AllR[2]+"\\\\
               "\\midrule \n")

    if t=="All":
        DHSa.write("\\multicolumn{10}{p{21.0cm}}{{\\footnotesize Panels A "
                   "and B present coefficients and standard errors for a r"
                   "egression of fertility on each child's schooling z-sco"
                   "re (using OLS and IV respectively). The two plus subsa"
                   "mple refers to all first born children in families wit"
                   "h at least two births.  Three plus refers to first- an"
                   "d second-borns in families with at least three births,"
                   " and four plus refers to first- to third-borns in fami"
                   "lies with at least four births.  In panel B Each cell "
                   "presents the coefficient of a 2SLS regression where fe"
                   "rtility is instrumented by twinning at birth order two"
                   ", three or four (for 2+, 3+ and 4+ groups respectively"
                   "). Panel C presents the first-stage coefficients of tw"
                   "inning on fertility for each group. Base controls cons"
                   "ist of child age, mother's age, and mother's age at bi"
                   "rth fixed effects plus country and year-of-birth FEs. "
                   "In each case the sample is made up of all children age"
                   "d between 6-18 years from families in the DHS who fulf"
                   "ill 2+ to 4+ requirements. The \\citet{Altonjietal2005}"
                   " ratio determines how important unobservable factors m"
                   "ust be compared with included observables to imply tha"
                   "t the true effect of fertilty on educational attainmen"
                   "t is equal to zero.  The Oster ratio extends the Alton"
                   "ji et al.\\ ratio to take into account maximum R-squar"
                   "ed in the theoretical equation which includes both obs"
                   "ervables and unobservables.  We defined Oster's maximu"
                   "m R-squared as 2 times the observed R-squared. The rat"
                   "io in each column is with respects to the baseline reg"
                   "ression in column (1) and quantifies how important uno"
                   "bservables would have to be compared with observables "
                   "for the true coefficient from OLS regression to be equ"
                   "al to zero. Standard errors are clustered by mother.")
    else:
        DHSa.write("\\multicolumn{10}{p{21.0cm}}{{\\footnotesize Refer to"
                   " notes to table 7 in the paper.")       

    DHSa.write(foot+" \n}} \\\\"
               "\\bottomrule \\end{tabular} \\end{center} \n"
               "\\end{table} \\end{landscape} \n")


"""
#==============================================================================
#== (6) Read in balance table, fix formatting
#==============================================================================
bali = open(Results+bala, 'r').readlines()
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


balo = open(Tables+"BalanceBoth."+end, 'w')
balo.write('\\begin{table}[htpb!]\\centering \n'
           '\\caption{Test of Balance of Observables: Twin versus Non-Twin}\n'
           '\\label{TWINtab:balanceAll} \n'
           '\\begin{tabular}{lccc} \n \\toprule\\toprule'
           '&Twin&Non-Twin&Diff.\\\\ \n'
           '&Family&Family&(Diff. SE)\\\\ \\midrule \n'
           '\\textbf{Panel A: Developing Countries}&&&\\\\ \n')

bali = open(Results+'Balance.tex', 'r').readlines()
for i,line in enumerate(bali):
    l1 = '&'.join(line.split('&')[0:5])+'\\\\'
    l1 = l1.replace('&*','*')
    l2 = '&&&('+line.split('&')[5]+')\\\\'
    l2 = l2.replace('\n','')+'\n'
    if i>0:
        balo.write(l1 +'\n' + l2)

balo.write('\\midrule\n \\textbf{Panel B: USA}&&&\\\\ \n')
bali = open(Results+'NHIS/BalanceAll.txt', 'r').readlines()
for i,line in enumerate(bali):
    l1 = '&'.join(line.split('&')[0:5])+'\\\\'
    l1 = l1.replace('&*','*')
    l1 = l1.replace('&\\\\','\\\\')
    l2 = '&&&('+line.split('&')[5]+')\\\\'
    l2 = l2.replace('\n','')+'\n'
    if i>0:
        balo.write(l1 +'\n' + l2)


balo.write('\\bottomrule\n \\multicolumn{4}{p{11.2cm}}{\\begin{footnotesize}'
           '\\textsc{Notes:} Panel A is estimated from DHS data, and panel B '
           'uses NHIS data.  The first two columns display means, while the  '
           'third column displays the difference and its standard error, esti'
           'mated using a two-tailed t-test. Each t-test is conditional on mo'
           'ther\'s age at birth, and total completed fertility. Education is'
           'measured in years, underweight refers to a BMI$<$18.5, and Infant'
           'mortality is expressed per 1,000 live births.'
           '\\end{footnotesize}} \n'
           '\\end{tabular}\\end{table}')

balo.close()

#==============================================================================
#== (7a) Read in twin predict table, LaTeX format
#==============================================================================
ii = 1
for twintab in [twin, twiP]:
    if ii==1:
        Tname = ''
        Ttype = ''
        Tlab  = 'TWINtab:TwinDHS'
    if ii==2:
        Tname = 'Probit'
        Ttype = '(Probit)'
        Tlab  = 'TWINtab:TwinDHSProbit'

    twini = open(Results+"Twin/"+twintab, 'r')
    twino = open(Tables+"TwinReg"+Tname+"."+end, 'w')

    if ftype=='tex':
        twino.write("\\begin{landscape}\\begin{table}[htpb!] \n"
        "\\caption{Probability of Giving Birth to Twins "+ Ttype + "}"
        "\\label{" + Tlab + "}\n"
        "\\begin{center}\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
        +dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
        "Twin*100"+dd+"All"+dd+"\\multicolumn{2}{c}{Income}"+dd+
        "\\multicolumn{2}{c}{Time}"+dd+"Prenatal"+ls+"\n "
        "\\cmidrule(r){3-4} \\cmidrule(r){5-6} \n"
        +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr
        +"\n\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+dd+
        "\\begin{footnotesize}\\end{footnotesize}"+ls+"\n")
    elif ftype=='csv':
        twino.write(dd+"(1);(2);(3);(4);(5);(6)"+ls+"\n"
        "Twin*100"+dd+"All;Income;;Time;;Prenatal"+ls+"\n"
        +dd+dd+"Low inc;Middle inc;1990-2013;1972-1989"+dd+ls+mr+"\n\n")

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
            line = line.replace("Notes:",hr+hr+ 
            "\\multicolumn{7}{p{14.3cm}}{\\begin{footnotesize}\\textsc{Notes:}")
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
    ii = ii+1

#==============================================================================
#== (8) Read in summary stats, LaTeX format
#==============================================================================
counti = open(Results+"Summary/"+coun, 'r')

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

summi = open(Results+"Summary/"+summ, 'r')
summc = open(Results+"Summary/"+sumc, 'r')
summf = open(Results+"Summary/"+sumf, 'r')
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

"""
#==============================================================================
#== (9) Create Conley et al. table
#==============================================================================
conli = open(Results+"Conley/"+conl, 'r').readlines()
conlu = open(Results+"NHIS/"+conU, 'r').readlines()
conlo = open(Tables+"Conley."+end, 'w')


if ftype=='tex':
    conlo.write("\\begin{table}[htpb!]\\caption{`Plausibly Exogenous' Bounds} \n"
    "\\label{TWINtab:Conley}\\begin{center}\\begin{tabular}{lcccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{2}{c}{UCI: $\\gamma\\in [0,2\\hat\\gamma]$}"
    "&\\multicolumn{2}{c}{LTZ: $\\gamma \\sim \mathcal{N}(\\mu_{\\hat\\gamma},"
    "\\sigma_{\\hat\\gamma})$}\\\\ \n" 
    "\\cmidrule(r){2-3} \\cmidrule(r){4-5}\n")
elif ftype=='csv':
    conlo.write("UCI:;gamma in [0,delta];LTZ:;gamma ~ N(mu,sigma) \n")

for i,line in enumerate(conli):
    if i<4:
        line = re.sub('\s+', dd, line) 
        line = re.sub('&$', ls+ls, line)
        line = line.replace('Plus', ' Plus')
        line = line.replace('Bound', ' Bound')
        line = line.replace('Bound\\\\', 'Bound\\\\ \\midrule')
        line = line.replace('\\midrule', 
                            '\\midrule \n \\multicolumn{5}{l}{Panel A: DHS}\\\\')
        conlo.write(line + "\n")
    if i==5:
        delta = line.replace('deltas', '')
        delta = re.sub('\s+', ', ', delta) 
        delta = re.sub(', $', '.', delta)
        delta = re.sub('^,', ' ', delta)
conlo.write('&&&& \\\\ \\midrule \\multicolumn{5}{l}{Panel B: USA (Education)}\\\\')
for i,line in enumerate(conlu):
    if i==1 or i==2 or i==3:
        line = re.sub('\s+', dd, line) 
        line = re.sub('&$', ls+ls, line)
        line = line.replace('E',' Plus')
        conlo.write(line + "\n")
conlo.write('&&&& \\\\ \\multicolumn{5}{l}{Panel B: USA (Health)}\\\\')
for i,line in enumerate(conlu):
    if i==4 or i==5 or i==6:
        line = re.sub('\s+', dd, line) 
        line = re.sub('&$', ls+ls, line)
        line = line.replace('H',' Plus')
        conlo.write(line + "\n")
    

conlo.write(mr+mc1+twid[3]+tcm[3]+mc3+
"This table presents upper and lower bounds of a 95\\% confidence interval "
"for the effects of family size on (standardised) children's education "
"attainment. These are estimated by the methodology described in "
"\\citet{Conleyetal2012}  under various priors about the direct effect "
"that being from a twin family has on educational outcomes ("+mi+ "gamma"+
mo+"). In the UCI (union of confidence interval) approach, it is assumed "
"the true "+mi+"gamma\\in[0,2\\hat\\gamma]"+mo+", while in the LTZ (local "
"to zero) approach it is assumed that "+mi+"gamma\sim "
"\mathcal{N}(\\mu_{\\hat\\gamma},\\sigma_{\\hat\\gamma})"+mo+". The "
"consistent estimation of $\\hat\\gamma$ and its entire distribution is "
"discussed in section \\ref{TWINscn:gamma}, and estimates for $\\gamma$ "
"are provided in table \\ref{TWINtab:gamma}.")

if ftype=='tex':
    conlo.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\end{tabular}\\end{center}\\end{table} \n")


conlo.close()
"""
#==============================================================================
#== (10) Create country list table
#==============================================================================
dhssi = open(Results+"Summary/"+dhss, 'r').readlines()
dhsso = open(Tables+"Countries."+end, 'w')

if ftype=='tex':
    dhsso.write("%\\end{spacing}\\begin{spacing}{1} \n"
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
    "\\\\ \\bottomrule \\end{longtable}%\\end{spacing}\\begin{spacing}{1.5}")


dhsso.close()

#==============================================================================
#== (11) Gender table
#==============================================================================
genfi = open(Results+'IV/'+gend[0],'r').readlines
genmi = open(Results+'IV/'+gend[1],'r').readlines

gendo = open(Tables+'Gender.'+end, 'w')


FB, FS, FN = plustable(Results+'IV/'+gend[0],1,13,"fert",'normal',1000)
MB, MS, MN = plustable(Results+'IV/'+gend[1],1,13,"fert",'normal',1000)


Ns = format(float(FN[0][0]), "n")+', '+format(float(MN[0][0]), "n")+', '
Ns = Ns + format(float(FN[0][4]),"n")+', '+format(float(MN[0][4]),"n")+', '
Ns = Ns + format(float(FN[0][8]),"n")+', '+format(float(MN[0][8]),"n")

if ftype=='tex':
    gendo.write("\\begin{table}[htpb!]"
    "\\caption{Q-Q IV Estimates by Gender (Developing Countries)} \n"
    "\\label{TWINtab:gend}\\begin{center}\\begin{tabular}{lcccccccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{4}{c}{Females}""&\\multicolumn{4}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-5} \\cmidrule(r){6-9} \n"
    "&Base&+Health&+H\\&S&Obs.&Base&+Health&+H\\&S&Obs. \\\\ \\midrule \n"+lineadd)
elif ftype=='csv':
    gendo.write(";Females;;;Males;; \n"  
    ";Base;Socioec;Health;Obs.;Base;Socioec;Health;Obs. \n")


gendo.write(
"Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd+format(float(FN[0][0]), "n")+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+dd+format(float(MN[0][0]), "n")+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+dd+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][4]+dd+FB[0][5]+dd+FB[0][6]+dd+format(float(FN[0][4]), "n")+dd
+MB[0][4]+dd+MB[0][5]+dd+MB[0][6]+dd+format(float(MN[0][4]), "n")+ls+'\n'
+dd+FS[0][4]+dd+FS[0][5]+dd+FS[0][6]+dd+dd
+MS[0][4]+dd+MS[0][5]+dd+MS[0][6]+dd+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][8]+dd+FB[0][9]+dd+FB[0][10]+dd+format(float(FN[0][8]), "n")+dd
+MB[0][8]+dd+MB[0][9]+dd+MB[0][10]+dd+format(float(MN[0][8]), "n")+ls+'\n'
+dd+FS[0][8]+dd+FS[0][9]+dd+FS[0][10]+dd+dd
+MS[0][8]+dd+MS[0][9]+dd+MS[0][10]+dd+ls+'\n'
#+ lineadd +
#"Five Plus &"+FB[0][9]+'&'+FB[0][10]+'&'+FB[0][11]+'&'
#+MB[0][9]+'&'+MB[0][10]+'&'+MB[0][11]+'\\\\ \n'
#"&"+FS[0][9]+'&'+FS[0][10]+'&'+FS[0][11]+'&'
#+MS[0][9]+'&'+MS[0][10]+'&'+MS[0][11]+'\\\\ \n' 
+mr+mc1+twid[5]+tcm[5]+mc3+
"Female or male refers to the gender of the index child of the regression. \n"
"All regressions include full controls including socioeconomic and maternal "
"health variables.  The full list of controls are available in the \n"
"notes to table "+rIVa+". Standard errors are clustered by mother."+foot+"\n")
if ftype=='tex':
    gendo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")

gendo.close()


gendo = open(Tables+'GenderUSA.'+end, 'w')

girl = 'IVFertEducationZscoreG2.xls'
boys = 'IVFertEducationZscoreG1.xls'
FB, FS, FN = plustable(Results+'NHIS/Gender/'+girl,1,13,"fert",'normal',1000)
MB, MS, MN = plustable(Results+'NHIS/Gender/'+boys,1,13,"fert",'normal',1000)

if ftype=='tex':
    gendo.write("\\begin{table}[htpb!]"
    "\\caption{Q-Q IV Estimates by Gender (USA)} \n"
    "\\label{TWINtab:gend}\\begin{center}\\begin{tabular}{lcccccccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{4}{c}{Females}""&\\multicolumn{4}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-5} \\cmidrule(r){6-9} \n" 
    "&Base&+Health&+H\\&S&Obs.&Base&+Health&+H\\&S&Obs. \\\\ \\midrule \n"+lineadd)
elif ftype=='csv':
    gendo.write(";Females;;;Males;; \n"  
    ";Base;Socioec;Health;Obs.;Base;Socioec;Health;Obs. \n")

gendo.write('\\multicolumn{6}{l}{\\textbf{Panel A: School Z-Score}}\\\\')

gendo.write(
"Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd+format(float(FN[0][0]), "n")+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+dd+format(float(MN[0][0]), "n")+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+dd+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][4]+dd+FB[0][5]+dd+FB[0][6]+dd+format(float(FN[0][4]), "n")+dd
+MB[0][4]+dd+MB[0][5]+dd+MB[0][6]+dd+format(float(MN[0][4]), "n")+ls+'\n'
+dd+FS[0][4]+dd+FS[0][5]+dd+FS[0][6]+dd+dd
+MS[0][4]+dd+MS[0][5]+dd+MS[0][6]+dd+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][8]+dd+FB[0][9]+dd+FB[0][10]+dd+format(float(FN[0][8]), "n")+dd
+MB[0][8]+dd+MB[0][9]+dd+MB[0][10]+dd+format(float(MN[0][8]), "n")+ls+'\n'
+dd+FS[0][8]+dd+FS[0][9]+dd+FS[0][10]+dd+dd
+MS[0][8]+dd+MS[0][9]+dd+MS[0][10]+dd+ls+'\n')


girl = 'IVFertexcellentHealthG2.xls'
boys = 'IVFertexcellentHealthG1.xls'
FB, FS, FN = plustable(Results+'NHIS/Gender/'+girl,1,13,"fert",'normal',1000)
MB, MS, MN = plustable(Results+'NHIS/Gender/'+boys,1,13,"fert",'normal',1000)

gendo.write('\\multicolumn{6}{l}{\\textbf{Panel B: Child Health}}\\\\')
gendo.write(
"Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd+format(float(FN[0][0]), "n")+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+dd+format(float(MN[0][0]), "n")+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+dd+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][4]+dd+FB[0][5]+dd+FB[0][6]+dd+format(float(FN[0][4]), "n")+dd
+MB[0][4]+dd+MB[0][5]+dd+MB[0][6]+dd+format(float(MN[0][4]), "n")+ls+'\n'
+dd+FS[0][4]+dd+FS[0][5]+dd+FS[0][6]+dd+dd
+MS[0][4]+dd+MS[0][5]+dd+MS[0][6]+dd+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][8]+dd+FB[0][9]+dd+FB[0][10]+dd+format(float(FN[0][8]), "n")+dd
+MB[0][8]+dd+MB[0][9]+dd+MB[0][10]+dd+format(float(MN[0][8]), "n")+ls+'\n'
+dd+FS[0][8]+dd+FS[0][9]+dd+FS[0][10]+dd+dd
+MS[0][8]+dd+MS[0][9]+dd+MS[0][10]+dd+ls+'\n'
+mr+mc1+twid[5]+tcm[5]+mc3+
"Female or male refers to the gender of the index child of the regression. \n"
"All regressions include full controls including socioeconomic and maternal "
"health variables.  The full list of controls are available in the \n"
    "notes to table \\ref{TWINtab:NHISIV}. Standard errors are clustered by mother."
+foot+"\n")
if ftype=='tex':
    gendo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")



gendo.close()


#==============================================================================
#== (12) IMR Test table
#==============================================================================
#imrti = open(Results+"New/"+imrt, 'r').readlines()
imrti = open(Results+"IMRTest.txt", 'r').readlines()
imrto = open(Tables+"IMRtest."+end, 'w')

if ftype=='tex':
    imrto.write("\\begin{table}[htpb!]\n"
    "\\caption{Test of hypothesis that women who bear twins have better prior health}"
                "\\label{TWINtab:IMR}\\begin{center}\\begin{tabular}{lcccc}\n"
    "\\toprule \\toprule \n"
    "\\textsc{Infant Mortality (per 100 births)}& Base & +H & +S\\&H & Mean \\\\ \\midrule \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
for i,line in enumerate(imrti):
    if re.match("treated", line):
        index=i
    if re.match("N", line):
        ind2=i
        
betas = imrti[index].split()
ses   = imrti[index+1].split()
print betas

imrto.write('Treated (2+)'+hs*6+dd+betas[1]+dd+betas[2]+dd+betas[3]+"&9.758"+ls+'\n'
+dd+ses[0]+dd+ses[1]+dd+ses[2]+dd+ls+'\n'
'Treated (3+)'+hs+dd+betas[5]+dd+betas[6]+dd+betas[7]+"&10.157"+ls+'\n'
+dd+ses[4]+dd+ses[5]+dd+ses[6]+dd+ls+'\n'
'Treated (4+)'+dd+betas[9]+dd+betas[10]+dd+betas[11]+"&10.827"+ls+'\n'
+dd+ses[8]+dd+ses[9]+dd+ses[10]+dd+ls+'\n'
'\n'+mr+mc1+twid[6]+tcm[6]+mc3+
"The sample for these regressions consist of all children who have been entirely "
"exposed to the risk of infant mortality (ie those over 1 year of age). "
"Subsamples 2+, 3+, and 4+ are generated to allow comparison of children "
"born at similar birth orders.  For a full description of these groups see the "
"the body of the paper or notes to table 7. Treated=1 refers to children "
"who are born before a twin while Treated=0 refers to children of similar birth "
"orders not born before a twin.  Base, + and +S\&H controls are     "
"described in table 7"+foot+" \n")
if ftype=='tex':
    imrto.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")


#==============================================================================
#== (14) First stage table
#==============================================================================
fstao = open(Tables+"firstStage."+end, 'w')

os.chdir(Results+'IV')

if ftype=='tex':
    fstao.write("\\begin{landscape}\\begin{table}[htpb!]"
    "\\caption{First Stage Results} \n"
    "\\label{TWINtab:FS}\\begin{center}"
    "\\begin{tabular}{lcccp{2mm}cccp{2mm}ccc}\n\\toprule \\toprule \n"
    "&\\multicolumn{3}{c}{2+}&&\\multicolumn{3}{c}{3+}&&\\multicolumn{3}{c}{4+}"
    "\\\\ \\cmidrule(r){2-4} \\cmidrule(r){6-8} \\cmidrule(r){10-12} \n"
    "\\textsc{Fertility}&Base&+H&+S\&H&&Base&+H&+S\&H&&Base&+H&+S\&H"
    "\\\\ \\midrule \n"
    +"\\begin{footnotesize}\\end{footnotesize}& \n"*9+
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
elif ftype=='csv':
    fstao.write(";2+;;;;3+;;;;4+;;;\n"
    "FERTILITY;Base;+H;+S&H;;Base;+H;+S&H;;Base;+S;+S&H \n")

AllB = []
AllS = []
AllN = []
LowB = []
LowS = []
LowN = []
MidB = []
MidS = []
MidN = []
TwiB = []
TwiS = []
TwiN = []
AdjB = []
AdjS = []
AdjN = []

for num in ['two','three','four']:
    searcher='twin\_'+num+'\_fam'
    Asearcher='ADJtwin\_'+num+'\_fam'
    searchup=searcher+'|twin'+num
    if num=='two':
        N = 0
    elif num=='three':
        N = 4
    else:
        N = 8

    FSB, FSS, FSN    = plustable(firs, 1, 13,searcher,'normal',1000)
    FLB, FLS, FLN    = plustable(flow, 1, 13,searcher,'normal',1000)
    FMB, FMS, FMN    = plustable(fmid, 1, 13,searcher,'normal',1000)
    FMB, FMS, FMN    = plustable(fmid, 1, 13,searcher,'normal',1000)
    FTB, FTS, FTN    = plustable(ftwi, 1, 13,searcher,'normal',1000)
    FAB, FAS, FAN    = plustable(fadj, 1, 13,searcher,'normal',1000)


    AllB.append(dd + FSB[0][0] + dd + FSB[0][1] + dd + FSB[0][2])
    AllS.append(dd + FSS[0][0] + dd + FSS[0][1] + dd + FSS[0][2])
    AllN.append(dd + FSN[0][N] + dd + FSN[0][N+1] + dd + FSN[0][N+2])
    LowB.append(dd + FLB[0][0] + dd + FLB[0][1] + dd + FLB[0][2])
    LowS.append(dd + FLS[0][0] + dd + FLS[0][1] + dd + FLS[0][2])
    LowN.append(dd + FLN[0][N] + dd + FLN[0][N+1] + dd + FLN[0][N+2])
    MidB.append(dd + FMB[0][0] + dd + FMB[0][1] + dd + FMB[0][2])
    MidS.append(dd + FMS[0][0] + dd + FMS[0][1] + dd + FMS[0][2])
    MidN.append(dd + FMN[0][N] + dd + FMN[0][N+1] + dd + FMN[0][N+2])
    AdjB.append(dd + FAB[0][0] + dd + FAB[0][1] + dd + FAB[0][2])
    AdjS.append(dd + FAS[0][0] + dd + FAS[0][1] + dd + FAS[0][2])
    AdjN.append(dd + FAN[0][N] + dd + FAN[0][N+1] + dd + FAN[0][N+2])
    TwiB.append(dd + FTB[0][0] + dd + FTB[0][1] + dd + FTB[0][2])
    TwiS.append(dd + FTS[0][0] + dd + FTS[0][1] + dd + FTS[0][2])
    TwiN.append(dd + FTN[0][N] + dd + FTN[0][N+1] + dd + FTN[0][N+2])



fstao.write(mc1+twid[10]+mcbf+"All"+mc2+ls+" \n"
"Twin"+AllB[0]+dd+AllB[1]+dd+AllB[2]+ls+'\n'
+AllS[0]+dd+AllS[1]+dd+AllS[2]+ls+'\n'+lA2+
"Observations"+AllN[0]+dd+AllN[1]+dd+AllN[2]+ls+'\n'+lA2+

mc1+twid[10]+mcbf+"Low-Income"+mc2+ls+" \n"
"Twin"+LowB[0]+dd+LowB[1]+dd+LowB[2]+ls+'\n'
+LowS[0]+dd+LowS[1]+dd+LowS[2]+ls+'\n'+lA2+
"Observations"+LowN[0]+dd+LowN[1]+dd+LowN[2]+ls+'\n'+lA2+

mc1+twid[10]+mcbf+"Middle-Income"+mc2+ls+" \n"
"Twin"+MidB[0]+dd+MidB[1]+dd+MidB[2]+ls+'\n'
+MidS[0]+dd+MidS[1]+dd+MidS[2]+ls+'\n'+lA2+
"Observations"+MidN[0]+dd+MidN[1]+dd+MidN[2]+ls+'\n')
#+lA2+

#mc1+twid[10]+mcbf+"Adjusted Fertility"+mc2+ls+" \n"
#"Twin"+AdjB[0]+dd+AdjB[1]+dd+AdjB[2]+ls+'\n'
#+AdjS[0]+dd+AdjS[1]+dd+AdjS[2]+ls+'\n'+lA2+
#"Observations"+AdjN[0]+dd+AdjN[1]+dd+AdjN[2]+ls+'\n'+lA2+

#mc1+twid[10]+mcbf+"Twins and Pre-Twins"+mc2+ls+" \n"
#"Twin"+TwiB[0]+dd+TwiB[1]+dd+TwiB[2]+ls+'\n'
#+TwiS[0]+dd+TwiS[1]+dd+TwiS[2]+ls+'\n'+lA2+
#"Observations"+TwiN[0]+dd+TwiN[1]+dd+TwiN[2]+ls+'\n')

fstao.write('\n'+mr+mc1+twid[12]+tcm[12]+mc3+
"Each cell represents the coefficient from the first-stage of a two-stage "
"regression.  The first-stage represents the effect of twinning at parity "
"$N$ on total fertility where $N$ is 2, 3 or 4 for 2+, 3+ and 4+ groups "
"respectively.  The 2+ group includes all first borns in families with at "
"least 2 births, the 3+ group includes first and second borns in families "
"with at least 3 births, and the 4+ group includes all first to third borns "
"in families with at least four births.  In each regressions the sample is "
"made up of all children aged between 6-18 years from families in the DHS who "
"fulfill these birth order conditions.  Controls in each case are "
"identical to those described in table "+rIVa+".  Standard "
"errors are clustered at the level of the mother."+foot+" \n")
if ftype=='tex':
    fstao.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")


#==============================================================================
#== (14) Gender full IV
#==============================================================================
genio = open(Tables+'GenderIV.'+end, 'w')

AllB = []
AllS = []
AllN = []
LowB = []
LowS = []
LowN = []
MidB = []
MidS = []
MidN = []
TwiB = []
TwiS = []
TwiN = []
AdjB = []
AdjS = []
AdjN = []

FirB = []
FirS = []
AFiB = []
AFiS = []

for gg in [0,1]:
    BB, BS, BN    = plustable(gend[gg], 1, 10,'fert','normal',1000)
    LB, LS, LN    = plustable(genl[gg], 1, 10,'fert','normal',1000)
    MB, MS, MN    = plustable(genm[gg], 1, 10,'fert','normal',1000)
    TB, TS, TN    = plustable(gent[gg], 1, 10,'fert','normal',1000)
    AB, AS, AN    = plustable(gena[gg], 1, 10,'ADJfert','normal',1000)
    
    AllB.append(dd + BB[0][2] + dd + BB[0][5] + dd + BB[0][8])
    AllS.append(dd + BS[0][2] + dd + BS[0][5] + dd + BS[0][8])
    AllN.append(dd + BN[0][2] + dd + BN[0][5] + dd + BN[0][8])
    LowB.append(dd + LB[0][2] + dd + LB[0][5] + dd + LB[0][8])
    LowS.append(dd + LS[0][2] + dd + LS[0][5] + dd + LS[0][8])
    LowN.append(dd + LN[0][2] + dd + LN[0][5] + dd + LN[0][8])
    MidB.append(dd + MB[0][2] + dd + MB[0][5] + dd + MB[0][8])
    MidS.append(dd + MS[0][2] + dd + MS[0][5] + dd + MS[0][8])
    MidN.append(dd + MN[0][2] + dd + MN[0][5] + dd + MN[0][8])
    TwiB.append(dd + TB[0][2] + dd + TB[0][5] + dd + TB[0][8])
    TwiS.append(dd + TS[0][2] + dd + TS[0][5] + dd + TS[0][8])
    TwiN.append(dd + TN[0][2] + dd + TN[0][5] + dd + TN[0][8])
    AdjB.append(dd + AB[0][2] + dd + AB[0][5] + dd + AB[0][8])
    AdjS.append(dd + AS[0][2] + dd + AS[0][5] + dd + AS[0][8])
    AdjN.append(dd + AN[0][2] + dd + AN[0][5] + dd + AN[0][8])

    for num in ['two','three','four']:
        searcher='twin\_'+num+'\_fam'
        Asearcher='ADJtwin\_'+num+'\_fam'

        FSB, FSS, FSN    = plustable(fgen[gg], 1, 4,searcher,'normal',1000)
        FAB, FAS, FAN    = plustable(fgna[gg], 1, 4,searcher,'normal',1000)


        FirB.append(dd + FSB[0][2])
        FirS.append(dd + FSS[0][2])
        AFiB.append(dd + FAB[0][2])
        AFiS.append(dd + FAS[0][2])


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
genio.write(dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All"+mc2+ls+" \n"
"Fertility"+AllB[0]+AllB[1]+ls+"\n"
""         +AllS[0]+AllS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Low-Income Countries"+mc2+ls+" \n"
"Fertility"+LowB[0]+LowB[1]+ls+"\n"
""         +LowS[0]+LowS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Middle-Income Countries"+mc2+ls+" \n"
"Fertility"+MidB[0]+MidB[1]+ls+"\n"
""         +MidS[0]+MidS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Adjusted Fertility"+mc2+ls+" \n"
"Fertility"+AdjB[0]+AdjB[1]+ls+"\n"
""         +AdjS[0]+AdjS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Twins and Pre-Twins"+mc2+ls+" \n"
"Fertility"+TwiB[0]+TwiB[1]+ls+"\n"
""         +TwiS[0]+TwiS[1]+ls+ "\n"+mr

+mc1+twid[0]+mcsc+"First Stage"+mc2+ls+" \n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All"+mc2+ls+" \n"
"Twin"+FirB[0]+FirB[1]+FirB[2]+FirB[3]+FirB[4]+FirB[5]+ls+"\n"
""         +FirS[0]+FirS[1]+FirS[2]+FirS[3]+FirS[4]+FirS[5]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Adjusted Fertility"+mc2+ls+" \n"
"Twin"+AFiB[0]+AFiB[1]+AFiB[2]+AFiB[3]+AFiB[4]+AFiB[5]+ls+"\n"
""         +AFiS[0]+AFiS[1]+AFiS[2]+AFiS[3]+AFiS[4]+AFiS[5]+ls+ "\n"

+'\n'+mr+mc1+twid[9]+tcm[9]+mc3+
"Each cell presents the coefficient from a 2SLS regression of standardised "
"educational attainment on fertility.  2+, 3+ and 4+ refer to the birth "
"orders of children included in the regression.  For a full description of "
"these groups see table "+rIVa+".  Each regression includes full controls "
"including maternal health and socioeconomic variables.  The sample is made "
"up of all children aged between 6-18 years from families in the DHS who "
"fulfill birth order and gender requirements indicated in the header.  "
"Standard errors are clustered by mother."
+foot+" \n")

if ftype=='tex':
    genio.write("\\end{footnotesize}}\n"+ls+br+
    "\\normalsize\\end{tabular}\\end{table} \n")
genio.close()

#==============================================================================
#== (15) Sample table
#==============================================================================
sampi = open(Results+"Summary/"+samp, 'r')
sampo = open(Tables+'Samples.'+end, 'w')

if ftype=='tex':
    sampo.write("\\begin{table}[!htbp] \\centering \n"
    "\\caption{Estimation Samples} \n "
    "\\label{TWINtab:Samples} \n"
    "\\begin{tabular}{lccccc} \\toprule \\toprule \n")


for i,line in enumerate(sampi):
    line = re.sub('&', dd, line) 
    line = re.sub('allsample','All', line)
    line = re.sub('hhsample','Household', line)
    line = re.sub('twopsample',  '2+', line)
    line = re.sub('threepsample','3+', line)
    line = re.sub('fourpsample', '4+', line)
    line = re.sub('fivepsample', '5+', line)
    if i==0:
        sampo.write(line + ls + mr + "\n")
    else:
        sampo.write(line + ls + "\n")


sampo.write('\n'+mr+mc1+twid[11]+tcm[11]+mc3+
"Full summary statistics are provided in table " +rSuS+ ".")

if ftype=='tex':
    sampo.write("\\end{footnotesize}}\\\\  \n"
    "\\bottomrule \\normalsize\\end{tabular}\\end{table} \n")

sampo.close()

"""
#==============================================================================
#== (16) Gamma table
#==============================================================================
gammi = open(Results+"../gamma/"+gamT, 'r')
gammn = open(Results+"../gamma/"+gamN, 'r')
gammo = open(Tables+'gamma.'+end, 'w')

if ftype=='tex':
    gammo.write("\\begin{table}[!htbp] \\begin{center} \n"
    "\\caption{Estimates of $\\gamma$ Using Maternal Health Shocks}\n "
    "\\label{TWINtab:gamma} \n"
    "\\begin{tabular}{lcccc} \\toprule \\toprule \n"
    "&$\\frac{\\partial Educ}{\\partial Health}$ "
    "&$\\frac{\\partial Health}{\\partial Twin}$ "
    "&$\\gamma=\\frac{\\partial Educ}{\\partial Twin}$" 
    "&$\\gamma$ (bootstrap) \\\\ \\midrule \n")


for i,line in enumerate(gammi):
    if i==3: EstA = line.split()[1]
    if i==4: SeA  = line.split()[0]
    if i==5: EstB = line.split()[1]
    if i==6: SeB  = line.split()[0]
    if i==10: obs = line.replace('\t','&')
    if i==11: rsq = line.replace('\t','&')
for i,line in enumerate(gammn):
    if i==3: EstAN= line.split()[1]
    if i==4: SeAN = line.split()[0]
    if i==5: EstBN= line.split()[1]
    if i==6: SeBN = line.split()[0]
    if i==10: obsN= line.replace('\t','&')
    if i==11: rsqN= line.replace('\t','&')


gammaEst  = str(float(EstA[0:6])*abs(float(EstB[0:6])))[0:6]
gammaEstN = str(float(EstAN[0:6])*(float(EstBN[0:6])))[0:6]

gammo.write('\\textbf{Panel A: United States} &&&& \\\\ \n'
            'Estimate &-'+EstA+'&'+EstB+'&'+gammaEst+'&'+gammaEst+'\\\\ \n'
            '&'+SeA+'&'+SeA+'&&(0.0027)\\\\  \n'
            '&&&&\\\\ \n'+obs+'&&\\\\ \n'+rsq+'&&\\\\ \\midrule')
gammo.write('\\textbf{Panel B: Nigeria} &&&& \\\\ \n'
            'Estimate &'+EstAN+'&'+EstBN+'&'+gammaEstN+'&'+gammaEstN+'\\\\ \n'
            '&'+SeAN+'&'+SeAN+'&&(0.0022)\\\\  \n'
            '&&&&\\\\ \n'+obsN+'&&\\\\ \n'+rsqN+'&&\\\\ \n')

gammo.write('\n'+mr+mc1+twid[13]+tcm[13]+mc3+
"Regression results for panel A use the 5\% sample of 1980 US census data and "
"follow the specifications in \\citet{BhalotraVenkataramani2014}. Regression  "
"results from panel B are based on all Nigerian DHS data in which children can"
" be linked to their mothers.  Specifications and samples are identical to    "
" those described in \\citet{Akreshetal2012}. The estimate of $\gamma$ is     "
"formed by taking the product of the column 1 and column 2 estimates.  A full "
"description of this process, along with the non-pivotal bootstrap process to "
"estimate the standard error of $\\gamma$ is provided in section              "
"\\ref{TWINscn:gamma}, and online appendix D.")

if ftype=='tex':
    gammo.write("\\end{footnotesize}}\\\\  \n"
    "\\bottomrule\\end{tabular}\\end{center}\\end{table} \n")

gammo.close()
"""
#==============================================================================
#== (17) NHIS Results
#==============================================================================
NHISo = open(Tables+'NHISols.'+end, 'w')
NHISf = open(Tables+'NHIS_fs.'+end, 'w')
NHISi = open(Tables+'NHIS_iv.'+end, 'w')

if ftype=='tex':
    NHISo.write('\\begin{landscape}\\begin{table}[htpb!] \n'
                '\\caption{OLS Estimates of the Q--Q Trade-off (USA)}'
                '\\label{TWINtab:NHISOLS}\n'
                '\\begin{center}\\begin{tabular}{lccc}\n'
                '\\toprule \\toprule\n' 
                '&Base & + & + Health \\\\'
                '&Controls& Health &\&Socioec \\\\ \\midrule \n'
                +tsc+'Panel A: Education \\ \\ \\ '+ebr+dd+dd+dd+ls+'\n')

wT = open(Results+"NHIS/OLSAllEducationZscore.xls", 'r')
for i, line in enumerate(wT):
    if i==8 or i==9:   
        #if i==8:
            #print 
            #A1 = float(re.search("-\d*\.\d*", line.split('\t')[1]).group(0))
            #A2 = float(re.search("-\d*\.\d*", line.split('\t')[2]).group(0))
            #A3 = float(re.search("-\d*\.\d*", line.split('\t')[3]).group(0))
            #AR1 = str(round(A2/(A1-A2), 3))
            #AR2 = str(round(A3/(A1-A3), 3))
        line = line.replace('fert','Fertility')
        line = line.replace('\t', '&')
        NHISo.write(line+'\\\\ \n')
    if i==34 or i==35:   
        line = line.replace('r2','R$^2$')
        line = line.replace('N','Observations')
        line = line.replace('\t', '&')
        NHISo.write(line+'\\\\ \n')

NHISo.write(tsc+'Panel B: Health'+ebr+dd+dd+dd+ls+'\n')
wT = open(Results+"NHIS/OLSAllexcellentHealth.xls", 'r')
for i, line in enumerate(wT):
    if i==8 or i==9:   
        line = line.replace('fert','Fertility')
        line = line.replace('\t', '&')
        NHISo.write(line+'\\\\ \n')
    if i==34 or i==35:   
        line = line.replace('r2','R$^2$')
        line = line.replace('N','Observations')
        line = line.replace('\t', '&')
        NHISo.write(line+'\\\\ \n')
    
NHISo.write('\n'+mr+mc1+twid[2]+tcm[2]+mc3+
"Each cell presents the coefficient of interest from a regression "
"using NHIS survey data (2004-2014).  Base controls include child "
"age FE (in months), mother's age, and mother's age at first birth" 
" plus race dummies for child and mother. Educational measures are"
" available for all children aged between 6-18 years, and health  "
"measures are available for all children. Descriptive statistics  "
"for each variable can be found in table \\ref{TWINtab:NHISstats}."
" Standard errors are clustered by mother.")

if ftype=='tex':
    NHISo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
                "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")
NHISo.close()


NHISi.write('\\begin{landscape}\\begin{table}[htpb!] \n'
            '\\caption{IV Estimates of the Q--Q Trade-off (USA)}'
            '\\label{TWINtab:NHISIV}\n'
            '\\begin{center}\\begin{tabular}{lccccccccc}\n'
            '\\toprule \\toprule\n' 
            '&\\multicolumn{3}{c}{2+}&\\multicolumn{3}{c}{3+}&'
            '\\multicolumn{3}{c}{4+}\\\\ \\cmidrule(r){2-4}'
            '\\cmidrule(r){5-7} \\cmidrule(r){8-10}\n' 
            '&Base&+H&+S\\&H&Base&+H&+S\\&H&Base&+H&+S\\&H\\\\ \\midrule\n' 
            +'\\begin{footnotesize}\\end{footnotesize}&'*9+
            '\\begin{footnotesize}\\end{footnotesize}\\\\' 
            '\\multicolumn{10}{l}{\\textsc{Panel A: Education Z-Score}}\\\\')
wT = open(Results+"NHIS/IVFertEducationZscore.xls", 'r')
for i, line in enumerate(wT):
    if i==2 or i==3:
        line = line.replace('fert','Fertility')
        line = line.replace('\t', '&')
        NHISi.write(line+'\\\\ \n')
    if i==35:
        line = line.replace('N','Observations')
        line = line.replace('\t', '&')
        NHISi.write(line+'\\\\ \n')

NHISi.write(tsc+'Panel B: Health'+ebr+dd+dd+dd+dd+dd+dd+dd+dd+dd+ls+'\n')
wT = open(Results+"NHIS/IVFertexcellentHealth.xls", 'r')
for i, line in enumerate(wT):
    if i==2 or i==3:
        line = line.replace('fert','Fertility')
        line = line.replace('\t', '&')
        NHISi.write(line+'\\\\ \n')
    if i==35:
        line = line.replace('N','Observations')
        line = line.replace('\t', '&')
        NHISi.write(line+'\\\\ \n')

NHISi.write('\n'+mr+mc1+twid[14]+tcm[14]+mc3+
"Each cell presents the coefficient of interest from a regression "
"using NHIS survey data (2004-2014).  Base controls include child "
"age FE (in months), mother's age, and mother's age at first birth"
" plus race dummies for child and mother. Educational measures are"
" available for all children aged between 6-18 years, and health  "
"measures are available for all children. Descriptive statistics  "
"for each variable can be found in table \\ref{TWINtab:NHISstats}."
" Standard errors are clustered by mother.")
if ftype=='tex':
    NHISi.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
                "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")

NHISi.close()


NHISf.write('\\begin{landscape}\\begin{table}[htpb!] \n'
            '\\caption{First Stage Estimates Twins and Fertility (USA)}'
            '\\label{TWINtab:NHISFS}\n'
            '\\begin{center}\\begin{tabular}{lccccccccc}\n'
            '\\toprule \\toprule\n' 
            '&\\multicolumn{3}{c}{2+}&\\multicolumn{3}{c}{3+}&'
            '\\multicolumn{3}{c}{4+}\\\\ \\cmidrule(r){2-4}'
            '\\cmidrule(r){5-7} \\cmidrule(r){8-10}\n' 
            '&Base&+H&+S\\&H&Base&+H&+S\\&H&Base&+H&+S\\&H\\\\ \\midrule\n' 
            +'\\begin{footnotesize}\\end{footnotesize}&'*9+
            '\\begin{footnotesize}\\end{footnotesize}\\\\' 
            '\\multicolumn{10}{l}{\\textsc{Panel A: Education Sample}}\\\\')
for ttab in ['EducationZscore','excellentHealth']:
    wT = open(Results+'NHIS/IVFert'+ttab+'1.xls', 'r')
    for i, line in enumerate(wT):
        if i==2:
            line = line.replace('twin_two_fam','Twin')
            line = line.replace('\t\t\t\t\t\t','\t')
            line = line.replace('\t', '&')
            line = line.replace('\n', '')
            lEst1= line
        if i==3:
            line = line.replace('\t\t\t\t\t\t','\t')
            line = line.replace('\t', '&')
            line = line.replace('\n', '')
            lSEs1= line
        if i==34:   
            line = line.replace('twin_three_fam\t\t\t\t','')
            line = line.replace('\n', '')
            line = line.replace('\t\t\t','\t')
            line = line.replace('\t', '&')
            lEst2= line
        if i==35:
            line = line.replace('\t\t\t\t','')
            line = line.replace('\t\t\t','\t')
            line = line.replace('\n', '')
            line = line.replace('\t', '&')
            lSEs2= line
        if i==36:   
            line = line.replace('twin_four_fam\t\t\t\t\t\t\t','')
            line = line.replace('\t', '&')
            lEst3= line
        if i==37:
            line = line.replace('\t\t\t\t\t\t\t','')
            line = line.replace('\t', '&')
            lSEs3= line
        if i==39:
            line = line.replace('N','Observations')
            lObs = line.replace('\t', '&')
    NHISf.write(lEst1+lEst2+lEst3 +'\\\\ \n')
    NHISf.write(lSEs1+lSEs2+lSEs3 + '\\\\ \n &&&&&&&&& \\\\ \n')
    NHISf.write(lObs +'\\\\ \n')
    if ttab=='EducationZscore':
        NHISf.write('&&&&&&&&&\\\\ \\multicolumn{10}{l}{'
                    '\\textsc{Panel B: Health Sample}}\\\\')
NHISf.write('\n'+mr+mc1+twid[14]+tcm[14]+mc3+
"Each cell presents the coefficient of interest from the first    "
"stage regression of twins on fertility using NHIS survey data    "
"(2004-2014).  Base controls include child age FE (in months),    "
"mother's age, and mother's age at first birth plus race dummies  "
"for child and mother. Educational measures are available for all "
"children aged between 6-18 years, and health measures are        "
"available for all children. Descriptive statistics for each      "
"variable can be found in table \\ref{TWINtab:NHISstats}. Standard"
" errors are clustered by mother.")
if ftype=='tex':
    NHISf.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
                "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")

NHISf.close()



#==============================================================================
#== (18) Balance table
#==============================================================================
BALo = open(Tables+'BalanceUSA.'+end, 'w')


BALo.write('\\begin{table}[htpb!] \n' 
           '\\caption{Test of Balance of Observables: USA}'
           '\\label{TWINtab:NHISBalance}\n'
           '\\begin{center}\\begin{tabular}{lcccc}\n'
           '\\toprule\\toprule\n'
           '&Twin  &Non-Twin&Difference&Difference \\\\ \n'
           '&Family&Family  &          & SE        \\\\ \\midrule \n'
           '\\textbf{Panel A: Two-Plus}&&&&\\\\  \n')

wT = open(Results+"NHIS/Balancetwo.txt", 'r')
for i,line in enumerate(wT):
    if i>0:
        line = line.replace('&*','*')
        line = line.replace('&&','&')
        BALo.write(line + '\\\\ \n')

BALo.write('\\midrule \\textbf{Panel B: Three-Plus}&&&&\\\\')
wT = open(Results+"NHIS/Balancethree.txt", 'r')
for i,line in enumerate(wT):
    if i>0:
        line = line.replace('&*','*')
        line = line.replace('&&','&')
        BALo.write(line + '\\\\ \n')

BALo.write('\\midrule \\textbf{Panel B: Four-Plus}&&&&\\\\')
wT = open(Results+"NHIS/Balancefour.txt", 'r')
for i,line in enumerate(wT):
    if i>0:
        line = line.replace('&*','*')
        line = line.replace('&&','&')
        BALo.write(line + '\\\\ \n')


BALo.write('\\bottomrule \\multicolumn{5}{p{12cm}}{\\begin{footnotesize}  '
'\\textsc{Notes:}Refer to table \\ref{TWINtab:DHSBalance} for definitions '
'of samples in each panel.  All variables are measured by the NHIS, and   '
'the sample is identical to that in table \\ref{TWINtab:NHISAll}. The SE  '
'(standard error) of the difference in means is calculated by a two-tailed'
' t-test.  *p$<$0.1; **p$<$0.05; ***p$<$0.01.'
'\\end{footnotesize}}'
'\\end{tabular}\\end{center}\\end{table}')


BALo.close()
"""


print "Terminated Correctly."
