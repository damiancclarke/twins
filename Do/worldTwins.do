/* worldTwins.do v0.00           damiancclarke             yyyy-mm-dd:2015-10-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Generate figures to present characteristics of twin and non-twin mothers across
 countries/regions.  It uses nationally representative surveys or administrative
 records of births.  Data comes from:
   Albania: DHS
   Armenia: DHS
   Kenya  : DHS
   USA    : Administrative data (NVSS)

 Pre-23/12/2015 included data on US fetal deaths.  Roll back to this date to use
 it.
*/

vers 11
clear all
set more off
cap log close
set maxvar 20000

********************************************************************************
*** (1) globals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data"
global USA "~/database/NVSS/Births/dta"
global GRA "~/investigacion/Activa/Twins/Figures"
global LOG "~/investigacion/Activa/Twins/Log"
global OUT "~/investigacion/Activa/Twins/Results/Sum"
global REG "~/investigacion/Activa/Twins/Results/World"

log using "$LOG/worldTwins.txt", text replace
cap mkdir "$REG"

local statform cells("count(fmt(%12.0gc)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))")
/*
********************************************************************************
*** (2a) DHS Setup
********************************************************************************
use "$DAT/DHS_twins"


keep if _merge==3
keep if motherage>17&motherage<50
gen normalweight = bmi>=18.5&bmi<30

replace height = . if height>240
replace height = . if height<70
replace bmi    = . if bmi > 50
replace educf  = . if educf >27
keep if height !=. & bmi!=.
cap drop underweight
gen underweight = bmi < 18.5
gen obese       = bmi > 30 if bmi!=.

tab twind if educf!=.
levelsof country, local(cc)
exit

replace twind100 = twind*100
bys v001 _year: egen prenateDoctorC = mean(prenate_doc)
bys v001 _year: egen prenateNurseC  = mean(prenate_nurse)
bys v001 _year: egen prenateNoneC   = mean(prenate_none)
gen prenateAnyC = 1 - prenateNoneC
gen noObese   = obese == 0 if obese!= .
gen noUweight = underweight == 0 if underweight != .

lab var height    "Mother's Height (cm)"
lab var bmi       "Mother's BMI"
lab var underweig "Mother is underweight"
lab var obese     "Mother is obese"
lab var educf     "Mother's Education"
lab var twind100  "Percent Twin Births"
lab var prenateD  "Attended Births in Area (\% Doctor)"
lab var prenateNu "Attended Births in Area (\% Nurse)"
lab var prenateAn "Attended Births in Area (\% Any)"
lab var noObese   "Mother is not obese"
lab var noUweight "Mother is not underweight"

factor height noObese noUweight prenateD prenateNu prenateAn, factor(3)
predict healthMom
#delimit ;
esttab using "$OUT/factorsDHS.tex", booktabs label  noobs nonumber nomtitle
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t) Psi[Uniqueness]") nogap replace;
#delimit cr
egen healthMomZ = std(healthMom)

regress healthMomZ twind
outreg2 using "$OUT/factorResults.xls", replace


********************************************************************************
*** (2b) DHS Sum Stats
********************************************************************************

local ovar height bmi educf prenateDoctorC prenateNurseC prenateNoneC
local ovar height underweight obese educf prenateDoctorC prenateNurseC prenateAnyC

gen a=1

estpost sum `ovar' twind100 agemay a, casewise
estout using "$OUT/DHSSum.tex", replace label style(tex) `statform' 

********************************************************************************
*** (2c) DHS Regressions: Conditional and Unconditional, Standardised and Not
********************************************************************************
local Zvar Z_heigh Z_underweight Z_obese Z_educf Z_prenateDoctorC  /*
*/         Z_prenateNurseC Z_prenateAnyC
local cs      i.agemay
local regopts abs(country) cluster(id)

foreach var of varlist `ovar' {
    egen mean_`var' = mean(`var')
    egen sd_`var'   = sd(`var')
                 
    gen Z_`var' = (`var' - mean_`var')/sd_`var'
    drop mean_`var' sd_`var'
}

