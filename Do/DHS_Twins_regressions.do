/* TWIN_RESULTS 1.00                 UTF-8                         dh:2012-04-09
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/

*NOTE TO FUTURE ME: This is the current twins file.  Run this with DHS_Twins as
*the setup file which gives the file DHS_twins.dta.

*make sure to change for i.bord!!!!!

clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base "~/investigacion/Activa/Twins"
global Data "$Base/Data"
log using $Base/Log/TwinRegressions2.log, text replace

*TWIN PREDICT CONTROLS
global twinpredict bord agemay m_age_sq educf_* height bmi_* /*wealth*/ poor1 i.child_yob i._cou
global twinpredict_i agemay m_age_sq educf_* height /*
*/ bmi_vslow bmi_vlow bmi_low bmi_overwt bmi_obese1 bmi_obese2 /*
*/ /*wealth*/ poor1 i.child_yob i._cou
global twinpredict_ii agemay m_age_sq educf_1_4 educf_5_6 educf_7_10 educf_11plus height /*
*/ bmi /*wealth*/ poor1 i.child_yob i._cou

global sumstats bord fert agemay educf educ attendance poor1 height bmi /*wealth*/

*Q-Q CONTROLS
global basic malec agemay age17-age18 i.child_yob i._cou /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global socioeconomic educf_* poor1 malec agemay age17-age18 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global allcontrols educf_* poor1 height bmi malec agemay age17-age18 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7

*OUTREG Q-Q
global basic_out fert malec agemay borddummy2 borddummy3 borddummy4 
global socioeconomic_out fert malec agemay educf_* poor1 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 
global all_out fert malec agemay educf_* bmi poor1 height borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7



use $Data/DHS_twins, clear

drop if height<800|height>2200 //THIS IS 1728 OBSERVATIONS
rename educf_0 educf00

*NEW CONDITION 24/10/2012: max 18yrs (92.78% of the sample)
drop if age>18
local agemax 18
gen poor1=wealth==1

replace bmi=bmi/100
gen bmi_vslow=bmi<15
gen bmi_vlow=bmi>=15&bmi<16
gen bmi_low=bmi>=16&bmi<18.5
gen bmi_norm=bmi>=18.5&bmi<25
gen bmi_overwt=bmi>=25&bmi<30
gen bmi_obese1=bmi>=30&bmi<35
gen bmi_obese2=bmi>=35
foreach var in bmi_vslow bmi_vlow bmi_low bmi_norm bmi_overwt bmi_obese1 bmi_obese2 {
	replace `var'=. if bmi==.
}

gen m_age_sq=agemay^2

*******************************************************************************
*** (2a) OLS BRISTOL
*******************************************************************************
local basecontrols malec age agesq agemay m_age_sq i._cou i.year_birth 
local morecontrols height bmi educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1

*gen highschool=educlevel==2|educlevel==3

cap gen agesq=age*age

reg school_zscore fert `basecontrols', cluster(_cou) 
outreg2 fert using "~/olszscore.tex", tex(pr) append
reg school_zscore fert `basecontrols' educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1, cluster(_cou) 
outreg2 fert using "~/olszscore.tex", tex(pr) append
reg school_zscore fert `basecontrols' `morecontrols', cluster(_cou) 
outreg2 fert using "~/olszscore.tex", tex(pr) append

reg attendance fert `basecontrols', cluster(_cou) 
outreg2 fert using "~/olshighschool.tex", tex(pr) append
reg attendance fert `basecontrols' educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1, cluster(_cou) 
outreg2 fert using "~/olshighschool.tex", tex(pr) append
reg attendance fert `basecontrols' `morecontrols', cluster(_cou) 
outreg2 fert using "~/olshighschool.tex", tex(pr) append

reg highschool fert `basecontrols', cluster(_cou) 
outreg2 fert using "~/olsattend.tex", tex(pr) append
reg highschool fert `basecontrols' educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1, cluster(_cou) 
outreg2 fert using "~/olsattend.tex", tex(pr) append
reg highschool fert `basecontrols' `morecontrols', cluster(_cou) 
outreg2 fert using "~/olsattend.tex", tex(pr) append

*******************************************************************************
****(Table 1) Summary Stats
*******************************************************************************

sum $sumstats
sum $sumstats if twin==0
sum $sumstats if twin>0&twin!=.
foreach income in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
sum $sumstats if twin==0 & inc=="`income'"
sum $sumstats if twin>0&twin!=. & inc=="`income'"
}

sum agemay m_age_sq educf_* height bmi_vslow bmi_vlow bmi_low bmi_overwt bmi_obese1 bmi_obese2 /*
*/ poor1 fert child_yob
foreach income in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
	sum agemay m_age_sq educf_* height bmi_vslow bmi_vlow bmi_low bmi_overwt bmi_obese1 bmi_obese2 poor1 fert child_yob if inc=="`income'"
}

*******************************************************************************
****(Table 2) Predict twins
*******************************************************************************
local cond1 child_yob>0 
local cond2 child_yob>1989
local cond3 child_yob<=1989

local bordyes i.bord
local bordno /*i.bord*/

