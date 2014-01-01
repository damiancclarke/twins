/* TWIN_RESULTS 1.00                 UTF-8                         dh:2012-04-09
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base H:\ExtendedEssay\Twins
global Data H:\ExtendedEssay\DHS
log using $Base\Log\20120409_TwinResults.txt, text replace

*______________________________________________________________________________*
*																		       *
use $Data\DHS_Base, clear
tab country, gen(country)

gen educf_0=educfyrs==0
gen educf_1_4=educfyrs>0&educfyrs<5
gen educf_5_6=educfyrs>4&educfyrs<7
gen educf_7_10=educfyrs>6&educfyrs<11
gen educf_11plus=educfyrs>10

gen twind100=twind*100

rename educf_0 educf00

reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight]
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) replace 2aster
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWINCOME"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append 2aster
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWERMIDDLE"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append 2aster
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="UPPERMIDDLE"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append 2aster
*reg twind bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status!="LOWINCOME"
*outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append

reg twind100 i.bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight]
outreg2 agemay educf_* height bmi poor1 using $Base\results\twinbirth2, excel append
reg twind100 i.bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWINCOME"
outreg2 agemay educf_* height bmi poor1 using $Base\results\twinbirth2, excel append
reg twind100 i.bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWERMIDDLE"
outreg2 agemay educf_* height bmi poor1 using $Base\results\twinbirth2, excel append
reg twind100 i.bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="UPPERMIDDLE"
outreg2 agemay educf_* height bmi poor1 using $Base\results\twinbirth2, excel append
reg twind100 i.bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status!="LOWINCOME"
outreg2 agemay educf_* height bmi poor1 using $Base\results\twinbirth2, excel append
*reg twind bord educfyrs height bmi poor1 i.yearc country2- country46 [pw=sweight]
*reg twind i.bord i.educfyrs height bmi poor1 i.v701 i.yearc country2- country46 [pw=sweight]
*probit twind bord educfyrs height bmi poor1 i.yearc country2- country46 [pw=sweight]

*______________________________________________________________________________*
*	
*SET-UP																		   *
*QUALITY-QUANTITY (1+)
gen one_plus=1 if bord==1 & fert>=2
replace one_plus=0 if bord>1|fert==1
replace one_plus=0 if twinc!=0
gen twin2=1 if twinc==1 & bord==2
replace twin2=0 if twin2!=1
bys caseid2: egen twin2fam=max(twin2)

*QUALITY-QUANTITY (2+)
gen two_plus=1 if bord==1 & fert>=3
replace two_plus=1 if bord==2 & fert>=3
replace two_plus=0 if two_plus!=1
replace two_plus=0 if twinc!=0
gen twin3=1 if twinc==1 & bord==3
replace twin3=0 if twin3!=1
bys caseid2: egen twin3fam=max(twin3) 

*QUALITY-QUANTITY (3+)
gen three_plus=1 if bord==1 & fert>=4
replace three_plus=1 if bord==2 & fert>=4
replace three_plus=1 if bord==3 & fert>=4
replace three_plus=0 if three_plus!=1
replace three_plus=0 if twinc!=0
gen twin4=1 if twinc==1 & bord==4
replace twin4=0 if twin4!=1
bys caseid2: egen twin4fam=max(twin4) 

*QUALITY-QUANTITY (4+)
gen four_plus=1 if bord==1 & fert>=5
replace four_plus=1 if bord==2 & fert>=5
replace four_plus=1 if bord==3 & fert>=5
replace four_plus=1 if bord==4 & fert>=5
replace four_plus=0 if four_plus!=1
replace four_plus=0 if twinc!=0
gen twin5=1 if twinc==1 & bord==5
replace twin5=0 if twin5!=1
bys caseid2: egen twin5fam=max(twin5) 

gen attendance=0 if enrolment==0
replace attenda=1 if enrolment==2
replace attenda=2 if enrolment==1
*GAP
gen gap=age-eduyears-6 if age>6 & age<17
replace gap=. if gap<-2

tab v701, gen(educmale)
*drop educfyrs2
*tab educfyrs, gen(educfyrs)
tab age, gen(age)
tab yearc, gen(yearc)
tab bord, gen(borddummy)

rename twin2fam twin_one_fam
rename twin3fam twin_two_fam
rename twin4fam twin_three_fam
rename twin5fam twin_four_fam

*INCLUDE MOTHER'S AGE HERE AND IN DHSMerge
*OUTREG TABLES
*NOTE: table2 had robust standard errors.  table had robust standard errors clustered at country level (but I forgot to include agemay in the OLS)
**It is probably worth including table rather than table2 (included as at 20120410).
foreach x in one two three {
reg eduyears malec fert agemay age17-age38 yearc1-yearc88 country1-country46 /*
*/ borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
outreg2 fert agemay borddummy2 borddummy3 borddummy4 using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
ivreg2 eduyears malec (fert=twin_`x'_fam) agemay age17-age38 yearc1-yearc88 /*
*/country1-country46 borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
outreg2 fert borddummy2 borddummy3 borddummy4 agemay using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
ivreg2 eduyears malec (fert=twin_`x'_fam) agemay age17-age38 educfyrs educfyrs2 height /*
*/bmi poor1 yearc1-yearc88 country1-country46 borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
outreg2 fert agemay borddummy2 borddummy3 borddummy4 educfyrs educfyrs2 bmi poor1 height using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
}