gen varname = ""
foreach estimand in beta se uCI lCI obs {
    gen `estimand'_std_cond  = .
    gen `estimand'_non_cond  = .
    gen `estimand'_std_ucond = .
    gen `estimand'_non_ucond = .
    gen `estimand'_probit    = .
}

areg twind100 `ovar' `cs', `regopts'
keep if e(sample)
local counter = 1
foreach var of varlist `ovar' {
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
*/ in 1/`counter' using "$REG/DHS_est_non_cond.csv", delimit(";") replace


areg twind100 `Zvar' `cs', `regopts'
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
*/ in 1/`counter' using "$REG/DHS_est_std_cond.csv", delimit(";") replace


local counter = 1
dis "Unstandardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `ovar' {
    qui areg twind100 `var' `cs', `regopts'
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
*/ in 1/`counter' using "$REG/DHS_est_non_ucond.csv", delimit(";") replace


local counter = 1
dis "Standardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zvar' {
    qui areg twind100 `var' `cs', `regopts'
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
*/ in 1/`counter' using "$REG/DHS_est_std_ucond.csv", delimit(";") replace

local counter = 1
dis "Standardised Unconditional Probit"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zvar' {
    qui probit twind100 `var' `cs' i._cou, cluster(id)
    margins, dydx(`var') post
    local nobs = e(N)
    local beta = _b[`var']
    local se   = _se[`var']
    local uCI  = `beta'+invttail(`nobs',0.025)*`se')
    local lCI  = `beta'-invttail(`nobs',0.025)*`se')

    qui replace  obs_probit = `nobs' in `counter'
    qui replace beta_probit = `beta' in `counter'
    qui replace   se_probit = `se'   in `counter'
    qui replace  uCI_probit = `uCI'  in `counter'
    qui replace  lCI_probit = `lCI'  in `counter'

    dis "`var';`beta';`se';`lCI';`uCI';`nobs'"        
    local ++counter
}
outsheet varname beta_probit se_probit uCI_probit lCI_probit /*
*/ in 1/`counter' using "$REG/DHS_est_probit.csv", delimit(";") replace


********************************************************************************
*** (2d) DHS Regressions: 1 per country
********************************************************************************
gen countryName = ""
gen surveyYear  = .
foreach var in height educf {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .

    bys country: egen Mean = mean(`var')
    bys country: egen SDev = sd(`var')
    gen `var'_std = (`var'-Mean)/SDev
    drop Mean SDev
}
foreach var in height_std educf_std {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .
}

gen twinProp = .
destring _year, gen(yearint)

local iter = 1
foreach c of local cc {
    if `"`c'"'=="Indonesia"|`"`c'"'=="Pakistan"|`"`c'"'=="Paraguay"      exit
    if `"`c'"'=="Philippines"|`"`c'"'=="South-Africa"|`"`c'"'=="Ukraine" exit
    if `"`c'"'=="Vietnam"|`"`c'"'=="Yemen" exit

    qui replace countryName = "`c'" in `iter'
    sum twind [aw=sweight] if country == "`c'"
    replace twinProp = `r(mean)' if countryName == "`c'"
    sum yearint [aw=sweight] if country == "`c'"
    replace surveyYear = `r(mean)' if countryName == "`c'"
    
    foreach var in height educf height_std educf_std {
        qui areg `var' twindfamily i.fert if country=="`c'", abs(motherage)
        local nobs  = e(N)
        local estl `=_b[twindfamily]-invttail(`nobs',0.025)*_se[twindfamily]'
        local estu `=_b[twindfamily]+invttail(`nobs',0.025)*_se[twindfamily]'
        dis "country is `c', 95% CI for `var' is [`estl',`estu']"
        
        qui replace `var'Est   = _b[twindfamily] in `iter'
        qui replace `var'LB    = `estl' in `iter'
        qui replace `var'UB    = `estu' in `iter'
    }
    local ++iter
}
dis "Number of countries: `iter'"

keep in 1/`iter'
keep countryName heightEst heightLB heightUB educfEst educfLB educfUB         /*
*/ height_stdEst height_stdLB height_stdUB educf_stdEst educf_stdLB           /*
*/ educf_stdUB twinProp surveyYear
outsheet using "$OUT/countryEstimatesDHS.csv", comma replace


********************************************************************************
*** (3a) USA Setup
********************************************************************************
set seed 543
foreach year of numlist 2009(1)2013 {
    use "$USA/natl`year'", clear
    keep if mager>=18&mager<=49
    gen twin     = dplural == 2 if dplural < 3
    gen twin100  = twin*100
    gen heightcm = m_ht_in*2.54 if m_ht_in!=99
    gen smoke0   = cig_0>0 if cig_0<=98
    gen smoke1   = cig_1>0 if cig_1<=98
    gen smoke2   = cig_2>0 if cig_2<=98
    gen smoke3   = cig_3>0 if cig_3<=98
    gen infert   = rf_inftr=="Y" if rf_inftr!="U" & rf_inftr!=""
    gen ART      = rf_artec=="Y" if rf_artec!="U" & rf_artec!=""
    gen fertDrug = rf_fedrg=="Y" if rf_fedrg!="U" & rf_fedrg!=""
    gen diabetes = rf_diab =="Y" if rf_diab !="U" & rf_diab !=""
    gen gestDiab = rf_gest =="Y" if rf_gest !="U" & rf_gest !=""
    gen eclampsia= rf_eclam=="Y" if rf_eclam!="U" & rf_eclam!=""
    gen hypertens= rf_phyp =="Y" if rf_phyp !="U" & rf_phyp !=""
    gen pregHyper= rf_ghyp =="Y" if rf_ghyp !="U" & rf_ghyp !=""
    gen married  = mar==1 if mar!=.
    gen gestation=estgest if estgest>19 & estgest<46
    gen birthweight = dbwt if dbwt<6500&dbwt>500
    gen year = `year'
    gen nonmissing = smoke1!=.&hypertens!=.&heightcm!=.&meduc!=.
    gen underweight = bmi<18.5 if bmi<99
    gen obese       = bmi>30 if bmi<99

    preserve
    keep if infert==1
    tempfile i`year'
    save `i`year''
    restore
    
    keep if infert==0
    tempfile t`year'
    gen bin=runiform()
    tab twin if ART==0&nonmissing==1
    keep if bin>0.90
    save `t`year''
}

clear
append using `t2009' `t2010' `t2011' `t2012' `t2013'

tab twin

