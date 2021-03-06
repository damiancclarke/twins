* NepalTests.do v0.00            damiancclarke             yyyy-mm-dd:2014-06-26
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
/*Regressions looking at health of mothers and whether this predicts miscarriage
as well as interaction with twins.

Note that Nepal uses the Vikram Samvat calendar, so this is converted to Gregor-
ian in the code (-57 yrs).
*/

vers 11
clear all
set more off
cap log close
********************************************************************************
*** (0) Globals and Locals
********************************************************************************
global DAT "~/database/DHS/DHS_Data/Nepal"
global OUT "~/investigacion/Activa/Twins/Results/Nepal"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir "$OUT"

log using "$LOG/NepalTests.txt", text replace

local IRfiles NPIR31DT NPIR41DT NPIR51DT NPIR60DT
tokenize `IRfiles'
********************************************************************************
*** (1) Generate data
********************************************************************************
foreach yy in 1996 2001 2006 2011 {
	use "$DAT/`yy'/`1'"
	macro shift

	if `"`yy'"'=="2011" {
		drop s217_* s229_*
		foreach num in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
			rename sprego_`num' s217_`num'
			rename s220ab_`num' s229_`num'
			rename s228_`num'   s230_`num'
			foreach nn in 0 1 2 3 4 5 8 {
				rename b`nn'_`num' b`nn'_x_`num'
			}
		}
	}
	else if `"`yy'"'=="2001" {
		drop s217_* s229_* s230*
		foreach num in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 {
			rename s216_`num' s217_`num'
			rename s227_`num' s229_`num'
			rename s228_`num' s230_`num'
			foreach nn in 0 1 2 3 4 5 8 {
				rename b`nn'_92_`num' b`nn'_x_`num'
			}
		}
	}
	else if `"`yy'"'=="1996" {
		drop s217_* s229_*
		foreach num in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
			rename s216_`num' s217_`num'
			rename s226_`num' s229_`num'
			rename s227_`num' s230_`num'
			foreach nn in 0 1 2 3 4 5 8 {
				rename b`nn'_`num' b`nn'_x_`num'
			}
		}
	}

	keep v000-v026 v133 v201 v212 v438 v445 b0_x_* b1_x_* b2_x_* b3_x_* b4_x_* /*
	*/ b5_x_* b8_x_* s217_* s230_* s229_* caseid v106


	local stub b0_x_ b1_x_ b2_x_ b3_x_ b4_x_ b5_x_ b8_x_ s217_ s230_ s229_

	foreach num of numlist 1(1)9 {
		foreach var of local stub {
			rename `var'0`num' `var'`num'
		}
	}

	reshape long `stub', i(caseid) j(birth)
	keep if b0_x_!=.

	rename b0_x_ twin 
	rename b2_x_ child_yob
	rename b3_x_ child_dob
	rename b4_x_ sex
	rename b5_x_ child_alive
	rename b8_x_ age
	rename s217_ miscarriageStatus
	rename s229_ gestationMonthDeath
	rename s230_ abort
	rename v010 year_birth
	rename v012 agemay
	*rename v133 educf
	rename v201 fert
	rename v212 agefirstbirth
	rename v438 height
	rename v445 bmi
	gen educNo  =v106==0
	gen educPrim=v106==1
	gen educSec =v106==2
	gen educTer =v106==3
	
	gen twind=twin>0
	gen twind100=twind*100
	gen miscarry=(miscarriageStatus>1)*100
	gen miscarryNoAbort=miscarry*(1-abort)
	replace miscarryNoAbort=0 if miscarryNoAbort==.
	gen miscarryAbort=miscarry*(abort)
	replace miscarryAbort=0 if miscarryAbort==.
	gen twinMiscarry=miscarry*twind
	gen twinMiscarryNoAbort=twinMiscarry*(1-abort)
	replace twinMiscarryNoAbort=0 if twinMiscarryNoAbort==.
	gen twinMiscarryAbort=twinMiscarry*(abort)
	replace twinMiscarryAbort=0 if twinMiscarryAbort==.
	*gen educfyrs_sq=educf*educf
	gen motherage = agemay - age
	replace motherage=24.3 if motherage==.
	gen motheragesq = motherage^2
	replace age=floor(v007-child_yob+(v006-b1_x_/12)) if age==.
	replace height=height/10
	replace bmi=bmi/100
	gen heightsq=height*height
	gen bmisq=bmi*bmi	
	
	foreach year of varlist child_yob year_birth {
		if `year'< 1000 replace `year'=`year'+2000
		replace `year'=`year'-57
	}
	gen survey=`yy'
	tempfile f`yy'
	save `f`yy''
}

append using `f1996' `f2001' `f2006' `f2011'
********************************************************************************
*** (2) Run regessions
********************************************************************************
cap rm "$OUT/NepalRegs.xls"
cap rm "$OUT/NepalRegs.txt"
cap rm "$OUT/NepalRegsNonLin.xls"
cap rm "$OUT/NepalRegsNonLin.txt"

foreach var of varlist educPrim educSec educTer {
	gen twinX`var'=twin*`var'
}

