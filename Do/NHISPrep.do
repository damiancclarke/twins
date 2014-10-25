/* NHISPrep.do v1.00             damiancclarke             yyyy-mm-dd:2014-10-21
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
   v1.00: NHIS, merge mother -> child seperately

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global SAV "~/investigacion/Activa/Twins/Data/NCIS"
global OUT "~/investigacion/Activa/Twins/Results/Outreg/NCHS"
global LOG "~/investigacion/Activa/Twins/Log"
global DAT "~/database/NHIS/Data/dta/2013"

log using "$LOG/NCHS_IV.txt", text replace

foreach yrr of numlist 2013 2012 2011 2010 {
global DAT "~/database/NHIS/Data/dta/`yrr'"

tempfile family child mother

********************************************************************************
*** (2) Use family and household files, keeping all with children--mother link
********************************************************************************
use "$DAT/familyxx.dta"
keep hhx fmx wtfa_fam fint_y_p fint_m_p fm_size fm_kids fm_type fm_strcp /*
*/fm_strp fm_educ1 incgrp2 incgrp3
egen famid=concat(hhx fmx)

drop if fm_strp==11|fm_strp==12 // drops all people living alone or not with fam
drop if fm_strp==21|fm_strp==22|fm_strp==23 // adult only families
drop if fm_strp==45|fm_strp==99 // no biological parents or unknown
drop if fm_strp==32 // no mother to link to mother record
drop if fm_strp==.

gen fert = fm_kids // actually identical to using famsize - adults

save `family'


use "$DAT/househld.dta"
keep hhx region
merge 1:m hhx using `family'
keep if _merge==3
drop _merge
drop if fmx==""
save `family', replace

********************************************************************************
*** (3) Create child file
********************************************************************************
use "$DAT/personsx"
drop if fmother=="00"|fmother=="96"

keep if age_p<=18

replace mracrpi2=4 if mracrpi2==1&origin_i==1
cap rename fmother1 fmother

order hhx fmx fpx rrp frrp fmother
rename srvy_yr  surveyYear
rename intv_mon surveyMonth
rename wtfa     sWeight
rename sex      childSex
rename mracrpi2 childRace
rename dob_m    childMonthBirth
rename dob_y_p  childYearBirth
rename age_p    childAge
rename mom_ed   motherEduc
rename dad_ed   fatherEduc
rename cstatflg childFlag
rename plaplylm childLimitPlay
rename la1ar    childLimitAny
rename lahcc5   childLimitBirth
rename lahcc13  childLimitADHD
rename phstat   childHealthStatus
rename lcondrt  childChronicCond
rename hikindna childHealthPrivate
rename hikindnb childHealthMedicar
rename hikindnc childHealthMedigap
rename hikindnd childHealthMedicai
rename hikindne childHealthSCHIP
rename hikindnf childHealthMilitar
rename hikindng childHealthIndian
rename hikindnh childHealthState
rename hikindni childHealthGovt
rename hikindnj childHealthSSP
rename hikindnk childHealthNone
rename citizenp childUSCitizen
rename plborn   childUSBorn
rename educ1    childEducation
rename rrp      childRefRelate
rename frrp     childRefRelateFam
rename fpx      childfpx

keep hhx fmx childfpx fmother surveyYear surveyMont sWeight childSex childRac /*
*/ childMonthBirth childYearBirth childAge motherEduc fatherEduc childFlag    /*
*/ childLimit* childHealthStatus childChronicCond childHealth* childUSCitizen /*
*/ childUSBorn childEducation childRef*

save `child'
merge m:1 hhx fmx using `family'
drop if _merge==1 //  People for whom we have no measure of family structure
drop if _merge==2 //  Children who do not have observations for mother
drop _merge

save `child', replace

********************************************************************************
*** (4) Create mother file
********************************************************************************
use "$DAT/personsx"
keep if age_p>=18&sex==2

