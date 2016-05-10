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
gen kids1979         = FER_2A_1979
gen kid1_YOB1979     = C1DOB79_Y_1979
gen kid1_MOB1979     = C1DOB79_M_1979
gen kid2_YOB1979     = C2DOB79_Y_1979
gen kid2_MOB1979     = C2DOB79_M_1979
gen kid3_YOB1979     = C3DOB79_Y_1979
gen kid3_MOB1979     = C3DOB79_M_1979
gen kid4_YOB1979     = C4DOB79_Y_1979
gen kid4_MOB1979     = C4DOB79_M_1979
gen kid5_YOB1979     = C5DOB79_Y_1979
gen kid5_MOB1979     = C5DOB79_M_1979
gen income1979       = Q13_5_1979
gen race             = SAMPLE_RACE_7
gen kidsadd1980      = FER_2A_1980
gen kid1_YOB1980     = C1DOB80_Y_1980
gen kid1_MOB1980     = C1DOB80_M_1980
gen kid2_YOB1980     = C2DOB80_Y_1980
gen kid2_MOB1980     = C2DOB80_M_1980
gen income1980       = Q13_5_1980
gen kidsadd1981      = FER_2A_1981
gen kid1_YOB1981     = C1DOB81_Y_1981
gen kid1_MOB1981     = C1DOB81_M_1981
gen kid2_YOB1981     = C2DOB81_Y_1981
gen kid2_MOB1981     = C2DOB81_M_1981
gen kids1982         = FFER_2A_1982
gen kids1983         = FER_2A_1983
gen kids1984         = FER_2A_1984
gen drugMarij1984    = DRUG_5_1984>0
gen drugCocaine1984  = DRUG_22_1984==1
gen drugOther1984    = DRUG_26_1984==1

foreach y of numlist 1988 1990 1992 1994 {
    gen PregMarij`y'    = Q9_89_1_`y'==1|Q9_89_2_`y'==1
    gen PregCocaine`y'  = Q9_91_1_`y'==1|Q9_91_2_`y'==1
}
foreach y of numlist 1996 1998 2000 2002 2004 2006 2008 2010 2012 {
    gen PregMarij`y'    = Q9_89_01_`y'==1|Q9_89_02_`y'==1
    gen PregCocaine`y'  = Q9_91_01_`y'==1|Q9_91_02_`y'==1
}


local nums 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 96 98 00 /*
*/ 02 04 06 08 10 12
tokenize `nums'
foreach y of numlist 1979(1)1994 1996(2) 2012 {
    gen education`y'   =HGC_`y'
    gen married`y'     = MARSTAT_KEY_`y'
    gen famsize`y'     = FAMSIZE_`y'
    gen healthLimit`y' = Q11_4_`y'==1 | Q11_5_`y'==1 
    if `y'!= 1989 & `y'!= 2012  gen numkids`y'  = NUMCH`1'_`y'
    if `y'>1983 & `y'!= 1987 & `y'!= 1989 & `y'!= 1991 & `y'!= 1993 {
        gen miscarriage`y'  = MISCAR`1'_`y'
    }
    cap gen alcohol6plus`y' = Q12_4_`y'
    gen region`y'=REGION_`y'
    macro shift
}
foreach y of numlist 1981 1982 1985 1988 1989 1990 1992 {
    gen weight`y'       = Q11_9_`y' if Q11_9_`y'>0
}
gen height1981       = HEALTH_HEIGHT_1981 if HEALTH_HEIGHT_1981>0
gen height1982       = HEALTH_HEIGHT_1982 if HEALTH_HEIGHT_1982>0
gen height1985       = HEALTH_HEIGHT_1985 if HEALTH_HEIGHT_1985>0
gen height2006       = Q11_10_B_2006 if Q11_10_B_2006>0
gen height2008       = Q11_10_B_2008 if Q11_10_B_2008>0
gen height2010       = Q11_10_B_2010 if Q11_10_B_2010>0
gen height2012       = Q11_10_B_2012 if Q11_10_B_2012>0

exit

#delimit ;
keep age1979 hypertension* diabetes* cancer* heartfail* CASEID_1979 HHID_1979
birth* kid*;
#delimit cr
