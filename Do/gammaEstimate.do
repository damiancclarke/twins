/* gammaEstimate.do v0.00        damiancclarke             yyyy-mm-dd:2015-03-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Estimate gamma for Conley et al method using the USA Sulfanide improvement in m-
aternal health.


*/

vers 11
clear all
set more off
cap log close
    
********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/IPUMS"
global SUL "~/investigacion/Activa/Twins/Data/"
global OUT "~/investigacion/Activa/Twins/Results"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/gammaEstimate.txt", replace text

local gen = 0
local est = 1

global post_base_inf p_b_inf
global mortality     p_b_mmr p_b_tbr /*p_b_diar p_b_cancer p_b_heartd p_b_mal*/
global statevar      ln_pci ln_nb_sch_imp ln_ed_exp_imp ln_nb_hos_imp /*
                     */ ln_nb_doc_imp /*i.post*health_exp_pc*/
global cohort        birth_year>=1930&birth_year<=1943
global basic         i.birth_state*i.race i.birth_year*i.race
global regional      i.birth_state*i.race i.birth_year*i.race
global trends        i.birth_state*i.race i.birth_year*i.race i.birth_state*t
global trends2       i.birth_state*i.race i.birth_year*i.race i.birth_state*t /*
                     */ i.birth_state*t_2

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
if `est'==1 {
    use "$SUL/IPUMS1980_sulfa"
    keep if birth_year>=1930&birth_year<=1943

    gen post = birth_year>=1937
    gen p_b_inf = post*base_inf
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
    gen school_zscore = (meanEd - educb) / sdEd

}
