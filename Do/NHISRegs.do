/* NHISRegs.do v0.00             damiancclarke             yyyy-mm-dd:2014-10-25
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes processed data from the generating script NHISPrep.do and runs
OLS, IV and bounds analysis of the effect of fertility on child quality.  Speci-
fications are as similar as possible to DHS twin regressions. The twin 2sls reg-
ressions (the main regression of interest), take the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Running only with NHIS from 2004-2013 (2003 and earlier are diff)
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/NCIS"
global OUT "~/investigacion/Activa/Twins/Results/Outreg/NHIS"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir $OUT
*log using "$LOG/NCISRegs.txt", text replace

local yvars excellentHealth schoolZscore childEducation /*childHealthPrivate*/ 
local yvars excellentHealth schoolZscore
local age   ageFirstBirth motherAge motherAge2
local base  B_* childSex
local H     H_* `age' smoke* heightMiss
local SH    S_* `H' 
local tcon  i.surveyYear i.motherRace i.region `age'

local wt    pw=sWeight
local se    cluster(motherID)

local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) /*
*/ stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)

local ols 0
local sum 1
local ivs 0

********************************************************************************
*** (2) Append cleaned files, generate indicators
********************************************************************************
append using "$DAT/NCIS2010" "$DAT/NCIS2011" "$DAT/NCIS2012" "$DAT/NCIS2013"
append using "$DAT/NCIS2006" "$DAT/NCIS2007" "$DAT/NCIS2008" "$DAT/NCIS2009"
append using "$DAT/NCIS2002" "$DAT/NCIS2003" "$DAT/NCIS2004" "$DAT/NCIS2005"  

gen childHealth=childHealthStatus if childHealthStatus<=5
gen excellentHealth=childHealthStatus==1
bys ageInterview: egen mE=mean(childEducation)
bys ageInterview: egen sd=sd(childEducation)
gen schoolZscore=(childEducation-mE)/sd
*replace childHealthPrivate=0 if childHealthPrivate==2

tab surveyYear,   gen(B_Syear)
tab ageInterview, gen(B_Bdate)
tab region,       gen(B_region)
tab motherRace,   gen(B_mrace)
*tab childRace,    gen(B_crace)


tab motherHealthStatus, gen(H_mhealth)
drop H_mhealth6
drop H_mhealth7
drop H_mhealth8
*replace motherHeight=. if motherHeight==0

gen mGoodHealth   =motherHealthStatus==1|motherHealthStatus==2
gen mPoorHealth   =motherHealthStatus==4|motherHealthStatus==5
gen mMissingHealth=motherHealthStatus==6|motherHealthStatus==7
gen H_mheight=motherHeight
gen H_mheight2=motherHeight^2
gen S_meduc=motherEducation
gen S_meduc2=motherEducation^2
*gen S_mUSCit=motherUSCitizen==1

gen bmi2=bmi^2

********************************************************************************
*** (3) Summary
********************************************************************************
if `sum'==1 {
    gen mEduc=motherEducation
    replace mEduc=12 if motherEducation==13
    replace mEduc=12 if motherEducation==14
    replace mEduc=14 if motherEducation>=15
    gen BMI=bmi if bmi<99
    gen BMI185=bmi<18.5
    replace BMI185=. if bmi>99
    gen motherExcellentHealth=motherHealthStatus==1

    local motherStat fert motherAge mEduc BMI BMI185 motherExcellentHealth
    local childStat  excellentHealth childEducation schoolZscore

    preserve
    collapse `motherStat' twinfamily, by(surveyYear hhx fmx)
    replace twinfamily=round(twinfamily)
    estpost tabstat `motherStat', by(twinfamily) statistics(mean sd) listwise /*
    */ columns(statistics)
    esttab using "$OUT/Mother.txt", replace main(mean) aux(sd) nostar unstack /*
    */ noobs nonote nomtitle nonumber
    restore
    estpost tabstat `childStat', by(twin) statistics(mean sd) listwise /*
    */ columns(statistics)
    esttab using "$OUT/Child.txt", replace main(mean) aux(sd) nostar unstack
    noobs nonote nomtitle nonumber
}

********************************************************************************
*** (4) Twin Regression
********************************************************************************
if `twin'==1 {
gen twin100=twin*100

reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) replace
reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss if childYearBirth<=1989
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) append
reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss if childYearBirth>1989
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) append
reg twin100 H_mheight S_meduc* smoke* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss
outreg2 `age' H_* S_* bmi smoke* using "$OUT/NHIStwin.tex", tex(pr) append

exit

*reg twin100 H_mheight S_meduc smoke* i.motherRac i.region motherAge* /*
**/ ageFirstBirth i.surveyYear bmi heightMiss mGood mPoor mMissing
*outreg2 `age' H_* S_* smoke* bmi m*  using "$OUT/NHIStwin.xls", excel append
}

