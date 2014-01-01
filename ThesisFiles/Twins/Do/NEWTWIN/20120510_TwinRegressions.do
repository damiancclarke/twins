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
*REGRESSIONS FOR TABLE 2 (Predict twins)
use $Data\DHS_Base, clear

reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight]
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) replace
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWINCOME"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="LOWERMIDDLE"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append
reg twind100 bord agemay educf_* height bmi poor1 i.yearc country2- country46 [pw=sweight] if income_status=="UPPERMIDDLE"
outreg2 bord agemay educf_* height bmi poor1 using $Base\results\twinbirth2, tex(pr) append
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
*																		       *
*INCLUDE MOTHER'S AGE HERE AND IN DHSMerge
*OUTREG TABLES
*NOTE: table2 had robust standard errors.  table had robust standard errors clustered at country level (but I forgot to include agemay in the OLS)
**It is probably worth including table rather than table2 (included as at 20120410).
*THIS IS TABLE 3 (Q-Q SPECIFICATION)
***Damian 10 May - include socioeconomic, and health columns
foreach x in one two three {
reg eduyears malec fert agemay age17-age38 yearc1-yearc88 country1-country46 /*
*/ borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
*outreg2 fert agemay borddummy2 borddummy3 borddummy4 using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
ivreg2 eduyears malec (fert=twin_`x'_fam) agemay age17-age38 yearc1-yearc88 /*
*/country1-country46 borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
*outreg2 fert borddummy2 borddummy3 borddummy4 agemay using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
ivreg2 eduyears malec (fert=twin_`x'_fam) agemay age17-age38 educfyrs educfyrs2 height /*
*/bmi poor1 yearc1-yearc88 country1-country46 borddummy2 borddummy3 borddummy4 if age>16 & `x'_plus==1
*outreg2 fert agemay borddummy2 borddummy3 borddummy4 educfyrs educfyrs2 bmi poor1 height using $Base\Results\Outreg\Attendance\Eduyears_table3, tex(pr) append
}

*TABLE 3 GENERAL (SEE ALL), 
foreach y of varlist eduyears attendance gap {
foreach x in one two three four five six{
ivreg2 `y' malec (fert=twin_`x'_fam) agemay age17-age38 educf_* height /*
*/bmi poor1 yearc1-yearc88 country1-country46 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1
outreg2 fert malec agemay educf_* bmi poor1 height borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 using $Base\Results\Outreg\Attendance\`y'_table3, excel append

ivreg2 `y' malec (fert=twin_`x'_fam) agemay age17-age38 educf_*  /*
*/ poor1 yearc1-yearc88 country1-country46 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1 & e(sample)
outreg2 fert malec agemay educf_* poor1 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 using $Base\Results\Outreg\Attendance\`y'_table3, excel append

ivreg2 `y' malec (fert=twin_`x'_fam) agemay age17-age38 yearc1-yearc88 /*
*/country1-country46 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1 & e(sample)
outreg2 fert malec borddummy2 borddummy3 borddummy4 agemay using $Base\Results\Outreg\Attendance\`y'_table3, excel append

reg `y' malec fert agemay age17-age38 yearc1-yearc88 country1-country46 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1 & e(sample)
outreg2 fert malec agemay borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 using $Base\Results\Outreg\Attendance\`y'_table3, excel append

reg `y' malec fert agemay age17-age38 yearc1-yearc88 country1-country46 educf_* poor1 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1 & e(sample)
outreg2 fert malec agemay educf_* poor1 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 using $Base\Results\Outreg\Attendance\`y'_table3, excel append

reg `y' malec fert agemay age17-age38 yearc1-yearc88 country1-country46 educf_* poor1 height bmi /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 if age>16 & `x'_plus==1 & e(sample)
outreg2 fert malec agemay educf_* poor1 height bmi borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 using $Base\Results\Outreg\Attendance\`y'_table3, excel append
}
}

*ADD NEW LINES WHERE I RERUN FOR EACH COUNTRY SUB-GROUP.

