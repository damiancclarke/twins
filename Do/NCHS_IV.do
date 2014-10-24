/* NCHS_IV.do v0.00              damiancclarke             yyyy-mm-dd:2014-10-21
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NHIS, and converts it into one line per child
with measures of child quality, sibling twin status, and maternal health.  This
can then be used for twin 2sls regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Running only with 2013 NHIS

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/NHIS/Data/dta/2012"
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
*/fm_strp fm_educ1 incgrp2 incgrp3
egen famid=concat(hhx fmx)

drop if fm_strp==11|fm_strp==12 // drops all people living alone or not with fam
drop if fm_strp==21|fm_strp==22|fm_strp==23 // adult only families
drop if fm_strp==45|fm_strp==99 // no biological parents or unknown

gen fert = fm_kids // actually identical to using famsize - adults

save `NCHSfile'


use "$DAT/househld.dta"
keep hhx region
merge 1:m hhx using `NCHSfile'
drop _merge
drop if fmx==""
save `NCHSfile', replace

exit

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


********************************************************************************
*** (4) Gen mother, child, twin variables
********************************************************************************
preserve
keep if mother==1
drop mother child mom_ed dad_ed sex fmother1 headst* _merge
destring dob_m, replace
destring dob_y_p, replace

rename dob_m motherMOB
rename dob_y_p motherYOB
rename racerpi2 motherRace
rename id motherid
rename rrp motherRRP
rename age_p motherAge
rename r_maritl motherMarriage
rename phstat motherHealthStatus
rename plborn motherUSAborn
rename citizenp motherCitizen
rename educ1 motherEduc
rename wrkhrs2 motherWorkHrs
rename wrkmyr motherWorkMths

bys famid: gen n=_n
keep if n==1
drop n
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
replace twin=0 if twin==.

bys famid (birthdate fpx): gen bord=_n
bys famid: egen twinfamily=max(twin)
replace twinfamily=0 if twinfamily==.

bys famid twin (fpx): gen twinnum=_n
replace twinnum=. if twin!=1
gen bordtwin=bord if twin==1
replace bordtwin=bord-1 if twin==2

bys famid: egen twinfamilyT=max(twinnum)
drop if twinfamilyT==3|twinfamilyT==4
drop twinfamilyT _merge

save "$SAV/NCHSChild", replace

merge m:1 famid using "$SAV/NCHSMother"
drop if _merge==1
drop _merge

merge m:1 famid using `NCHSfile'
bys famid: gen fert=_N

local max 1
local fert 2

foreach num in two three four five {
	gen `num'_plus=(bord>=1&bord<=`max')&fert>=`fert'
	replace `num'_plus=0 if twin!=0
	gen twin`num'=(twin==1 & bordtwin==`fert')
	bys famid: egen twin_`num'_fam=max(twin`num')
	drop twin`num'
	local ++max
	local ++fert
}

drop _merge
save $SAV/NCHSTwins, replace


********************************************************************************
*** (5) Other covariates
********************************************************************************
replace educ=. if educ>=96
replace motherEduc=. if motherEduc>96
tab age, gen(_age)
tab motherYOB, gen(_mYOB)
tab region, gen(_region)
tab motherRace, gen(_motherRace)

tab motherEduc, gen(S_motherEduc)

bys age: egen educmean=mean(educ1)
bys age: egen educsd  =sd(educ1)
gen educZscore=(educ1-educmean)/educsd

foreach n in two three four { 
	reg educZs _* fert if age<20&`n'_plus==1
	ivreg2 educZscore _age* _region* (fert=twin_`n'_fam) if age<20&`n'_plus==1
	ivreg2 educZscore _* (fert=twin_`n'_fam) if age<20&`n'_plus==1
	ivreg2 educZscore _* S_* (fert=twin_`n'_fam) if age<20&`n'_plus==1	
}