preserve
sum twin
local proptwin = r(mean) 
collapse twin, by(lbo_rec)
#delimit ;
line twin lbo_rec if lbo_rec<7, scheme(s1mono) lpattern(dash)
yline(`proptwin', lcolor(red)) ytitle("Fraction Twins") xtitle("Birth Order");
graph export "$GRA/twinBordUSA.eps", as(eps) replace;
#delimit cr
restore

#delimit ;
twoway kdensity birthweight if twin==1, lwidth(thick) lcolor(black)
   ||  kdensity birthweight if twin==0, lpattern(dash) lcolor(black)
lwidth(thick) legend(lab(1 "Twins") lab(2 "Singletons")) ytitle("Fraction")
xtitle("Birth Weight") scheme(s1mono);
graph export "$GRA/birthweightUSA.eps", as(eps) replace;
#delimit cr
exit

lab var heightcm "Mother's height (cm)"
lab var meduc    "Mother's education (years)"
lab var smoke0   "Mother Smoked Before Pregnancy"
lab var smoke1   "Mother Smoked in 1st Trimester" 
lab var smoke2   "Mother Smoked in 2nd Trimester" 
lab var smoke3   "Mother Smoked in 3rd Trimester" 
lab var diabet   "Mother had pre-pregnancy diabetes"
lab var gestDia  "Mother had gestational diabetes"
lab var hyperten "Mother had pre-pregnancy hypertension"
lab var pregHyp  "Mother had pregnancy-associated hypertension"
lab var married  "Mother is married"
lab var obese    "Mother is obese (pre-pregnancy)"
lab var underwei "Mother is underweight (pre-pregnancy)"
lab var mager    "Mother's Age in years"
lab var twin100  "Percent Twin Births"

foreach v of varlist smoke* diabet hyperten obese underw {
    gen INV_`v'=`v'==0 if `v'!=.
}
lab var INV_smoke0   "Mother Didn't Smoke Before Pregnancy"
lab var INV_smoke1   "Mother Didn't Smoke in Trimester 1" 
lab var INV_smoke2   "Mother Didn't Smoke in Trimester 2"  
lab var INV_smoke3   "Mother Didn't Smoke in Trimester 3" 
lab var INV_diabet   "Mother Didn't have pre-pregnancy diabetes"
lab var INV_hyperten "Mother Didn't have pre-pregnancy hypertension"
lab var INV_obese    "Mother was not obese (pre-pregnancy)"
lab var INV_underwei "Mother was not underweight (pre-pregnancy)"


factor heightcm INV_*, factor(3)
#delimit ;
esttab using "$OUT/factorsUSA.tex", booktabs label noobs nonumber nomtitle
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t) Psi[Uniqueness]") nogap replace;
#delimit cr

predict healthMom
egen healthMomZ = std(healthMom)

gen twind=twin
regress healthMomZ twind
exit
outreg2 using "$OUT/factorResults.xls", append




********************************************************************************
*** (3b) USA Sum Stats
********************************************************************************
local usv heightcm meduc smoke0 smoke1 smoke2 smoke3 diabetes hypertens /*
*/        underweight obese
gen a=1

estpost sum `usv' twin100 mager a, casewise
estout using "$OUT/USASum.tex", replace label style(tex) `statform'

********************************************************************************
*** (3c) USA Regressions: Conditional and Unconditional, Standardised and Not
********************************************************************************
local Zusv Z_heightcm Z_meduc Z_smoke0 Z_smoke1 Z_smoke2 Z_smoke3 Z_diab  /*
*/         Z_hyper Z_underweight Z_obese
local FEs i.mbrace i.lbo_rec i.year i.gestation married
local regopts abs(mager) robust


foreach var of varlist `usv' {
    egen mean_`var' = mean(`var')
    egen sd_`var'   = sd(`var')
                 
    gen Z_`var' = (`var' - mean_`var')/sd_`var'
    drop mean_`var' sd_`var'
}

