* TerminatedPreg_regressions 1.00  dh:2012-10-03                Damian C. Clarke
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
clear all
version 11.2
cap log close
set more off
set mem 2000m

global BASE "~/investigacion/Activa/Twins"
global DATA "~/database/DHS/DHS_Data/"
log using $BASE/Log/TerminatedPreg_regressions.log, text replace
use $DATA/maternalDHS

drop if fert==0
********************************************************************************
*** (1) Globals for regression
********************************************************************************
global depvars1 i.education poor rural height agefirst /*
*/ very_underweight underweight overweight moderateobese severeobese age agesq /*
*/ i._cou1 i.year_birth
global depvars2 education educsq poor rural height agefirst /*
*/ very_underweight underweight overweight moderateobese severeobese age agesq /*
*/ i._cou1 i.year_birth
global outreg $BASE/Results/AbortPredict
********************************************************************************
*** (2) Regressions
********************************************************************************


**ALL COUNTRIES, 1 NO FERT, 2 FERT
reg terminated_preg $depvars2 [pw=v005], cluster(_cou)
outreg2 using $outreg/terminated_preg.xls, excel replace
reg terminated_preg fertility $depvars2 [pw=v005], cluster(_cou)
outreg2 using $outreg/terminated_preg.xls, excel append
**ALL COUNTRIES EDUC QUADRATIC, 1 NO FERT, 2 FERT
reg terminated_preg $depvars1 [pw=v005], cluster(_cou)
outreg2 using $outreg/terminated_preg.xls, excel append
reg terminated_preg fertility $depvars1 [pw=v005], cluster(_cou)
outreg2 using $outreg/terminated_preg.xls, excel append
**SPLIT BY COUNTRY INCOME LEVELS
foreach inc in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
	reg terminated_preg $depvars2 [pw=v005] if income_status=="`inc'", cluster(_cou)
	outreg2 using $outreg/terminated_preg.xls, excel append	
	reg terminated_preg fertility $depvars2 [pw=v005] if income_status=="`inc'", cluster(_cou)
	outreg2 using $outreg/terminated_preg.xls, excel append
}
