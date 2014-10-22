/* NCHS_IV.do v0.00              damiancclarke             yyyy-mm-dd:2014-10-21
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NCHS, and converts it into one line per child
with measures of child quality, sibling twin status, and maternal health.  This
can then be used for twin 2sls regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Running only with 2013 NCHS

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/NCHS/Data/dta/2013"
global SAV "~/investigacion/Activa/Twins/Data"
global OUT "~/investigacion/Activa/Twins/Results/Outreg/NCHS"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir $OUT
log using "$LOG/NCHS_IV.txt", text replace

tempfile NCHSfile people

********************************************************************************
*** (2) Open data
********************************************************************************
use "$DAT/familyxx.dta"
keep hhx fmx wtfa_fam fint_y_p fint_m_p fm_size fm_kids fm_type fm_strcp /*
*/ fm_educ1 incgrp2 incgrp3

save `NCHSfile'

use "$DAT/househld.dta"
keep hhx region
merge 1:m hhx using `NCHSfile'

save `NCHSfile', replace

use "$DAT/personsx"
keep hhx fmx fpx sex origin_i racerpi2 rrp dob_m dob_y_p age_p r_maritl        /*
*/ fmother1 mom_ed dad_ed latime29 launit29 ladura29 ladurb29 lachrc29 phstat /*
*/ plborn regionbr citizenp headst headstv educ1 wrkhrs2 wrkftall wrkmyr 

********************************************************************************
*** (3) Create relationship file
********************************************************************************
egen famid=concat(hhx  fmx)
egen id=concat(hhx fmx fpx)
destring fpx, replace
save `people'

gen mother=.
gen child=.

keep famid fpx fmother1 rrp mother child
destring fmother1, replace
reshape wide fmother1 rrp mother child, i(famid) j(fpx)

foreach num of numlist 1(1)18  {
	egen yes=anymatch(fmother*), v(`num')
	replace mother`num'=1 if yes==1
	drop yes
	replace child`num'=1 if fmother1`num'!=0
}

reshape long fmother1 rrp mother child, i(famid) j(fpx)
drop if rrp==.
keep famid fpx mother child

merge 1:1 famid fpx using `people'

preserve
keep if mother==1
save "$SAV/NCHSMother", replace
restore

keep if child==1
destring dob_y_p, replace
destring dob_m, replace
keep if dob_y_p<9000
keep if dob_m<90

gen birthdate=dob_y_p+(dob_m-1)/12

gen twin=.
foreach n of numlist 1(1)18 {
	gen bd=birthdate if fpx==`n'
	bys famid: egen mbd=mean(bd)
	gen bddif = birthdate-mbd
	replace twin=1 if bddif==0&fpx!=`n'
	drop bd mbd bddif
}
