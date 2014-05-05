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
Results = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/"
Tables   = "/home/damiancclarke/investigacion/Activa/Twins/Scientific/Tables/"

twin = "Twin_Predict_none.xls"

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
            '}{p{13.8cm}}','}{p{14.2cm}}','}{p{10.6cm}}','}{p{13.2cm}}',
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

    rTwi = '11'

#==============================================================================
#== (1) Read in DHS twin predict table, LaTeX format
#==============================================================================
twini = open(Results+"Twin/"+twin, 'r')
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
#== (2) Read in Chile twin predict table
#==============================================================================


print "Terminated Correctly."
