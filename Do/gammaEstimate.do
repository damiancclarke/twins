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
global OUT "~/investigacion/Activa/Twins/Results"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/gammaEstimate.txt", replace text

local c=0
local m=1
********************************************************************************
*** (2) open data and generate child file
********************************************************************************
use "$DAT/IPUMS1980"
keep if momrule == 1 & age <=18 & year>=2005
keep year datanum serial hhwt pernum perwt momloc sex birthqtr birthyr race /*
*/ bpl bpld language speakeng school educ educd grade* schltype

gen birthtime = birthyr+0.25*(birthqtr-1)
bys year datanum serial momloc: gen ageDif1=birthtime[_n]-birthtime[_n-1]
bys year datanum serial momloc: gen ageDif2=birthtime[_n]-birthtime[_n+1]

gen twin = ageDif1==0 | ageDif2==0
tab twin
tempfile child
save `child'

********************************************************************************
*** (3) open data and generate mother file, merge to children
********************************************************************************
use "$DAT/IPUMS1980"
keep if nchild>0 & year>=2005 & sex==2
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

exit
********************************************************************************
*** (4) Merge in Sulfa data
********************************************************************************
merge m:1 birty_year birth_state using "$DAT/sulfaStateData"
