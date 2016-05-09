/* NLSYPrep.do v0.00             damiancclarke             yyyy-mm-dd:2016-05-05
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NLSY, and converts it into one line per child
with measures of child quality, sibling twin status, and maternal health.  This
can then be used for twin 2sls regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Merging mother and child file

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/NLSY79"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir "$OUT"
log using "$LOG/NLSYPrep.txt", text replace

********************************************************************************
*** (2) Import NLSY79 data
********************************************************************************
infile using "$DAT/NLYS79.dct"
do "$DAT/NLYS79-value-labels.do"

keep if SAMPLE_SEX_1979==2


********************************************************************************
*** (3) Generate mother variables
********************************************************************************
gen age1979          = FAM_1B_1979
gen hypertension     = H40_CHRC_1_XRND == 1
gen hypertensionYear = H40_CHRC_1A_Y_XRND if H40_CHRC_1A_Y_XRND>0
gen diabetes         = H40_CHRC_2_XRND == 1
gen diabetesYear     = H40_CHRC_2A_Y_XRND if H40_CHRC_2A_Y_XRND>0
gen cancer           = H40_CHRC_3_XRND == 1
gen cancerYear       = H40_CHRC_3B_01_Y_XRND if H40_CHRC_3B_01_Y_XRND>0
gen heartfail        = H40_CHRC_6_XRND == 1
gen heartfailYear    = H40_CHRC_6A_Y_XRND if H40_CHRC_6A_Y_XRND>0
gen birthYear        = Q1_3_A_Y_1979
gen birthMonth       = Q1_3_A_M_1979
gen birthCountry     = FAM_2A_1979

gen 
exit

#delimit ;
keep age1979 hypertension* diabetes* cancer* heartfail* CASEID_1979 HHID_1979
birth* ;
#delimit cr
