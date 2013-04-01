* TerminatedPreg_Setup            dh:2012-07-25                 Damian C. Clarke
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000

*GLOBALS FOR COMPUTER AND DATA
if c(username)=="damian" {
	global PATH "/media/DCC/MMR"
	global COMPUTER "Damian"
}
else if c(os)=="Unix" {
	global PATH "~/investigacion/Activa/Twins"
	global COMPUTER "damiancclarke@dcc-linux"
}

global DATA "~/database/DHS/DHS_Data"
global DO "$PATH/Do"
global LOG "$PATH/Log"
global RESULTS "$PATH/Results"

log using "$LOG/TerminatedPreg_Setup.txt", text replace

********************************************************************************
*** (1) TAKE APPROPRIATE VARIABLES FROM INDIVIDUAL RECODE FILES (MOTHERS)
********************************************************************************
foreach file in 1 2a 2 3a 3 4a 4 {
	use $DATA/World_IR_p`file', clear

	keep _cou _year caseid v000 v001 v002 v003 v005 v007 v010 v133 v137 v140 /*
	*/ v201 v212 v228 v230 v234 v437 v438 v106 v190 v445 v012

	rename v010 year_birth
	rename v228 terminated_preg
	rename v230 terminated_year
	rename v234 other_terminated
	rename v133 education
	rename v137 kids_under5
	rename v140 rural
	rename v201 fertility
	rename v212 agefirstbirth
	rename v437 weight
	rename v438 height
	rename v106 educ_level
	rename v190 wealth
	rename v445 bmi
	rename v012 age

	save $DATA/IR`file', replace
}

********************************************************************************
*** (2) MERGE TO CREATE WORLDWIDE MOTHER DATA FILE
********************************************************************************
clear all
use "$DATA/IR1"
append using "$DATA/IR2a" "$DATA/IR2" "$DATA/IR3a" "$DATA/IR3" "$DATA/IR4a" "$DATA/IR4"

********************************************************************************
*** (3) CREATE VARIABLES FOR REGRESSIONS
********************************************************************************
replace terminated_preg=. if terminated_preg==8 | terminated_preg==9
replace height=. if height<100|height>2500
replace weight=. if weight<300|weight>2000
replace year_birth=year_birth+1900 if year_birth<100
replace year_birth=. if year_birth>1997
replace education=. if education>25
replace rural=. if rural==0|rural>2
encode _cou, gen(_cou1)
gen educsq=education*education
replace educ_level=. if educ_level==8|educ_level==9
gen weightsq = weight*weight
replace bmi=. if bmi>9000
gen very_underweight=(bmi<1600)
gen underweight=(bmi>=1600&bmi<1850)
gen normal=(bmi>=1850&bmi<2500)
gen overweight=(bmi>=2500&bmi<3000)
gen moderateobese=(bmi>=3000&bmi<3500)
gen severeobese=(bmi>=3500)
gen agesq=age^2
gen poor=wealth==1
replace height=height/1000
foreach var of varlist very_underweight underweight normal overweight moderateobese severeobese {
	replace `var'=. if bmi==.
}

********************************************************************************
*** (4) Create country income levels
********************************************************************************
gen country=_cou
do $PATH/Do/countrynaming

********************************************************************************
*** (5) Save dataset for regressions
********************************************************************************
save $DATA/maternalDHS, replace
