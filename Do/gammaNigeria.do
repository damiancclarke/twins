/* gammaEstimate.do v0.00        damiancclarke             yyyy-mm-dd:2015-03-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Estimate gamma for Conley et al method using the USA Sulfanide improvement in m-
aternal health.


*/

vers 11
clear all
set more off
cap log close
set matsize 5000

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/Nigeria"
global DHS "~/database/DHS/DHS_Data/Nigeria/"
global OUT "~/investigacion/Activa/Twins/Results/gamma"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/gammaNigeria.txt", replace text

local gen = 0
local est = 1



********************************************************************************
*** (2a) Prep DHS files to merge in children education
********************************************************************************
use "$DHS/2003/NGPR4CDT"
keep hhid hv001 hv002 hvidx hv106 hv107 hv108 hv109
gen DHSyear = 2003
rename hv001 v001
rename hv002 v002
rename hvidx b16
tempfile person2003
save `person2003'

use "$DHS/2008/NGPR52DT"
keep hhid hv001 hv002 hvidx hv106 hv107 hv108 hv109
gen DHSyear = 2008
rename hv001 v001
rename hv002 v002
rename hvidx b16

append using `person2003'
tempfile person
save `person'


use "$DHS/2003/NGBR4BDT"
gen DHSyear = 2003
keep DHSyear caseid bidx v001 v002 b16
tempfile birth2003
save `birth2003'

use "$DHS/2008/NGBR52DT"
gen DHSyear = 2008
keep DHSyear caseid bidx v001 v002 b16
append using `birth2003'
drop if b16==0|b16==.

merge 1:1 DHSyear v001 v002 b16 using `person'
keep if _merge == 3
drop _merge

save `person', replace


********************************************************************************
*** (2b) Generation
********************************************************************************
use "$DAT/datachild_alldhs", clear
generate DHSyear = 2003 if dhs03==1
replace  DHSyear = 2008 if dhs08==1
replace  DHSyear = 1999 if dhs99==1
replace  DHSyear = 1990 if dhs90==1 
merge 1:1 DHSyear caseid bidx using `person'

gen educYears = hv108 if hv108!=99

bys DHSyear agec: egen meanEd = mean(educYears)
bys DHSyear agec: egen sdEd   = sd(educYears)
gen educZscore = (educYears-meanEd)/sdEd
replace educZscore = . if agec<6

gen agediffmothch=ybc -yrbirth
label var agediffmothch "Age difference mother-child"

replace mort60m=1000 if mort60m==1
replace haz2sd=1000 if haz2sd==1
replace mort12m=1000 if mort12m==1
replace mort1m=1000 if mort1m==1
replace chtwin=1000 if chtwin==1
replace waz2sd=1000 if waz2sd==1

label var pchawrsibst_mexp0 "Months exposure in utero*State mortality"
label var pchawrsibst_mexp1 "Months exposure at ages 0-3*State mortality"
label var pchawrsibst_mexp2 "Months exposure at ages 4-6*State mortality"
label var pchawrsibst_mexp3 "Months exposure at ages 7-12*State mortality"
label var pchawrsibst_mexp4 "Months exposure at ages 13-16*State mortality"
label var pchawrsibet_mexp0 "Months exposure in utero*Ethnic mortality"
label var pchawrsibet_mexp1 "Months exposure at ages 0-3*Ethnic mortality"
label var pchawrsibet_mexp2 "Months exposure at ages 4-6*Ethnic mortality"
label var pchawrsibet_mexp3 "Months exposure at ages 7-12*Ethnic mortality"
label var pchawrsibet_mexp4 "Months exposure at ages 13-16*Ethnic mortality"
label var femalec "Child is female"

gen twin = b0==1|b0==2
bys DHSyear caseid: egen twinM = max(twin)
drop if b0>2


*Under-5 mortality, Under 12-months mortality, under-1 month
keep if ((yrbirth>=1954 & yrbirth<=1974) & dhs03==1)| /*
*/      ((yrbirth>=1958 & yrbirth<=1974) & dhs08==1)| /*
*/      ((yrbirth>=1954 & yrbirth<=1974) & dhs99==1)
keep if bidx!=.  // keep only women that had at least one child
keep if ybc>=1971  // drop children born during or before the war
keep if agec<=18

local lvars mort1m educZscore
local lvars educZscore
local X     mexp0 mexp1 mexp2 mexp3 mexp4
local X1    reg_mexp0 reg_mexp1 reg_mexp2 reg_mexp3 reg_mexp4
local X2    ethn_mexp0 ethn_mexp1 ethn_mexp2 ethn_mexp3 ethn_mexp4
local cont  dhs03 dhs99 i.stcode1970 i.ethn i.ybc i.yrbirth i.stcode1970#c.ybc femalec 
local wt    [pw=sweight]
local se    robust cluster(yearstate)


********************************************************************************
*** (3) Resampling
********************************************************************************
gen twinEst = .
gen qualEst = .
local N = 1000
foreach i of numlist 1(1)`N' {
    set seed `i'
    dis "Cycle `i': qual"
    preserve
    bsample

    reg educZscore `cont' `X' `X2' `wt', `se'
    local phiQ = _b[ethn_mexp0]
    reg mexp0 twinM i.fert `cont' if e(sample)==1&ethnwarexp==1, `se'
    local phiT = _b[twinM]

    restore

    replace qualEst = `phiQ' in `i'
    replace twinEst = `phiT' in `i'
    dis "Gamma estimate is `=`phiQ'*`phiT''"
    sum qualEst twinEst
}

gen gamma = twinEst*qualEst
sum gamma


local Gmean = `r(mean)'
local Gsdev = `r(sd)'
local Gmax  = `r(max)'

********************************************************************************
*** (4) Examine distribution: Kolmogorov-Smirnov
********************************************************************************
tw hist gamma, bin(12) yaxis(2) frac || function normalden(x,`Gmean',`Gsdev'), /*
*/ lc(black) scheme(lean1) range(`=`Gmean'-3*`Gsdev'' `=`Gmean'+3.2*`Gsdev'')    /*
*/ yaxis(1) yscale(range(0 11)) ylabel(none) ytitle(" ") xtitle(" ")           /*
*/ legend(label(1 "Empirical Distribution") label(2 "Analytical Distribution"))
graph export "$OUT/gammaResampNigeria.eps", as(eps) replace


sort gamma
gen lgamma = log(gamma)
sum lgamma
local lm = `r(mean)'
local ls = `r(sd)'

gen x = _n*(`Gmax'/`N')
gen lN =  (1 / x * `ls' * sqrt(2 * _pi)) * exp(-(log(x) - `lm')^2 / (2 *`ls'^2))

tw hist gamma, bin(12) yaxis(2) frac || line lN x, yaxis(1)                  ///
    scheme(lean1) yscale(range(0 43)) ylabel(none) ytitle(" ") xtitle(" ")   ///
    legend(label(1 "Empirical Distribution") label(2 "Analytical Distribution")) 
graph export "$OUT/gammaLogNNigeria.eps", as(eps) replace

ksmirnov gamma = normal((gamma-`Gmean')/`Gsdev')
swilk gamma lgamma

********************************************************************************
*** (9) Clean and clear
********************************************************************************
keep in 1/1000
gen j=_n
keep qualEst twinEst gamma j
save "$OUT/gammasNigeria.dta", replace


log close
