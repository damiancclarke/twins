/* ALSPACtests.do v1.00          damiancclarke             yyyy-mm-dd:2016-04-06
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file runs twin regressions using the ALSPAC data.  Regressions of the form:
      twin100_ij = a + B*Health_j + fert + MotherAge + u_ij
are run, where twin100 takes the value of 0 if child i of mother j is not a twin
and 100 if child i of mother j is a twin.  Independent variables consist of moth
er's health stocks and behvarious, as well as controls for completed fertility a
nd age at birth.

Locals are set in section (1b). These should only need to be changed if: (a) cer
tain variable names are not as defined in these locals, or if (b) certain variab
les are not available. The globals DAT and OUT in section (1a) also need to be s
et.  DAT is where the data is located, and OUT is where log files and results fi
les should be sent.  The local data gives the name of the ALSPAC data file.

The only non-Stata library required is estout.  If this is not installed on the 
computer/server, it will be installed. If it is not installed and the computer 
does not have internet access, this file will fail to export results.
*/

vers 11
clear all
set more off
set maxvar 25000
cap log close


cap which estout
if _rc!=0 ssc install estout

********************************************************************************
*** (1a) Set main globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/ALSPAC"
global OUT "~/investigacion/Activa/Twins/Results/World"
local data ALSPAC.dta

log using "$OUT/ALSPACtest.txt", text replace

********************************************************************************
*** (1b) Set locals of variables to include in analysis
********************************************************************************
#delimit ;
local y_var   twin100;
local health  underweight obese height diabetes hypertension infections 
              freqHealthFoods freqFreshFruit alcoholPreg
              alcoholPregHigh passiveSmoke smokePreg meduc;
local FEs     i.motherAge i.fertility i.gestation educM;
local statform cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))");
#delimit cr

********************************************************************************
*** (2) Open data, label variable for output
********************************************************************************
use "$DAT/`data'"
keep if in_core==1

gen gestation        = bestgest
gen twin             = mz010 == 2
gen twin100          = twin*100
gen fertility        = b005+1
gen motherAge        = e695
gen bmi              = dw042 if dw042!=.  
gen height           = dw021 if dw021!=.
gen underweight      = bmi<18.5 
gen obese            = bmi>=30 & bmi<99
gen diabetes         = d041==2 if d040!=-1
gen hypertension     = d047==2 if d046!=-1
gen infections       = d059a if d059a!=-1
gen preDrugs         = d167==1|d167==2 if d167!=-1&d167<99
gen preAlcohol       = d168==1|d168==2 if d168!=-1&d168<99
gen preSmoke         = b650==1&b658>=10 
gen freqHealthFoods  = c223>3|c224>3|c225>3 if c223!=.
gen freqFreshFruit   = c229>=5
gen beerDrink        = c363>0&c363<5 
gen beerDrinkHigh    = c363>=5 & c363<99
gen wineDrink        = c366>0&c366<5 
gen wineDrinkHigh    = c366>=5 & c366<99
gen alcoholPreg      = c373>0&c373<99 
gen alcoholPregHigh  = c373>=6 & c373<99
gen passiveSmoke     = c481a==3 
gen smokePreg        = c482>0 & c482<99

gen meduc     = 0  if k6280 == 1
replace meduc = 11 if k6281 == 1
replace meduc = 11 if k6282 == 1
replace meduc = 12 if k6283 == 1
replace meduc = 13 if k6284 == 1
replace meduc = 11 if k6285 == 1
replace meduc = 14 if k6286 == 1|k6287==1|k6288==1|k6289==1|k6280==1|k6291==1
replace meduc = 16 if k6292 == 1
replace meduc = 13 if k6295 == 1
replace meduc = 10 if meduc== .
gen educM = meduc==10
keep if motherAge>=18&motherAge<=49
gen twind=twin

/*
foreach v of varlist underweight obese hypertension infections /*
*/ diabetes alcoholPreg alcoholPregHigh passiveSmoke smokePreg {
    gen INV_`v'=`v'==0 if `v'!=.
}

factor INV_* height freqHealthFoods freqFreshFruit, factor(3)
predict healthMom
egen healthMomZ = std(healthMom)
#delimit ;
esttab using "$OUT/factorsUK.tex", booktabs label noobs nonumber nomtitle
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t) Psi[Uniqueness]") nogap replace; 
#delimit cr


regress healthMomZ twind
outreg2 using "$OUT/../Sum/factorResults.xls", append 
exit

********************************************************************************
*** (3) Sum stats
********************************************************************************
gen a=1
estpost sum `health' twin100 motherAge a, casewise
estout using "$OUT/UKASum.tex", replace label style(tex) `statform'

********************************************************************************
*** (4) Regressions using four iterations: uncond/cond, Z-score/unstand
********************************************************************************
preserve
local Zvar
foreach var of varlist `health' {
    egen mean_`var' = mean(`var')
    egen sd_`var'   = sd(`var')
	gen Z_`var' = (`var' - mean_`var')/sd_`var'
	drop mean_`var' sd_`var'

    local Zvar `Zvar' Z_`var'
}

gen varname = ""
foreach estimand in beta se uCI lCI obs {
    gen `estimand'_std_cond  = .
	gen `estimand'_non_cond  = .
	gen `estimand'_std_ucond = .
	gen `estimand'_non_ucond = .
}