gen varname = ""
foreach estimand in beta se uCI lCI obs {
    gen `estimand'_std_cond  = .
    gen `estimand'_non_cond  = .
    gen `estimand'_std_ucond = .
    gen `estimand'_non_ucond = .
    gen `estimand'_probit    = .    
}

egen allsmoke = rownonmiss(smoke0 smoke1 smoke2 smoke3)
areg birthweight smoke0 `FEs' if allsmoke==4, `regopts'
outreg2 using "$REG/bwtSmoke.xls", keep(smoke0) replace
areg birthweight smoke1 `FEs' if allsmoke==4, `regopts'
outreg2 using "$REG/bwtSmoke.xls", keep(smoke1) append
areg birthweight smoke2 `FEs' if allsmoke==4, `regopts'
outreg2 using "$REG/bwtSmoke.xls", keep(smoke2) append
areg birthweight smoke3 `FEs' if allsmoke==4, `regopts'
outreg2 using "$REG/bwtSmoke.xls", keep(smoke3) append
foreach num of numlist 0 1 {
    areg birthweight smoke0 `FEs' if twin==`num'&allsmoke==4, `regopts'
    outreg2 using "$REG/bwtSmoke_twin`num'.xls", keep(smoke0) append
    areg birthweight smoke1 `FEs' if twin==`num'&allsmoke==4, `regopts'
    outreg2 using "$REG/bwtSmoke_twin`num'.xls", keep(smoke1) append
    areg birthweight smoke2 `FEs' if twin==`num'&allsmoke==4, `regopts'
    outreg2 using "$REG/bwtSmoke_twin`num'.xls", keep(smoke2) append
    areg birthweight smoke3 `FEs' if twin==`num'&allsmoke==4, `regopts'
    outreg2 using "$REG/bwtSmoke_twin`num'.xls", keep(smoke3) append
}
exit

areg twin100 `usv' `FEs', `regopts'
keep if e(sample)
local counter = 1
foreach var of varlist `usv' {
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
*/ in 1/`counter' using "$REG/USA_est_non_cond.csv", delimit(";") replace


areg twin100 `Zusv' `FEs', `regopts'
local counter = 1
foreach var of varlist `Zusv' {
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
*/ in 1/`counter' using "$REG/USA_est_std_cond.csv", delimit(";") replace


local counter = 1
dis "Unstandardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `usv' {
    qui areg twin100 `var' `FEs', `regopts'
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
*/ in 1/`counter' using "$REG/USA_est_non_ucond.csv", delimit(";") replace


local counter = 1
dis "Standardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zusv' {
    qui areg twin100 `var' `FEs', `regopts'
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
*/ in 1/`counter' using "$REG/USA_est_std_ucond.csv", delimit(";") replace

local counter = 1
dis "Standardised Unconditional Probit"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zusv' {
    qui probit twin100 `var' `FEs' i.mager
    margins, dydx(`var') post
    local nobs = e(N)
    local beta =   _b[`var']
    local se   =  _se[`var']
    local uCI  =  (`beta'+invttail(`nobs',0.025)*`se')
    local lCI  =  (`beta'-invttail(`nobs',0.025)*`se')

    qui replace  obs_probit = `nobs' in `counter'
    qui replace beta_probit = `beta' in `counter'
    qui replace   se_probit = `se'   in `counter'
    qui replace  uCI_probit = `uCI'  in `counter'
    qui replace  lCI_probit = `lCI'  in `counter'

    dis "`var';`beta';`se';`lCI';`uCI';`nobs'"        
    local ++counter
}
outsheet varname beta_probit se_probit uCI_probit lCI_probit /*
*/ in 1/`counter' using "$REG/USA_est_probit.csv", delimit(";") replace


********************************************************************************
*** (3d) USA Regressions: Twin Dif
********************************************************************************
gen countryName = "USA"
gen surveyYear  = 2011
rename heightcm height
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
gen twind = twin100/100

gen yearint = 2011

sum twind 
replace twinProp = `r(mean)' 
gen fert = lbo_rec
foreach var in height educf height_std educf_std {
    qui areg `var' twind i.fert, abs(mager)
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
outsheet using "$OUT/countryEstimatesUSA.csv", comma replace

********************************************************************************
*** (3e) USA Regressions for IVF users
********************************************************************************
clear
append using `i2009' `i2010' `i2011' `i2012' `i2013'

tab twin
exit
lab var heightcm "Mother's height (cm)"
lab var meduc    "Mother's education (years)"
lab var smoke0   "Mother Smoked Before Pregnancy"
lab var smoke1   "Mother Smoked in 1st Trimester" 
lab var smoke2   "Mother Smoked in 2nd Trimester" 
lab var smoke3   "Mother Smoked in 3rd Trimester" 
lab var diabet   "Mother had pre-pregnancy diabetes"
lab var gestDia  "Mother had gestational diabetes"
lab var hyperten "Mother had pre-pregnancy hypertension"
lab var pregHyp  "Mother had pregnancy-associated hypertension"
lab var married  "Mother is married"
lab var obese    "Mother is obese (pre-pregnancy)"
lab var underwei "Mother is underweight (pre-pregnancy)"
lab var mager    "Mother's Age in years"
lab var twin100  "Percent Twin Births"


local usv heightcm meduc smoke0 smoke1 smoke2 smoke3 diabetes hypertens /*
*/        underweight obese
local Zusv Z_heightcm Z_meduc Z_smoke0 Z_smoke1 Z_smoke2 Z_smoke3 Z_diab  /*
*/         Z_hyper Z_underweight Z_obese
local FEs i.mbrace i.lbo_rec i.year i.gestation married
local regopts abs(mager) robust


foreach var of varlist `usv' {
    egen mean_`var' = mean(`var')
    egen sd_`var'   = sd(`var')
                 
    gen Z_`var' = (`var' - mean_`var')/sd_`var'
    drop mean_`var' sd_`var'
}

gen varname = ""
foreach estimand in beta se uCI lCI obs {
    gen `estimand'_std_cond  = .
    gen `estimand'_non_cond  = .
    gen `estimand'_std_ucond = .
    gen `estimand'_non_ucond = .
}

areg twin100 `usv' `FEs', `regopts'
keep if e(sample)
local counter = 1
foreach var of varlist `usv' {
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
*/ in 1/`counter' using "$REG/USA_est_non_cond_IVF.csv", delimit(";") replace