drop miscarry
rename miscarryNoAbort Miscarriage

qui reg Miscarriage motherage motheragesq agefirstbirth educP educS educT bmi* /*
*/ height* fert i.child_yob, cluster(caseid)
reg Miscarriage motherage motheragesq agefirstbirth educP educS educT      /*
*/ fert i.child_yob if e(sample), cluster(caseid)
outreg2 motherage motheragesq agefirstbirth educP educS educT              /*
*/ using "$OUT/NepalRegs.tex", tex(pretty) replace
reg Miscarriage motherage motheragesq agefirstbirth educP educS educT bmi* /*
*/ height* fert i.child_yob, cluster(caseid)
outreg2 motherage motheragesq agefirstbirth educP educS educT              /*
*/ using "$OUT/NepalRegs.tex", tex(pretty) append


reg Miscarriage motherage motheragesq agefirstbirth educP educS educT twin /*
*/ twinX* fert i.child_yob if e(sample), cluster(caseid) 
outreg2 motherage motheragesq agefirstbirth educP educS educT twin twinX*  /*
*/ using "$OUT/NepalRegs.tex", tex(pretty) append

gen twinXheight=twin*height
gen twinXbmi=twin*bmi

reg Miscarriage motherage motheragesq agefirstbirth  educP educS educT height /*
*/ bmi twin twinX* fert i.child_yob, cluster(caseid)
outreg2 motherage motheragesq agefirstbirth educP educS educT height bmi twin /*
*/ twinX* using "$OUT/NepalRegs.tex", tex(pretty) append
gen twinXheightsq=twin*heightsq
gen twinXbmisq=twin*bmisq
reg Miscarriage  motherage motheragesq agefirstbirth  educP educS educT       /*
*/ height* bmi* twin twinX* fert i.child_yob, cluster(caseid)
outreg2 motherage motheragesq agefirstbirth  educP educS educT height* bmi*   /*
*/ twin twinX* using "$OUT/NepalRegs.tex", tex(pretty) append

********************************************************************************
*** (3) Run regessions cast as negative health
********************************************************************************

gen underweight  = bmi<18.5&bmi>=15
gen vunderweight = bmi<15.0
*gen short        = height<150&height>140
gen short        = height<145
foreach var of varlist educNo underweight vunderweight short motherage /*
*/ motheragesq agefirstbirth fert{
	gen twinX`var' = twin*`var'
}

lab var underweight "Underweight"
lab var vunderweight "Very Underweight"
lab var short "Short"
*lab var vshort "Very Short"
lab var educNo "No Education"
lab var educPrim "Primary Education"
lab var educSec "Secondary Education"
lab var educTer "Tertiary Education"
lab var twinXunder "Twin $\times$ Underweight"
lab var twinXvunder "Twin $\times$ Very underweight"
lab var twinXshort "Twin $\times$ Short"
*lab var twinXvshort "Twin $\times$ Very Short"
lab var twinXeducNo "Twin $\times$ No Education"
lab var twinXeducPri "Twin $\times$ Primary"
lab var twinXeducSec "Twin $\times$ Secondary"

local base motherage motheragesq agefirstbirth fert i.child_yob
local educ educN educP educS
local health underweight vunderweight short
local Teduc twinXeducNo twinXeducP twinXeducS
local Thealth twinXunderweight twinXvunderweight twinXshort
local Tbase motherage* agefirst fert i.child_yob twinXmotherage* twinXagef twinXfert

local se cluster(caseid)

qui reg Miscarriage `base' `educ' bmi height*, `se'
reg Miscarriage `base' `educ' if e(sample), `se'
outreg2 `educ' using "$OUT/NepalRegs2.tex", tex(pretty) label replace

reg Miscarriage `base' `educ' `health'  if e(sample), `se'
outreg2 `educ' `health' using "$OUT/NepalRegs2.tex", tex(pretty) label append

reg Miscarriage `Tbase' `educ' twin `Teduc' if e(sample), `se'
outreg2 `educ' twin `Teduc' using "$OUT/NepalRegs2.tex", tex(pretty) label

reg Miscarriage `Tbase' `educ' `health' twin `Teduc' `Thealth' if e(sample), `se'
outreg2 `educ' `health' twin `Teduc' `Thealth' using "$OUT/NepalRegs2.tex", /*
*/ tex(pretty) label append

