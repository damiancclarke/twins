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


********************************************************************************
*** (2) open data and generate child file
********************************************************************************
use "$DAT/IPUMS20012013"
keep if momrule == 1 & age <=18 & year>=2005
keep year datanum serial hhwt region pernum perwt momloc sex age age_orig /*
*/ birthqtr birthyr race bpl bpld language speakeng school educ educd grade* /*
*/ schltype

gen birthtime = birthyr+0.25*(birthqtr-1)
bys year datanum serial momloc: gen ageDif1=birthtime[_n]-birthtime[_n-1]
bys year datanum serial momloc: gen ageDif2=birthtime[_n-1]-birthtime[_n]

gen twin = ageDif1==1 | ageDif2==1