local counter = 1
dis "Standardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zusv' {
    qui areg twin100 `var' `FEs', `regopts'
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
*/ in 1/`counter' using "$REG/USA_est_std_ucond_IVF.csv", delimit(";") replace

*/
********************************************************************************
*** (4a) Chile Setup
********************************************************************************
use "$DAT/Chile_twins", clear
#delimit ;
local base    indigenous ypc ypc2;
local region  i.region i.age rural i.m_age_birth i.birthorder;
local cond    a16==13&m_age_birth<=49;
local wt      [pw=fexp_enc];
local prePreg obesePre lowWeightPre meduc;
local preg    pregDiab pregDepr pregSmoked pregDrugsModerate pregDrugsHigh
              pregAlcoholModerate pregAlcoholHigh pregHosp;
local pregS   pregSmoked pregDrugsModerate pregDrugsHigh
              pregAlcoholModerate pregAlcoholHigh;
#delimit cr

keep if m_age_birth >=18&m_age_birth<=49
gen twind = twin*100
recode mother_educ (1/2=0) (3=4) (4=10) (5=12) (6=13) (7/8=14) (9=16), gen(meduc)


lab var pregSmoked    "Mother Smoked During Pregnancy"
lab var pregDrugsMod  "Drugs During Pregnancy (Sporadically)"
lab var pregDrugsHigh "Drugs During Pregnancy (Regularly)"
lab var pregAlcoholM  "Alcohol During Pregnancy (Sporadically)"
lab var pregAlcoholHi "Alcohol During Pregnancy (Regularly)"
lab var obesePre      "Mother Obese Prior to Pregnancy"
lab var lowWeightPre  "Mother Low Weight Prior to Pregnancy"
lab var twind         "Percent Twin Births"
lab var m_age_birth   "Mother's Age in Years"
lab var meduc         "Mother's Education in Years"
/*
********************************************************************************
*** (4b) Chile Sum Stats
********************************************************************************
gen a=1
estpost sum `pregS' `prePreg' twind m_age_birth a if `cond', listwise
estout using "$OUT/ChileSum.tex", replace label style(tex) `statform'


foreach v of varlist `pregS' lowWeightPre obesePre {
    gen INV_`v'=`v'==0 if `v'!=.
}
    
factor INV_*, factor(3)
#delimit ;
esttab using "$OUT/factorsChile.tex", booktabs label noobs nonumber nomtitle
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t) Psi[Uniqueness]") nogap replace;
#delimit cr

predict healthMom
egen healthMomZ = std(healthMom)

regress healthMomZ twind
outreg2 using "$OUT/factorResults.xls", append
*/

********************************************************************************
*** (4c) Chile Regressions
********************************************************************************
local Zchi Z_pregSmoked Z_pregDrugsModerate Z_pregDrugsHigh Z_pregAlcoholModerate/*
*/ Z_pregAlcoholHigh Z_obesePre Z_lowWeightPre Z_meduc 


*eststo: reg twind `region' `prePreg' `preg' `base' `wt' if `cond' 

foreach var of varlist `pregS' `prePreg' {
    egen mean_`var' = mean(`var')
    egen sd_`var'   = sd(`var')
                 
    gen Z_`var' = (`var' - mean_`var')/sd_`var'
    drop mean_`var' sd_`var'
}