********************************************************************************
*** (5) OLS regressions
********************************************************************************
if `ols'==1 {
foreach y of varlist `yvars' {

	eststo: reg `y' `base' `age' fert [`wt'], `se'
	eststo: reg `y' `base' `H'   fert [`wt'], `se'
	eststo: reg `y' `base' `SH'  fert [`wt'], `se'

	estout est1 est2 est3 using "$OUT/OLSAll`y'.xls", replace `estopt' keep(fert `SH')
	estimates clear

	foreach f in two three four {
		eststo: reg `y' `base' `SH' fert [`wt'] if `f'_plus==1, `se'
		eststo: reg `y' `base' `H'  fert [`wt'] if `f'_plus==1, `se'
		eststo: reg `y' `base'      fert [`wt'] if `f'_plus==1, `se'
	}
	local estimates est1 est2 est3 est4 est5 est6 est7 est8 est9
	estout `estimates' using "$OUT/OLSFert`y'.xls", replace `estopt' keep(fert `SH')
	estimates clear
}
}	

********************************************************************************
*** (6) IV regressions
********************************************************************************
if `ivs'==1 {
foreach y of varlist `yvars' {
	foreach f in two three four {
		local F`f'
		preserve
		keep if `f'_plus==1
		eststo: ivreg29 `y' `base' `SH' (fert=twin_`f'_fam)             [`wt'], /*
		*/ `se' first ffirst savefirst savefp(`f's) partial(`base')
		unab svars : S_*
		test `svars'
		local F`f' `F`f'' `=`r(chi2)''
		
		eststo: ivreg29 `y' `base' `H' (fert=twin_`f'_fam) if e(sample) [`wt'], /*
		*/ `se' first ffirst savefirst savefp(`f'h) partial(`base')
		unab hvars : H_* smoke*
		test `hvars'
		local F`f' `F`f'' `=`r(chi2)''

		eststo: ivreg29 `y' `base'     (fert=twin_`f'_fam) if e(sample) [`wt'], /*
		*/ `se' first ffirst savefirst savefp(`f'b) partial(`base')
		restore
		dis `F`f''
	}
	local estimates est3 est2 est1 est6 est5 est4 est9 est8 est7
	local fstage twobfert twohfert twosfert threebfert threehfert threesfert /*
	*/ fourbfert fourhfert foursfert
	estout `estimates' using "$OUT/IVFert`y'.xls", replace `estopt' keep(fert `SH')
	estout `fstage'  using "$OUT/IVFert`y'1.xls", replace `estopt' keep(twin* `SH')
	dis "F-test two plus (S, H)  : `Ftwo'"
	dis "F-test three plus (S, H): `Fthree'"
	dis "F-test four plus (S, H) : `Ffour'"
	estimates clear
}
}
exit 

count
********************************************************************************
*** (7) IV regressions by gender
********************************************************************************
cap mkdir "$OUT/Gender"
foreach gend of numlist 1 2 {
	foreach y of varlist  `yvars' {
		foreach f in two three four {
			preserve
			keep if childSex==`gend'&`f'_plus==1
			eststo: ivreg29 `y' `SH' (fert=twin_`f'_fam) [`wt'],               /*
			*/ `se' first ffirst savefirst savefp(`f's) partial(`base')
			dis "`f' base"
			dis _b[fert]
			dis _b[fert]/_se[fert]

			eststo: ivreg29 `y'  `H' (fert=twin_`f'_fam) if e(sample) [`wt'], /*
			*/ `se' first ffirst savefirst savefp(`f'h) partial(`base')
			dis "`f' H"
			dis _b[fert]
			dis _b[fert]/_se[fert]

			eststo: ivreg29 `y' `base' (fert=twin_`f'_fam) if e(sample) [`wt'], /*
			*/ `se' first ffirst savefirst savefp(`f'b) partial(`base')
			dis "`f' SH"
			dis _b[fert]
			dis _b[fert]/_se[fert]
			restore
		}
		local estimates est3 est2 est2 est6 est5 est4 est9 est8 est7
		local fstage twobfert twohfert twosfert threebfert threehfert threesfert /*
		*/ fourbfert fourhfert foursfert
		estout `estimates' using "$OUT/Gender/IVFert`y'G`gend'.xls", replace     /*
		*/ `estopt' keep(fert `SH')
		estout `fstage'    using "$OUT/Gender/IVFert`y'1G`gend'.xls", replace    /*
		*/ `estopt' keep(twin* `SH')
		estimates clear
	}
}
