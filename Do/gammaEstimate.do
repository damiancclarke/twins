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
global DAT "~/investigacion/Activa/Twins/Data/IPUMS"
global SUL "~/investigacion/Activa/Twins/Data/"
global OUT "~/investigacion/Activa/Twins/Results/gamma"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/gammaEstimate.txt", replace text

local gen = 0
local est = 1

global post_base_inf p_b_inf
global mortality     p_b_mmr /*p_b_tbr p_b_diar p_b_cancer p_b_heartd p_b_mal*/
global statevar      ln_pci ln_nb_sch_imp ln_ed_exp_imp ln_nb_hos_imp /*
                     */ ln_nb_doc_imp /*i.post*health_exp_pc*/
global cohort        birth_year>=1930&birth_year<=1943
global basic         i.birth_state*i.race i.birth_year*i.race
global trends        i.birth_state*i.race i.birth_year*i.race i.birth_state*t
global trends2       $trends i.birth_state*t_2

********************************************************************************
*** (2) open data and generate child file
********************************************************************************
if `gen'==1 {
    use "$DAT/IPUMS1980"
    gen age = year -birthyr
    keep if momrule == 1 & age <=18
    keep year datanum serial hhwt pernum perwt momloc sex birthqtr birthyr race /*
    */ bpl bpld language speakeng school educ educd grade* schltype
    
    gen birthtime = birthyr+0.25*(birthqtr-1)
    bys year datanum serial momloc: gen ageDif1=birthtime[_n]-birthtime[_n-1]
    bys year datanum serial momloc: gen ageDif2=birthtime[_n]-birthtime[_n+1]
    
    gen twin = ageDif1==0 | ageDif2==0
    tab twin
    tempfile child
    save `child'
    
    ****************************************************************************
    *** (3) open data and generate mother file, merge to children
    ****************************************************************************
    use "$DAT/IPUMS1980"
    keep if nchild>0 & sex==2
    keep year datanum serial pernum perwt birthyr race bpl 
    rename pernum momloc
    
    foreach var of varlist perwt birthyr race bpl {
        rename `var' m`var'
    }
    
    merge 1:m year datanum serial momloc using `child'
    keep if _merge==3
    drop _merge
    
    rename mbirthyr birth_year
    rename mbpl birth_state
    
    ****************************************************************************
    *** (4) Merge in Sulfa data
    ****************************************************************************
    keep if birth_state<=56
    merge m:1 birth_year birth_state using "$SUL/sulfaStateData"
    keep if _merge==3

    save "$SUL/IPUMS1980_sulfa", replace
}

********************************************************************************
*** (5) Estimate Sulfa effect on child quality
********************************************************************************
use "$SUL/IPUMS1980_sulfa"

gen post = birth_year>=1937
gen p_b_inf = post*base_inf*1000
gen p_b_mmr = post*base_mmr
foreach var of varlist nb_sch_imp ed_exp_imp nb_hos_imp nb_doc_imp {
    gen ln_`var'=log(`var')
}
gen t   = year-1929
gen t_2 = t*t

gen educb = .
replace educb = 0 if educ==0
replace educb = 2 if educ==1
replace educb = 6.5 if educ==2
replace educb = 9 if educ==3
replace educb = 10 if educ==4
replace educb = 11 if educ==5
replace educb = 12 if educ==6
replace educb = 13 if educ==7
replace educb = 14 if educ==8
replace educb = 15 if educ==9

bys birthyr birthqtr: egen meanEd = mean(educb)
bys birthyr birthqtr: egen sdEd   = sd(educb)
gen school_zscore = (educb - meanEd) / sdEd
bys datanum serial momloc: gen fert = _N
bys datanum serial momloc: gen Mrep = _n
bys year datanum serial momloc: egen twinfam = max(twin)
tab twin twinfam

if `est'==1 {
    ****************************************************************************
    *** (6a) Estimates -- school z-score
    ****************************************************************************
    global outcomes school_zscore
    local se robust cluster(birth_state)
    local ctrl i.sex i.race i.birthyr fert
    local c if birthyr<1974&birth_year>=1930&birth_year<=1943

    foreach y of varlist $outcomes {
        xi: reg `y' $post_base_inf $basic `ctrl' `c', `se'
        outreg2 using "$OUT/gammaEstimates.xls", excel keep(p_b_inf) replace
    }

    ****************************************************************************
    *** (6b) Compare Influenza rates in twin and non-twin families
    ****************************************************************************
    sum p_b_inf if twin==1
    sum p_b_inf if twin==0

    *CONDITIONAL MEANS:
    reg p_b_inf twin i.fert i.sex i.race if birthyr < 1974 & Mrep==1
    outreg2 using "$OUT/gammaEstimates.xls", excel keep(twin)
}

********************************************************************************
*** (7) Resampling to estimate a standard error for gamma (ratio of a, b)
********************************************************************************
global outcomes school_zscore educb
local se robust cluster(birth_state)
local ctrl i.sex i.race i.birthyr fert
local c if birthyr<1974&birth_year>=1930&birth_year<=1943

gen twinEst = .
gen qualEst = .
foreach i of numlist 1(1)100 {
    set seed `i'
    dis "Cycle `i': qual"
    preserve
    bsample
    
    xi: qui reg school_zscore $post_base_inf $basic `ctrl' `c', `se'
    local qualEst = _b[p_b_inf]

    dis "Cycle `i':twin"
    qui reg p_b_inf twin i.fert i.sex i.race if birthyr < 1974 & Mrep==1
    local twinEst = _b[twin]

    restore

    replace qualEst = `qualEst' in `i'
    replace twinEst = `twinEst' in `i'
    sum qualEst twinEst
}
gen gamma = - twinEst*qualEst
sum gamma

local Gmean = `r(mean)'
local Gsdev = `r(sd)'

********************************************************************************
*** (8) Examine distribution: Kolmogorov-Smirnov
********************************************************************************
tw hist gamma, bin(12) yaxis(2) frac || function normalden(x,`Gmean',`Gsdev'), /*
*/ lc(black) scheme(lean1) range(`=`Gmean'-3*`Gsdev'' `=`Gmean'+3*`Gsdev'')    /*
*/ yaxis(1) yscale(range(0 11)) ylabel(none) ytitle(" ") xtitle(" ")           /*
*/ legend(label(1 "Empirical Distribution") label(2 "Analytical Distribution"))
graph export "$OUT/gammaResamp.eps", as(eps) replace


sort gamma
gen lgamma = log(gamma)
sum lgamma
local lm = `r(mean)'
local ls = `r(sd)'

gen x = _n*0.0002
gen lN =  (1 / x * `ls' * sqrt(2 * _pi)) * exp(-(log(x) - `lm')^2 / (2 *`ls'^2))

tw hist gamma, bin(12) yaxis(2) frac || line lN x, yaxis(1)                  ///
    scheme(lean1) yscale(range(0 43)) ylabel(none) ytitle(" ") xtitle(" ")   ///
    legend(label(1 "Empirical Distribution") label(2 "Analytical Distribution")) 
graph export "$OUT/gammaLogN.eps", as(eps) replace

ksmirnov gamma = normal((gamma-`Gmean')/`Gsdev')

********************************************************************************
*** (9) Clean and clear
********************************************************************************
keep in 1/100
gen j=_n
keep qualEst twinEst gamma
save "$OUT/gammas.dta", replace

dis "Gamma is distributed N(`Gmean',`Gsdev')"
log close
