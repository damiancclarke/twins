/* ALSPACtests.do v1.00          damiancclarke             yyyy-mm-dd:2015-12-06
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

The only non-Stata libraries required are outreg2 and estout.  If this is not in
stalled on the computer/server, it will be installed. If it is not installed and 
the computer does not have internet access, this file will fail to export result
s.
*/

vers 11
clear all
set more off
set maxvar 25000
cap log close


foreach ado in outreg2 estout {
    cap which `ado'
    if _rc!=0 ssc install `ado'
}

********************************************************************************
*** (1a) Set main globals and locals
********************************************************************************
global DAT "/mnt/ide0/home/biroli/ChicaGo/Heckman/Data/ALSPAC"
global OUT "/mnt/ide0/home/biroli/ChicaGo/Heckman/Data/ALSPAC/codePietro/DamianSonia"

cd $OUT

local data heckman_111111.dta
log using "$OUT/ALSPACtest.txt", text replace

********************************************************************************
*** (1b) Set locals of variables to include in analysis
********************************************************************************
#delimit ;
local y_var   twin100;
local health  bmi height diabetes hypertension infections preDrugs preAlcohol
              preSmoke freqFattyFoods freqHealthFoods freqFreshFruit beerDrink
              beerDrinkHigh wineDrink wineDrinkHigh alcoholPreg alcoholPregHigh
              passiveSmoke smokePreg;
local FEs     i.motherAge i.fertility i.gestation;
local statform cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))");
#delimit cr

********************************************************************************
*** (2) Open data, label variable for output
********************************************************************************
use "$DAT/`data'"

gen gestation        = bestgest
duplicates tag aln, gen(twin)
gen twin100          = twin*100
gen fertility        = b005+1
gen motherAge        = e695
*************************PLEASE JUST CHECK THESE TWO: ARE THE MISSINGS CORRECT?
gen bmi              = dw042 if dw042!=.  
gen height           = dw021 if dw021!=.
*************************
gen diabetes         = d041==2 if d040!=-1
gen hypertension     = d047==2 if d046!=-1
gen infections       = d059a if d059a!=-1
gen preDrugs         = d167==1|d167==2 if d167!=-1
gen preAlcohol       = d168==1|d168==2 if d168!=-1
gen preSmoke         = b650==2&b658>=10 if b650!=-1
gen freqFattyFoods   = c200>3|c201>3|c210>3|c211>3|c220>3 if c200!>0
gen freqHealthFoods  = c223>3|c224>3|c225>3 if c200!>0
gen freqFreshFruit   = c229>3 if c229>0 
gen beerDrink        = c363>0&c363<5
gen beerDrinkHigh    = c363>=5
gen wineDrink        = c366>0&c366<5
gen wineDrinkHigh    = c366>=5
gen alcoholPreg      = c373>0&c373<6
gen alcoholPregHigh  = c373>=6
gen passiveSmoke     = c481a==3
gen smokePreg        = c482>0|c482==-1
gen c579             = c554+c563+c568+c557+c560+c570+c571
egen temp1           = anymatch(c554 c563 c568 c557 c560 c570 c571), values(-1 -2)
replace c579         = -1 if temp1==1


********************************************************************************
*** (3) Sum stats
********************************************************************************
gen a=1
estpost sum `health' twin100 motherAge a, casewise
estout using "$OUT/UKASum.tex", replace label style(tex) `statform'

********************************************************************************
*** (4) Regressions using new four iterations: uncond/cond, Z-score/unstand
********************************************************************************
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
foreach var of varlist `health' {
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
outsheet varname beta_non_cond se_non_cond uCI_non_cond lCI_non_cond    /*
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



********************************************************************************
*** (5) Close
********************************************************************************
log close
