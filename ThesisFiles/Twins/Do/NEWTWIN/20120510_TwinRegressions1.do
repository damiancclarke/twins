/* TWIN_RESULTS 1.00                 UTF-8                         dh:2012-04-09
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/

**ADD TWO STARS INSTEAD OF THREE TO OUTREG MAX.
clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base H:\ExtendedEssay\Twins
global Data H:\ExtendedEssay\DHS
log using $Base\Log\20120510_TwinRegressions.txt, text replace

*TWIN PREDICT CONTROLS
global twinpredict bord agemay educf_* height bmi aiquin i.yearc country2- country46
global twinpredict_i i.bord agemay educf_* height bmi aiquin i.yearc country2- country46

*Q-Q CONTROLS
global basic  malec agemay age17-age38 yearc1-yearc88 country1-country46 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global socioeconomic educf_* poor1 malec agemay age17-age38 yearc1-yearc88/*
*/ country1-country46 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global allcontrols educf_* poor1 height bmi malec agemay age17-age38 yearc1-yearc88/*
*/ country1-country46 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7

*OUTREG Q-Q
global basic_out fert malec agemay borddummy2 borddummy3 borddummy4 
global socioeconomic_out fert malec agemay educf_* poor1 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 
global all_out fert malec agemay educf_* bmi poor1 height borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7

*______________________________________________________________________________*
*																		       *
*REGRESSIONS FOR TABLE 2 (Predict twins)
use $Data\DHS_Base, clear

drop if height<80|height>240 //THIS IS 1728 OBSERVATIONS
rename educf_0 educf00




*NOTE I ADDED fert (endog)?
reg twind100 $twinpredict [pw=sweight]
outreg2 bord agemay educf_* height bmi aiquin using $Base\results2\TwinPredict\twinpredict_table2quin, tex(pr) replace 2aster
*reg twind100 $twinpredict_i [pw=sweight]
*outreg2 agemay educf_* height bmi poor1 using $Base\results2\TwinPredict\twinpredict_table2, excel append 2aster
*test educf_0=educf_1_4=educf_5_6=educf_7_10=height=bmi=poor1=0
foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
reg twind100 $twinpredict [pw=sweight] if income_status=="`incstat'"
outreg2 bord fert agemay educf_* height bmi aiquin using $Base\results2\TwinPredict\twinpredict_table2quin, tex(pr) append 2aster
*reg twind100 $twinpredict_i [pw=sweight] if income_status=="`incstat'"
*outreg2 agemay educf_* height bmi poor1 using $Base\results2\TwinPredict\twinpredict_table2, excel append 2aster
}

*______________________________________________________________________________*
*																		       *
*REGRESSIONS FOR TABLE 3 (Q-Q)


*eduyears
reg eduyears fert $allcontrols if age>16
predict uhat, resid

reg uhat twind

foreach instat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
qui reg attendance fert $allcontrols if age>5 & age<17 & income_status=="`instat'"
predict uhatatt`instat', resid 
correlate uhatatt`instat' twind, covariance
}

reg school_zscore fert $allcontrols if age>5
predict uhatz, resid
reg uhatz twind

foreach x in one{ //two three four five six{
ivreg2 eduyears (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1
outreg2 $all_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster
ivreg2 eduyears (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster
ivreg2 eduyears (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster

reg eduyears fert $allcontrols if age>16 & `x'_plus==1 & e(sample)
outreg2 $all_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster
reg eduyears fert $socioeconomic if age>16 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster
reg eduyears fert $basic if age>16 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\eduyears_table3, excel append 2aster
}

*attendance gap

replace attendance=1 if attendance==2

foreach y of varlist attendance gap {
foreach x in one two three four five six{
ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1
outreg2 $all_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster
ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster
ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster

reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample)
outreg2 $all_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster
reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster
reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\a_`y'_table3, excel append 2aster
}
}

*school_zscore
foreach x in one two three four five six{
ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1
outreg2 $all_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster
ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster
ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster

reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample)
outreg2 $all_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster
reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample)
outreg2 $socioeconomic_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster
reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample)
outreg2 $basic_out using $Base\Results2\QQ\school_zscore_table3a, excel append 2aster
}
*______________________________________________________________________________*
*																		       *
*REGRESSIONS FOR TABLE 4 (Q-Q WITH COUNTRY GROUPS)


*eduyears
foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
foreach x in one two three four five six{
ivreg2 eduyears (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1 & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster
ivreg2 eduyears (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster
ivreg2 eduyears (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster

reg eduyears fert $allcontrols if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster
reg eduyears fert $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster
reg eduyears fert $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\eduyears_table4_`incstat', excel append 2aster
}

*attendance gap

foreach y of varlist attendance gap {
foreach x in one two three four five six{
ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1 & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster
ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster
ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster

reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster
reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster
reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\table4_`y'_`incstat', excel append 2aster
}
}

foreach incstat in LOWERMIDDLE UPPERMIDDLE{ //TAKE OUT THIS LINE NORMALLY
foreach x in one two three four five six {
ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1 & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster
ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster
ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster

reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $all_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster
reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $socioeconomic_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster
reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
outreg2 $basic_out using $Base\Results2\QQ\school_zscore_table4a_`incstat', excel append 2aster
}
}