replace mracrpi2=4 if mracrpi2==1&origin_i==1

rename wtfa     mWeight
rename mracrpi2 motherRace
rename dob_m    motherMonthBirth
rename dob_y_p  motherYearBirth
rename age_p    motherAge
rename la1ar    motherLimitAny
rename lahcc5   motherLimitBirth
rename lahcc13  motherLimitADHD
rename phstat   motherHealthStatus
rename lcondrt  motherChronicCond
rename citizenp motherUSCitizen
rename plborn   motherUSBorn
rename educ1    motherEducation
rename r_maritl motherMarriage
rename hikindna motherHealthPrivate
rename hikindnb motherHealthMedicar
rename hikindnc motherHealthMedigap
rename hikindnd motherHealthMedicai
rename hikindne motherHealthSCHIP
rename hikindnf motherHealthMilitar
rename hikindng motherHealthIndian
rename hikindnh motherHealthState
rename hikindni motherHealthGovt
rename hikindnj motherHealthSSP
rename hikindnk motherHealthNone

keep hhx fmx fpx rrp frrp mWeight motherRace motherMonthBirth motherYearBirth /*
*/ motherAge motherLimitAny motherLimitBirt motherLimitADHD motherHealthStatu /*
*/ motherChronicCond motherUSCitizen motherUSBorn motherEducation motherHealth*

gen fmother=fpx
merge 1:m hhx fmx fmother using `child'

keep if _merge==3 //Only mothers merge in, so about half should be _merge==1
drop _merge

********************************************************************************
*** (5) Create fertility variables
********************************************************************************
*egen childID=concat(hhx fmx childfpx)
egen famID=concat(hhx fmx)
egen motherID=concat(hhx fmx fpx)

destring childYearBirth,  replace
destring childMonthBirth, replace
keep if childYearBirth<9000
keep if childMonthBirth<90

gen motherAge2=motherAge^2
gen birthdate=childYearBirth+(childMonthBirth-1)/12

sum birthdate

gen twin=.
bys motherID (birthdate): gen kidID=_n
levelsof kidID 
local num: word count `r(levels)'

foreach n of numlist 1(1)`num' {
	gen bd=birthdate if kidID==`n'
	bys motherID: egen mbd=mean(bd)
	gen bddif = birthdate-mbd
	replace twin=1 if bddif==0&kidID!=`n'
	drop bd mbd bddif
}
replace twin=0 if twin==.

bys motherID (birthdate): gen bord=_n

bys motherID: egen twinfamily=max(twin)
replace twinfamily=0 if twinfamily==.

gen tbord=bord if twin==1
bys motherID: egen bordtwin=min(tbord)
replace bordtwin=. if twin==0

bys motherID twin: gen twinnum=_n
replace twinnum=. if twin!=1
bys motherID: egen twinfamilyT=max(twinnum)
drop if twinfamilyT==3|twinfamilyT==4
drop twinfamilyT

local max 1
local fert 2
foreach num in two three four five {
	gen `num'_plus=(bord>=1&bord<=`max')&fert>=`fert'
	replace `num'_plus=0 if twin!=0
	gen twin`num'=(twin==1 & bordtwin==`fert')
	bys motherID: egen twin_`num'_fam=max(twin`num')
	drop twin`num'
	local ++max
	local ++fert
}

********************************************************************************
*** (6) Clean outcomes, other covariates
********************************************************************************
replace childEducation=. if childEducation>90
replace motherEducation=. if motherEducation>90

bys motherID: egen maxAge=max(childAge)
gen ageFirstBirth=motherAge-maxAge

foreach var in LimitAny USCitizen USBorn HealthPrivate HealthNone {
	foreach p in mother child {
		replace `p'`var'=2 if `p'`var'>=3
	}
}
gen childCondition   =childLimitAny==1&childLimitBirth!=1
gen childADHD        =childLimitADHD==1

save $SAV/NCIS`yrr', replace
}