reg twin100 `health' `FEs'
keep if e(sample)
local counter = 1
3Dforeach var of varlist `health' {
    qui replace varname     = "`var'" in `counter'

    local nobs = e(N)
	local beta = round( _b[`var']*1000)/1000
	local se   = round(_se[`var']*1000)/1000
	local uCI  = round((`beta'+invttail(`nobs',0.025)*`se')*1000)/1000
	local lCI  = round((`beta'-invttail(`nobs',0.025)*`se')*1000)/1000

    qui replace  obs_non_cond = `nobs' in `counter'
	qui replace beta_non_cond = `beta' in `counter'
	qui replace   se_non_cond = `se'   in `counter'
	qui replace  uCI_non_cond = `uCI'  in `counter'
	qui replace  lCI_non_cond = `lCI'  in `counter'

    local ++counter
}
outsheet varname beta_non_cond se_non_cond uCI_non_cond lCI_non_cond  /*
*/ in 1/`counter' using "$OUT/UKA_est_non_cond.csv", delimit(";") replace


reg twin100 `Zvar' `FEs'
local counter = 1
foreach var of varlist `Zvar' {
    local nobs = e(N)
	local beta = round( _b[`var']*1000)/1000
	local se   = round(_se[`var']*1000)/1000
	local uCI  = round((`beta'+invttail(`nobs',0.025)*`se')*1000)/1000
	local lCI  = round((`beta'-invttail(`nobs',0.025)*`se')*1000)/1000

    qui replace  obs_std_cond = `nobs' in `counter'
    qui replace beta_std_cond = `beta' in `counter'
	qui replace   se_std_cond = `se'   in `counter'
	qui replace  uCI_std_cond = `uCI'  in `counter'
	qui replace  lCI_std_cond = `lCI'  in `counter'

    local ++counter
}
outsheet varname beta_std_cond se_std_cond uCI_std_cond lCI_std_cond /*
*/ in 1/`counter' using "$OUT/UKA_est_std_cond.csv", delimit(";") replace



local counter = 1
dis "Unstandardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `health' {
    qui reg twin100 `var' `FEs'
	local nobs = e(N)
	local beta = round( _b[`var']*1000)/1000
	local se   = round(_se[`var']*1000)/1000
	local uCI  = round((`beta'+invttail(`nobs',0.025)*`se')*1000)/1000
	local lCI  = round((`beta'-invttail(`nobs',0.025)*`se')*1000)/1000

	qui replace  obs_non_ucond = `nobs' in `counter'
	qui replace beta_non_ucond = `beta' in `counter'
	qui replace   se_non_ucond = `se'   in `counter'
	qui replace  uCI_non_ucond = `uCI'  in `counter'
	qui replace  lCI_non_ucond = `lCI'  in `counter'

	dis "`var';`beta';`se';`lCI';`uCI';`nobs'"
	local ++counter
}
outsheet varname beta_non_ucond se_non_ucond uCI_non_ucond lCI_non_ucond /*
*/ in 1/`counter' using "$OUT/UKA_est_non_ucond.csv", delimit(";") replace


local counter = 1
dis "Standardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zvar' {
    qui reg twin100 `var' `FEs'
    local nobs = e(N)
	local beta = round( _b[`var']*1000)/1000
	local se   = round(_se[`var']*1000)/1000
	local uCI  = round((`beta'+invttail(`nobs',0.025)*`se')*1000)/1000
	local lCI  = round((`beta'-invttail(`nobs',0.025)*`se')*1000)/1000

	qui replace  obs_std_ucond = `nobs' in `counter'
	qui replace beta_std_ucond = `beta' in `counter'
	qui replace   se_std_ucond = `se'   in `counter'
	qui replace  uCI_std_ucond = `uCI'  in `counter'
	qui replace  lCI_std_ucond = `lCI'  in `counter'

	dis "`var';`beta';`se';`lCI';`uCI';`nobs'"
	local ++counter
}
outsheet varname beta_std_ucond se_std_ucond uCI_std_ucond lCI_std_ucond /*
*/ in 1/`counter' using "$OUT/UKA_est_std_ucond.csv", delimit(";") replace

restore

*/
********************************************************************************
*** (4) UK Regressions: Twin Dif
********************************************************************************
gen countryName = "United Kingdom"
gen surveyYear  = 1990
rename meduc    educf

foreach var in height educf {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .

    egen Mean = mean(`var')
    egen SDev = sd(`var')
    gen `var'_std = (`var'-Mean)/SDev
    drop Mean SDev
}
foreach var in height_std educf_std {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .
}
gen twinProp = .

gen yearint = 1990

sum twind
replace twinProp = `r(mean)'
gen fert = fertility
foreach var in height educf height_std educf_std {
    qui areg `var' twind i.fert, abs(motherAge)
    local nobs  = e(N)
    local estl `=_b[twind]-invttail(`nobs',0.025)*_se[twind]'
    local estu `=_b[twind]+invttail(`nobs',0.025)*_se[twind]'
    dis "95% CI for `var' is [`estl',`estu']"

    qui replace `var'Est   = _b[twind] in 1
    qui replace `var'LB    = `estl'    in 1
    qui replace `var'UB    = `estu'    in 1
}

keep in 1
keep countryName heightEst heightLB heightUB educfEst educfLB educfUB         /*
*/ height_stdEst height_stdLB height_stdUB educf_stdEst educf_stdLB           /*
*/ educf_stdUB twinProp surveyYear
outsheet using "$OUT/countryEstimatesUK.csv", comma replace


********************************************************************************
*** (5) Close
********************************************************************************
log close