gen varname = ""
foreach estimand in beta se uCI lCI obs {
    gen `estimand'_std_cond  = .
    gen `estimand'_non_cond  = .
    gen `estimand'_std_ucond = .
    gen `estimand'_non_ucond = .
    gen `estimand'_probit    = .
}

gen ypc2 = ypc^2
reg twind `region' `pregS' `prePreg' `base' `wt' if `cond'

keep if e(sample)
local counter = 1
foreach var of varlist `pregS' `prePreg' {
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
*/ in 1/`counter' using "$REG/CHI_est_non_cond.csv", delimit(";") replace


reg twind `region' `Zchi' `base' `wt' if `cond'
exit
local counter = 1
foreach var of varlist `Zchi' {
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
*/ in 1/`counter' using "$REG/CHI_est_std_cond.csv", delimit(";") replace


local counter = 1
dis "Unstandardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `pregS' `prePreg' {
    qui reg twind `region' `var' `base' `wt' if `cond' 
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
*/ in 1/`counter' using "$REG/CHI_est_non_ucond.csv", delimit(";") replace


local counter = 1
dis "Standardised Unconditional"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zchi' {
    qui reg twind `region' `var' `base' `wt' if `cond' 
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
*/ in 1/`counter' using "$REG/CHI_est_std_ucond.csv", delimit(";") replace

local counter = 1
dis "Standardised Unconditional Probit"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `Zchi' {
    qui probit twind `region' `var' `base' `wt' if `cond' 
    margins, dydx(`var') post
    local nobs = e(N)
    local beta =  _b[`var']
    local se   = _se[`var']
    local uCI  = `beta'+invttail(`nobs',0.025)*`se'
    local lCI  = `beta'-invttail(`nobs',0.025)*`se'

    qui replace  obs_probit = `nobs' in `counter'
    qui replace beta_probit = `beta' in `counter'
    qui replace   se_probit = `se'   in `counter'
    qui replace  uCI_probit = `uCI'  in `counter'
    qui replace  lCI_probit = `lCI'  in `counter'

    dis "`var';`beta';`se';`lCI';`uCI';`nobs'"        
    local ++counter
}
outsheet varname beta_probit se_probit uCI_probit lCI_probit /*
*/ in 1/`counter' using "$REG/CHI_est_probit.csv", delimit(";") replace
exit

********************************************************************************
*** (5) Figures
********************************************************************************
use "$DAT/GDPpc_WorldBank", clear
keep if year==2013
tempfile GDP
save `GDP', replace

insheet using "$OUT/countryEstimatesUSA.csv", comma names clear
tempfile USA
save `USA', replace

insheet using "$OUT/countryEstimatesSWE.csv", comma names clear
tempfile SWE
save `SWE', replace

insheet using "$OUT/countryEstimates.csv", comma names clear
append  using  `USA' `SWE'

gsort -heightest
gen numb = _n
encode countryname, gen(cc)
drop if cc==.

replace countryname=subinstr(countryname, "-", " ", .)
replace countryname= "Congo, Dem. Rep." if countryname == "Congo Democratic Republic"
replace countryname= "United States"    if countryname == "USA"
replace countryname= "Congo, Rep."      if countryname == "Congo Brazzaville"
replace countryname= "Cote d'Ivoire"    if countryname == "Cote d Ivoire"
replace countryname= "Egypt, Arab Rep." if countryname == "Egypt"
merge 1:1 countryname using `GDP'
keep if _merge==3


gen logGDP = log(ny_gdp_pcap_cd)
encode regioncode, gen(rc)
gen rcode = rc
rename heightest heightEst
rename educfest educfEst
rename height_stdest height_stdEst
rename educf_stdest  educf_stdEst
rename twinprop twinProp
local outvars heightEst educfEst height_stdEst educf_stdEst twinProp logGDP rcode
outsheet `outvars' using "$OUT/countryEstimatesGDP.csv", comma replace

format heightEst      %9.2f
format heightlb       %9.2f
format heightub       %9.2f
format educfEst       %9.2f
format educflb        %9.2f
format educfub        %9.2f
format logGDP         %9.2f

#delimit ;
eclplot heightEst heightlb heightub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Height Difference (cm)" "twin - non-twin")
xlabel(1  "Guyana"            2  "Brazil"      3  "Maldives"      4  "Sierra Leone"
       5  "Azerbaijan"        6  "Sao Tome"    7  "Albania"       8  "CAR"
       9  "Guatemala"         10 "Ghana"       11 "Dom. Rep."     12 "Mozambique"
       13 "USA"               14 "Kyrgyz Rep." 15 "Colombia"      16 "Honduras"
       17 "Burundi"           18 "DRC"         19 "Gabon"         20 "Ethiopia"
       21 "Jordan"            22 "Namibia"     23 "Nepal"         24 "Peru"
       25 "Lesotho"           26 "Sweden"      27 "Bolivia"       28 "Malawi"
       29 "Nicaragua"         30 "Togo"        31 "Moldova"       32 "Turkey"
       33 "Congo Brazzaville" 34 "Uganda"      35 "Kazakhstan"    36 "Comoros"
       37 "Rwanda"            38 "Swaziland"   39 "Cote D'Ivoire" 40 "Mali"
       41 "Egypt"             42 "Morocco"     43 "Cameroon"      44 "India"
       45 "Haiti"             46 "Tanzania"    47 "Armenia"       48 "Burkina Faso"
       49 "Nigeria"           50 "Madagascar"  51 "Niger"         52 "Kenya"
       53 "Bangladesh"        54 "Zambia"      55 "Senegal"       56 "Chad"
       57 "Liberia"           58 "Guinea"      59 "Zimbabwe"      60 "Benin"
       61 "Cambodia"          62 "Uzbekistan",angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/HeightDif.eps", as(eps) replace

drop numb
gsort -height_stdEst
gen numb = _n
#delimit ;
eclplot height_stdEst height_stdlb height_stdub numb, scheme(s1mono)
estopts(mcolor(black)) ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ylabel(-0.2(0.2)0.4)
ytitle("Standardised Height Difference (cm)" "twin - non-twin")
xlabel(1  "        Brazil" 2  "Guyana"        3  "Maldives"     4 "Azerbaijan"
       5  "Guatemala"      6 "Kyrgyz Rep."    7  "Albania"      8 "CAR"  
       9  "Dom. Rep."     10 "Mozambique"    11 "Ghana"        12 "Colombia"
       13 "Sao Tome"      14 "Honduras"      15 "Burundi"      16 "USA" 
       17 "Nepal"         18 "Gabon"         19 "Jordan"       20 "Ethiopia"
       21 "Peru"          22 "Sierra Leone"  23 "Bolivia"      24 "DRC"
       25 "Turkey"        26 "Malawi"        27 "Namibia"      28 "Sweden"
       29 "Nicaragua"     30 "Lesotho"       31 "Togo"         32 "Moldova"
       33 "Kazakhstan"    34 "Comoros"       35 "Uganda"       36 "Swaziland"
       37 "Cote D'Ivoire" 38  "Rwanda"       39 "Egypt"        40 "Congo Rep."
       41 "Morocco"       42 "Mali"          43 "India"        44 "Armenia"
       45 "Cameroon"      46 "Haiti"         47 "Tanzania"     48 "Burkina Faso"
       49 "Madagascar"    50 "Bangladesh"    51 "Niger"        52 "Kenya"  
       53 "Zambia"        54 "Nigeria"       55 "Senegal"      56 "Chad"
       57 "Liberia"       58 "Guinea"        59 "Zimbabwe"     60 "Benin"
       61 "Cambodia"      62 "Uzbekistan",angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/HeightStdDif.eps", as(eps) replace


drop numb
gsort -educfEst
gen numb = _n
#delimit ;
eclplot educfEst educflb educfub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Education Difference (years)" "twin - non-twin")
xlabel(1  "Cameroon"    2  "Nigeria"           3  "Burundi"      4  "Ghana"
       5  "India"       6  "Peru"              7  "Dom. Rep."    8  "Bolivia"
       9  "Kenya"       10 "Egypt"             11 "Colombia"     12 "Brazil"
       13 "Maldives"    14 "Jordan"            15 "Malawi"       16 "Tanzania"
       17 "Azerbaijan"  18 "Guyana"            19 "Bangladesh"   20 "Honduras"
       21 "Turkey"      22 "Zimbabwe"          23 "Albania"      24 "Moldova"
       25 "Nepal"       26 "Gabon"             27 "Cambodia"     28 "Comoros"
       29 "Nicaragua"   30 "Mozambique"        31 "Armenia"      32 "CAR"
       33 "Madagascar"  34 "Congo Brazzaville" 35 "Zambia"       36 "Sao Tome"
       37 "Uzbekistan"  38 "Ethiopia"          39 "USA"          40 "Haiti"
       41 "Benin"       42 "Rwanda"            43 "Uganda"       44 "Togo"
       45 "Kazakhstan"  46 "Chad"              47 "Niger"        48 "Mali" 
       49 "Senegal"     50 "Cote D'Ivoire"     51 "Guatemala"    52 "Liberia"
       53 "DRC"         54 "Morocco"           55 "Burkina Faso" 56 "Namibia"
       57 "Guinea"      58 "Sierra Leone"      59 "Lesotho"      60 "Swaziland"
       61 "Kyrgyz Rep.",angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/EducDif.eps", as(eps) replace

drop numb
gsort -educf_stdEst
gen numb = _n
#delimit ;
eclplot educf_stdEst educf_stdlb educf_stdub numb, scheme(s1mono)
estopts(mcolor(black)) ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Standardised Education Difference (years)" "twin - non-twin")
xlabel(1  "Cameroon"  2  "Burundi"        3  "Nigeria"       4  "Azerbaijan"
       5  "Ghana"     6  "Kenya"          7  "Peru"          8  "Moldova"   
       9  "Brazil"    10 "India"          11 "Dom. Rep."     12 "Bolivia"
       13 "Guyana"    14 "Malawi"         15 "Colombia"      16 "Albania"
       17 "Maldives"  18 "Uzbekistan"     19 "Tanzania"      20 "USA"
       21 "Nepal"     22 "Cambodia"       23 "Bangladesh"    24 "Armenia" 
       25 "Egypt"     26 "Jordan"         27 "Gabon"         28 "Honduras"
       29 "Zimbabwe"  30 "Turkey"         31 "Comoros"       32 "Mozambique"
       33 "CAR"       34 "Sao Tome"       35 "Ethiopia"      36 "Nicaragua"
       37 "Zambia"    38 "Congo Republic" 39 "Benin"         40 "Madagascar"
       41 "Togo"      42 "Kazakhstan"     43 "Chad"          44 "Haiti" 
       45 "Rwanda"    46 "Niger"          47 "Uganda"        48 "Mali" 
       49 "Senegal"   50 "Guatemala"      51 "Cote D'Ivoire" 52 "Morocco"
       53 "Liberia"   54 "DRC"            55 "Burkina Faso"  56 "Namibia"
       57 "Guinea"    58 "Sierra Leone"   59 "Swaziland"     60 "Lesotho"
       61 "Kyrgyz Rep.",angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/EducStdDif.eps", as(eps) replace


reg educfEst i.rcode
predict eResid, resid
reg logGDP i.rcode
predict gResid, resid
reg heightEst i.rcode
predict hResid, resid
reg educf_stdEst i.rcode
predict esResid, resid
reg height_stdEst i.rcode
predict hsResid, resid

corr eResid gResid
corr hResid gResid
corr esResid gResid
corr hsResid gResid
exit

reg educfEst  logGDP i.rcode, robust
reg heightEst logGDP i.rcode, robust
reg educf_sdEst  logGDP i.rcode, robust
reg height_sdtEst logGDP i.rcode, robust

*/
********************************************************************************
*** (6) Coverage
********************************************************************************
use "$DAT/world/world"
#delimit ;
drop if NAME=="Aruba"|NAME=="Aland"|NAME=="American Samoa"|NAME=="Antarctica";
drop if NAME=="Ashmore and Cartier Is."|NAME=="Fr. S. Antarctic Lands";
drop if NAME=="Bajo Nuevo Bank (Petrel Is.)"|NAME=="Clipperton I.";
drop if NAME=="Cyprus U.N. Buffer Zone"|NAME=="Cook Is."|NAME=="Coral Sea Is.";
drop if NAME=="Cayman Is."|NAME=="N. Cyprus"|NAME=="Dhekelia"|NAME=="Falkland Is.";
drop if NAME=="Faeroe Is."|NAME=="Micronesia"|NAME=="Guernsey";
drop if NAME=="Heard I. and McDonald Is."|NAME=="Isle of Man"|NAME=="Indian Ocean Ter.";
drop if NAME=="Br. Indian Ocean Ter."|NAME=="Baikonur"|NAME=="Siachen Glacier";
drop if NAME=="St. Kitts and Nevis"|NAME=="Saint Lucia"|NAME=="St-Martin";
drop if NAME=="Marshall Is."|NAME=="N. Mariana Is."|NAME=="New Caledonia";
drop if NAME=="Norfolk Island"|NAME=="Niue"|NAME=="Nauru"|NAME=="Pitcairn Is.";
drop if NAME=="Spratly Is."|NAME=="Fr. Polynesia"|NAME=="Scarborough Reef";
drop if NAME=="Serranilla Bank"|NAME=="S. Geo. and S. Sandw. Is."|NAME=="San Marino";
drop if NAME=="St. Pierre and Miquelon"|NAME=="Sint Maarten"|NAME=="Seychelles";
drop if NAME=="Turks and Caicos Is."|NAME=="U.S. Minor Outlying Is.";
drop if NAME=="St. Vin. and Gren."|NAME=="British Virgin Is.";
drop if NAME=="USNB Guantanamo Bay"|NAME=="Wallis and Futuna Is."|NAME=="Akrotiri";
drop if NAME=="Antigua and Barb."|NAME=="Bermuda"|NAME=="Kiribati"|NAME=="St-Barthélemy";
drop if NAME=="Curaçao"|NAME=="Dominica"|NAME=="Guam";
drop if NAME=="Malta"|NAME=="Montserrat"|NAME=="Palau"|NAME=="Mauritius";
drop if NAME=="Tonga"|NAME=="Trinidad and Tobago";
drop if NAME=="Tuvalu"|NAME=="U.S. Virgin Is."|NAME=="Vanuatu";

generat coverage=3 if NAME=="Albania"|NAME=="Azerbaijan"|NAME=="Armenia";
replace coverage=3 if NAME=="Brazil"|NAME=="Bolivia"|NAME=="Burundi";
replace coverage=3 if NAME=="Burkina Faso"|NAME=="Benin"|NAME=="Bangladesh";
replace coverage=3 if NAME=="Central African Rep."|NAME=="Colombia"|NAME=="Chad";
replace coverage=3 if NAME=="Comoros"|NAME=="Cambodia"|NAME=="Côte d'Ivoire";
replace coverage=3 if NAME=="Cameroon"|NAME=="Congo"|NAME=="Dem. Rep. Congo";
replace coverage=3 if NAME=="Dominican Rep."|NAME=="Egypt"|NAME=="Ethiopia";
replace coverage=3 if NAME=="Kyrgyzstan"|NAME=="Kazakhstan"|NAME=="Jordan";
replace coverage=3 if NAME=="Guatemala"|NAME=="Ghana"|NAME=="Gabon"|NAME=="Guinea";
replace coverage=3 if NAME=="Honduras"|NAME=="Haiti"|NAME=="Guyana"|NAME=="India";
replace coverage=3 if NAME=="Lesotho"|NAME=="Liberia"|NAME=="Mali"|NAME=="Malawi";
replace coverage=3 if NAME=="Maldives"|NAME=="Mozambique"|NAME=="Moldova";
replace coverage=3 if NAME=="Morocco"|NAME=="Madagascar"|NAME=="Nicaragua";
replace coverage=3 if NAME=="Namibia"|NAME=="Nepal"|NAME=="Nigeria"|NAME=="Niger";
replace coverage=3 if NAME=="Peru"|NAME=="Rwanda"|NAME=="Sierra Leone";
replace coverage=3 if NAME=="São Tomé and Principe"|NAME=="Swaziland";
replace coverage=3 if NAME=="Senegal"|NAME=="Togo"|NAME=="Turkey"|NAME=="Tanzania"; 
replace coverage=3 if NAME=="Uganda"|NAME=="Uzbekistan"|NAME=="Zambia";
replace coverage=3 if NAME=="Zimbabwe"|NAME=="Kenya";

replace coverage=1 if NAME=="United States"|NAME=="Sweden";
replace coverage=2 if NAME=="United Kingdom";
replace coverage=4 if NAME=="Chile";
replace coverage=5 if NAME=="Spain"|NAME=="Mexico"|NAME=="Ireland";
replace coverage=6 if NAME=="Romania";

spmap coverage using "$DAT/world/world_coords" , id(_ID) osize(vvthin)
fcolor(Rainbow) clmethod(unique) clbreaks(0 1 2 3 4 5 6)
legend(title("Twin Coverage", size(*1.45) bexpand justification(left)))
legend(label(1 "No Surveys")) legend(label(2 "Full Birth Records"))
legend(label(3 "Surveys (Regional)")) legend(label(4 "Surveys (Demographic)"))
legend(label(5 "Surveys (Early Life)"))
legend(label(6 "Birth Records (No Health Information)"))
legend(label(7 "Survey Data (No Health Information)"))
legend(symy(*1.45) symx(*1.45) size(*1.98))
;

graph export "$GRA/coverage.eps", as(eps) replace;
#delimit cr

********************************************************************************
*** (X) Close
********************************************************************************
cap log close