cap rm "$Base/Results/TwinPredict/twinpredict_table2.xls"
cap rm "$Base/Results/TwinPredict/twinpredict_table2.txt"
foreach cond in /*`cond1' `cond2'*/ `cond3' {
	reg twind100 bord $twinpredict_ii [pw=sweight] if `cond', cluster(_cou)
	*outreg2 agemay m_age_sq educf_* height bmi_* poor1 using "$Base/Results/TwinPredict/twinpredict_table2.xls", excel 2aster append
	outreg2 bord agemay educf_* height bmi poor1 using "$Base/Results/TwinPredict/twinpredict_table2_pre1990.tex", tex(pr) 2aster append

	foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
		reg twind100 bord $twinpredict_ii [pw=sweight] if income_status=="`incstat'" & `cond', cluster(_cou)
		*outreg2 agemay m_age_sq educf_* height bmi_* poor1 using $Base/Results/TwinPredict/twinpredict_table2.xls, excel append 2aster
		outreg2 bord agemay educf_* height bmi poor1 using "$Base/Results/TwinPredict/twinpredict_table2_pre1990.tex", tex(pr) 2aster append
	}

	*NO BIRTH ORDER
*	reg twind100 $twinpredict_i [pw=sweight] if `cond', cluster(_cou)
*	outreg2 agemay m_age_sq educf_* height bmi_* poor1 using "$Base/Results/TwinPredict/twinpredict_table2.xls", excel 2aster append


*	foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
*		reg twind100 $twinpredict_i [pw=sweight] if income_status=="`incstat'" & `cond', cluster(_cou)
*		outreg2 agemay m_age_sq educf_* height bmi_* poor1 using $Base/Results/TwinPredict/twinpredict_table2.xls, excel append 2aster
*	}
}
/*
*******************************************************************************
****(Table 3) Q-Q
*******************************************************************************

*educ
/*reg educ fert $allcontrols if age>16
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
*/

foreach x in one two three four five six{
	dis "educ `x'"
	xi: ivreg2 educ (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1
	outreg2 $all_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster
	xi: ivreg2 educ (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster
	xi: ivreg2 educ (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster

	reg educ fert $allcontrols if age>16 & `x'_plus==1 & e(sample)
	outreg2 $all_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster
	reg educ fert $socioeconomic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster
	reg educ fert $basic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/educ_table3.xls, excel append 2aster
}

*attendance gap
replace attendance=1 if attendance==2

foreach y of varlist attendance gap {
	foreach x in one two three four five six{
		dis "`y' `x'"
		xi: ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1
		outreg2 $all_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster
		xi: ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $socioeconomic_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster
		xi: ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $basic_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster

		reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $all_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster
		reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $socioeconomic_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster
		reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $basic_out using $Base/Results/QQ/`y'_table3.xls, excel append 2aster
	}
}

*school_zscore
foreach x in one two three four five six{
	dis "zscore `x'"
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1
	outreg2 $all_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster

	reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample)
	outreg2 $all_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster
	reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster
	reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/school_zscore_table3.xls, excel append 2aster
}


*******************************************************************************
****(Table 4) Q-Q with country groups
*******************************************************************************
foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
	*educ
	foreach x in one two three four five six{
		dis in red "educ `incstat' `x'"
		xi: ivreg2 educ (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1 & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		xi: ivreg2 educ (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		xi: ivreg2 educ (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster

		reg educ fert $allcontrols if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		reg educ fert $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		reg educ fert $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
	}

	*attendance gap
	foreach y of varlist attendance gap {
		foreach x in one two three four five six{
			dis "`y' `incstat' `x'"
			xi: ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1 & income_status=="`incstat'"
			outreg2 $all_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			xi: ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $socioeconomic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			xi: ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $basic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster

			reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $all_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $socioeconomic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $basic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
		}
	}
	
	*school z-score
	foreach x in one two three four five six {
		dis "zscore `incstat' `x'"
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1 & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster

		reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
	}
}

*******************************************************************************
****(Table 4) Predict terminated pregnancy
*******************************************************************************
*BMI
replace bmi=bmi/100
gen bmi_vslow=bmi>=13&bmi<15
gen bmi_vlow=bmi>=15&bmi<16
gen bmi_low=bmi>=16&bmi<18.5
gen bmi_norm=bmi>=18.5&bmi<25
gen bmi_overwt=bmi>=25&bmi<30
gen bmi_obese1=bmi>=30&bmi<35
gen bmi_obese2=bmi>=35

replace terminated_preg=. if terminated_preg==8|terminated_preg==9
gen incstat=1 if income_status=="LOWINCOME"
replace incstat=2 if income_status=="LOWERMIDDLE"
replace incstat=3 if income_status=="UPPERMIDDLE"
collapse fert agemay educf_* height bmi_* /*wealth*/ poor1 child_yob _cou /*anemia*/ sweight terminated_preg incstat, by(id)

replace child_yob=round(child_yob)
*replace yearc=round(yearc)
reg terminated_preg fert agemay educf_* height bmi_vslow bmi_vlo bmi_low bmi_over bmi_obese1 bmi_obese2 /*wealth*/ poor1 i.child_yob i._cou [pw=sweight]
outreg2 fert agemay educf_* height bmi_vslow bmi_vlo bmi_low bmi_over bmi_obese1 bmi_obese2 /*wealth*/ poor1 using $Base/Results/TwinPredict/pregterm_predict, excel replace 2aster
*reg twind100 $twinpredict_i [pw=sweight]
*outreg2 agemay educf_* height bmi poor1 using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
*test educf_0=educf_1_4=educf_5_6=educf_7_10=height=bmi=poor1=0


foreach incstat of numlist 1(1)3{
	reg terminated_preg fert agemay educf_* height bmi_vslow bmi_vlo bmi_low bmi_over bmi_obese1 bmi_obese2  /*wealth*/ poor1 i.child_yob i._cou [pw=sweight] if incstat==`incstat'
	outreg2 fert agemay educf_* height bmi_vslow bmi_vlo bmi_low bmi_over bmi_obese1  bmi_obese2 /*wealth*/ poor1 using $Base/Results/TwinPredict/pregterm_predict, excel append 2aster
	*reg twind100 $twinpredict_i [pw=sweight] if income_status=="`incstat'"
	*outreg2 agemay educf_* height bmi poor1 using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
}
