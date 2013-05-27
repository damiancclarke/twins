/* Regressions 3.00              damiancclarke             yyyy-mm-dd:2013-04-15
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/

*NOTE TO FUTURE ME: This is the new twins regressions file.  Here we are looking
*at all children in the family, not just twin preceeders.

*Second note: have added v367 to base dataset - this is wanted last pregnancy
*(but not perfect as there is missings).  Perhaps better to deal with ideal #.


clear all
version 11.2
cap log close
set more off
set mem 2000m

*******************************************************************************
*** (0) Globals and Locals
*******************************************************************************
global Base ~/investigacion/Activa/Twins
global Data $Base/Data
global Results ~/investigacion/Activa/Twins/ResultsNEW
log using "$Base/Log/Twin_Regressions.log", text replace

*Regression controls
global sumstats bord fert agemay educf educ attendance poor1 height bmi

global twinpredict agemay magesq educf_1_4 educf_5_6 educf_7_10 educf_11plus /*
*/ height bmi poor1 i.child_yob i._cou agefirstbirth

global basecont malec agemay magesq agefirstbirth i._cou i.year_birth i.age /*i.bord*/
global basecont2 malec agemay magesq agefirstbirth i.year_birth i.age /*i.bord*/
global baseout malec agemay magesq agefirstbirth
global morecont height bmi educf_1_4 educf_5_6 educf_7_10 educf_11pl poor1
global moreout height bmi educf_1_4 educf_5_6 educf_7_10 educf_11pl poor1

*SWITCHES
local sumstats no
local bybirth no
local pooled no
	local bind no
	local final no
	local after no
local bord no
	local bordfinal no
	local bordafter no
	local bordall no
local ols no
local bordpretwin no
	local bordafter_pre no
	local bordall_pre no
local gend yes
local income yes

* FOLDERS
cap mkdir "$Results/Outreg"

* FILES (these are the names with which to append outreg files)
local twinbind BindTwins
local twinfinal FinalTwins
local twinbord TwinBord_Final
local twinafter TwinAfter_bord
local twinbordafter TwinBord_After
local twinbordall TwinBord_All
local twinbordafter_pre TwinBord_After_pre
local twinbordall_pre TwinBord_All_pre
local gend_twinbordall TwinBordAll_gender
local gend_twinbordafter TwinBordAfter_gender
local inc_twinbordall TwinBordAll_income
local inc_twinbordafter TwinBordAfter_income


*******************************************************************************
*** (0) Setup (+ discretionary choices)
*******************************************************************************
use "$Data/DHS_twins"
***THIS IS NEW AND GETS RID OF ALL TWIN FAMILIES FROM CONTROL
*foreach treat in Final Bind {
*	replace T_`treat'=. if T_`treat'==0&nummultiple!=0
*	cap drop T_`treat'Xtwin
*	gen T_`treat'Xtwin=T_`treat'*twind
*}

replace bmi=. if bmi>42
replace height=. if height>240
replace height=. if height<80
replace educ=. if age<6
*drop if nummultiple>2&nummultiple<5

* Check if user written ados are installed.  If not this requires internet
cap which byhist
if _rc!=0 cap ssc install byhist

keep if _merge==3	
*******************************************************************************
*** (1) Summary Stats
*******************************************************************************
if `"`sumstats'"'=="yes" {
	***************************************************************************
	*** (2a) Graphical
	***************************************************************************
	*(1) Freq distribution of twins by bord of twins
	byhist bord  if bord<11, by(twin_birth) tw(legend(label(1 "Single Birth")/*
	*/ label(2 "Twin Birth")) title("Birth type by birth order") ///
	graphregion(color(white)) bgcolor(white)) frac	
	graph export "$Results/birthtype.eps", as(eps) replace
	graph export "$Results/birthtype.png", as(png) replace	

	twoway kdensity fert if twin_birth==1, bw(2) || kdensity fert if ///
	twin_birth==0, bw(2) legend(label(1 "Twin Family") ///
	label(2 "Singleton Family")) ytitle("Density") ///
	title("Total births by Family Type") xtitle("total children ever born") 

	*(2) % twins at last birth, % twins at last birth with family size at ideal
	tab twintype
	tab singletype

	*(3) Distribution of twins overlaid with distbn of family size	
	byhist fert, by(twinfamily) tw(legend(label(1 "Singleton Family") ///
	label(2 "Twin family")) title("Total births by family type") ///
	graphregion(color(white)) bgcolor(white)) frac
	graph export "$Results/familytype.eps", as(eps) replace	
	graph export "$Results/familytype.png", as(png) replace		
	
	*(3b) Twins by bord
	sum twind	
	local meantwin %6.4f r(mean)
	preserve
	collapse twind, by(bord)
	line twind bord if bord<19, title("Twinning by birth order") ///
	ytitle("Fraction twins") xtitle("Birth Order") yline(0.0207) ///
	note("Single births are 1-frac(twins). Total fraction of twins is 0.0207")
	restore

	***************************************************************************
	*** (2b) Stats
	***************************************************************************
	*(4) Do families continue with births when hitting ideal (with twins)?
	tab FAMtwinbinds FAMtwinbindsfinal

	*(5) % of unplanned births (after ideal number, also if wanted)
	tab idealfam

	*(6) characteristics of families who want different ideal sizes (P.Dev idea)
	areg idealnumkids educf_* fert agefirstbirth poor1 height bmi i.year_birth/*
	*/ i.child_yob i.agemay [pw=sweight], a(_cou) cluster(_cou)
	outreg2 educf_0 educf_1_4 educf_5_6 educf_7_10 fert agefirstbirth poor1 /*
	*/educ height bmi using $Results/fampref.tex, tex(pr) replace
	outreg2 educf_0 educf_1_4 educf_5_6 educf_7_10 fert agefirstbirth poor1 /*
	*/educ height bmi using $Results/fampref.xls, excel replace	

	***************************************************************************
	*** (2c) Twin, non-twin characteristics
	***************************************************************************
	sum $sumstats
	sum twind
	sum $sumstats if twin==0
	sum $sumstats if twin>0&twin!=.
	foreach income in low mid {
	dis in yellow "`income'"
	sum twind if income=="`income'"
	sum $sumstats if twin==0 & income=="`income'"
	sum $sumstats if twin>0&twin!=. & income=="`income'"
	}	
}

********************************************************************************
**** (2) Twin predict regressions
********************************************************************************
if `"`twin'"'=="yes" {
	reg twind100 bord $twinpredict [pw=sweight], cluster(_cou)

	foreach inc in low mid {
		reg twind100 bord $twinpredict [pw=sweigh] if income=="`inc'", cluster(_cou)
	}

}
********************************************************************************
**** (3) Reduced Form Regressions on twin (this is for all children together,
**** not explicitly separating by size so that we aren't comparing families of
**** size q with families of size q+1 (due to twins)
********************************************************************************
if `"`pooled'"'=="yes" {
	local cond agefirstbirth>=14&age<22

	***************************************************************************
	*** (3b) Binding twins
	***************************************************************************	
	if `"`bind'"'=="yes" {
		cap rm "$Results/Outreg/`twinbind'.xls"
		cap rm "$Results/Outreg/`twinbind'.txt"	
		local out "$Results/Outreg/`twinbind'.xls"

		foreach outcome of varlist school_zscore educ attendance highschool {
			qui reg `outcome' T_Bind T_BindXtwin $basecont $morecont if `cond'
			reg `outcome' T_Bind $basecont [pw=sweight] if `cond'&e(sample), /*
			*/ cluster(_cou)
			outreg2 T_Bind $baseout using `out', excel append
			reg `outcome' T_Bind $basecont $morecont [pw=sweight] /*
			*/ if `cond'&e(sample), cluster(_cou)
			outreg2 T_Bind $baseout $moreout using `out', excel append
			reg `outcome' T_Bind T_BindXtwin $basecont [pw=sweight] /*
			*/ if `cond'&e(sample), cluster(_cou)
			outreg2 T_Bind T_BindXtwin $baseout using `out', excel append
			reg `outcome' T_Bind T_BindXtwin $basecont $morecont [pw=sweight] /*
			*/ if `cond', cluster(_cou)
			outreg2 T_Bind T_BindXtwin $baseout $moreout using `out', excel append
		}
	}
	***************************************************************************
	*** (3a) Final birth twins
	***************************************************************************
	if `"`final'"'=="yes" {
		cap rm "$Results/Outreg/`twinfinal'.xls"
		cap rm "$Results/Outreg/`twinfinal'.txt"
		local out2 "$Results/Outreg/`twinfinal'.xls"	

		foreach outcome of varlist school_zscore educ attendance highschool {
			qui reg `outcome' T_Final T_FinalXtwin $basecont $morecont if `cond'
			reg `outcome' T_Final $basecont [pw=sweight] if `cond'&e(sample), /*
			*/cluster(_cou)
			outreg2 T_Final $baseout using `out2', excel append
			reg `outcome' T_Final $basecont $morecont [pw=sweight] /*
			*/ if `cond'&e(sample), cluster(_cou)
			outreg2 T_Final $baseout $moreout using `out2', excel append
			reg `outcome' T_Final T_FinalXtwin $basecont [pw=sweight] /*
			*/ if `cond'&e(sample), cluster(_cou)
			outreg2 T_Final T_FinalXtwin $baseout using `out2', excel append
			reg `outcome' T_Final T_FinalXtwin $basecont $morecont [pw=sweight]/*
			*/ if `cond', cluster(_cou)
			outreg2 T_Final T_FinalXtwin $baseout $moreout using `out2', excel append
		}
	}
	***************************************************************************
	*** (3c) Twins ocurring after desired number
	***************************************************************************	
	if `"`after'"'=="yes" {
		cap rm "$Results/Outreg/`twinafter'.xls"
		cap rm "$Results/Outreg/`twinafter'.txt"	
		local out "$Results/Outreg/`twinafter'.xls"

		foreach outcome of varlist school_zscore educ attendance highschool {
			qui reg `outcome' T_After T_AfterXpretwin T_AfterXposttwin $basecont /*
			*/ $morecont if `cond'
			reg `outcome' T_After $basecont [pw=sweight] if `cond'&e(sample), /*
			*/cluster(_cou)
			outreg2 T_After $baseout using `out', excel append
			reg `outcome' T_After $basecont $morecont [pw=sweight] /*
			*/ if `cond'&e(sample), cluster(_cou)
			outreg2 T_After $baseout $moreout using `out', excel append
			reg `outcome' T_After T_AfterXpretwin T_AfterXposttwin $basecont /*
			*/ [pw=sweight] if `cond'&e(sample), cluster(_cou)
			outreg2 T_After* $baseout using `out', excel append
			reg `outcome' T_After T_AfterXpretwin T_AfterXposttwin $basecont/*
			*/ $morecont [pw=sweight] if `cond', cluster(_cou)
			outreg2 T_After* $baseout $moreout using `out', excel append
		}
	}
}

********************************************************************************
**** (4) Reduced Form Regressions on twin by birth order (this is by birth order
**** so that we are comparing families of size q with families of size q+1 due
**** to twins).
********************************************************************************
if `"`bord'"'=="yes" {
	if `"`bordfinal'"' == "yes" {
		local cond agefirstbirth>=14&age<22
		cap rm "$Results/Outreg/`twinbord'.xls"
		cap rm "$Results/Outreg/`twinbord'.txt"

		local out3 "$Results/Outreg/`twinbord'.xls"
		foreach birth of numlist 2(1)8 {
			dis in yellow "We are on birth number `birth' of 8"	
			local cond2 (fert==idealnumkids&FAMtwinbindsfinal==0&fert==`birth')|/*
			*/(fert==idealnumkids+1&fert==`birth'+1&FAMtwinbindsfinal==1)

			foreach outcome of varlist school_zscore educ attendance highschool {
				reg `outcome' T_Final T_FinalXtwin $basecont $morecont [pw=sweight] /*
				*/ if `cond'&`cond2'
				outreg2 T_Final T_FinalXtwin $baseout $moreout using `out3', excel append

				reg `outcome' T_Bind T_BindXtwin $basecont $morecont [pw=sweight] /*
				*/ if `cond'&`cond2'
				outreg2 T_Bind T_BindXtwin $baseout $moreout using `out3', excel append
			}
		}
	}

	if `"`bordafter'"' == "yes" {
		local cond agefirstbirth>=14&age<22
		cap rm "$Results/Outreg/`twinbordafter'.xls"
		cap rm "$Results/Outreg/`twinbordafter'.txt"

		local out "$Results/Outreg/`twinbordafter'.xls"
		foreach birth of numlist 2(1)8 {
			dis in yellow "We are on birth number `birth' of 8"	
			local cond2 (T_After==1&fert==`birth'+1)|(T_After==0&fert==`birth')

			foreach outcome of varlist school_zscore educ attendance highschool {
				reg `outcome' T_After $basecont $morecont [pw=sweight] if `cond'&`cond2'
				outreg2 T_After $baseout $moreout using `out', excel append


				reg `outcome' T_After $basecont [pw=sweight] if `cond'&`cond2'&e(sample)
				outreg2 T_After $baseout using `out', excel append

			}
		}
	}

	if `"`bordall'"' == "yes" {
		local cond agefirstbirth>=14&age<22
		cap rm "$Results/Outreg/`twinbordall'.xls"
		cap rm "$Results/Outreg/`twinbordall'.txt"

		local out "$Results/Outreg/`twinbordall'.xls"
		foreach birth of numlist 2(1)8 {
			dis in yellow "We are on birth number `birth' of 8"	
			local cond2 (T_Twin==1&fert==`birth'+1)|(T_Twin==0&fert==`birth')

			foreach outcome of varlist school_zscore educ attendance highschool {
				reg `outcome' T_Twin $basecont $morecont [pw=sweight] if `cond'&`cond2'
				outreg2 T_Twin $baseout $moreout using `out', excel append


				reg `outcome' T_Twin $basecont [pw=sweight] if `cond'&`cond2'&e(sample)
				outreg2 T_Twin $baseout using `out', excel append
			}
		}
	}	
}

********************************************************************************
**** (4a) Reduced Form Regressions on twin by birth order (by gender)
********************************************************************************
if `"`gend'"' == "yes" {	
	** remove outreg files
	foreach x in M {
		cap rm "$Results/Outreg/`gend_twinbordafter'_`x'.xls"
		cap rm "$Results/Outreg/`gend_twinbordafter'_`x'.txt"
		cap rm "$Results/Outreg/`gend_twinbordall'_`x'.xls"
		cap rm "$Results/Outreg/`gend_twinbordall'_`x'.txt"

		local cond agefirstbirth>=14&age<22&gender=="`x'"
		local loop 1
		foreach cond2 in cond_aft cond_all {
			if `loop'==1 local out "$Results/Outreg/`gend_twinbordafter'_`x'.xls"
			else if `loop'==2 local out "$Results/Outreg/`gend_twinbordall'_`x'.xls"		

			foreach y of varlist school_zscore attendance highschool {
				foreach birth of numlist 2(1)8 {

					local cond_aft (T_After==1&fert==`birth'+1)|(T_After==0&fert==`birth')
					local cond_all (T_Twin==1&fert==`birth'+1)|(T_Twin==0&fert==`birth')

					reg `y' T_After $basecont $morecont [pw=sweight] if `cond'&``cond2''
					outreg2 T_After $baseout $moreout using `out', excel append
				}
			}
		local ++loop
		}
	}
}

********************************************************************************
**** (4b) Reduced Form Regressions on twin by birth order (by income)
********************************************************************************
if `"`income'"' == "yes" {
	** remove outreg files
	foreach x in low mid {
		local cond agefirstbirth>=14&age<22&income=="`x'"

		cap rm "$Results/Outreg/`inc_twinbordafter'_`x'.xls"
		cap rm "$Results/Outreg/`inc_twinbordafter'_`x'.txt"
		cap rm "$Results/Outreg/`inc_twinbordall'_`x'.xls"
		cap rm "$Results/Outreg/`inc_twinbordall'_`x'.txt"

		local loop 1
		foreach cond2 in cond_aft cond_all {

			if `loop'==1 local out "$Results/Outreg/`inc_twinbordafter'_`x'.xls"
			else if `loop'==2 local out "$Results/Outreg/`inc_twinbordall'_`x'.xls"		

			foreach y of varlist school_zscore attendance highschool {
				foreach birth of numlist 2(1)8 {

					local cond_aft (T_After==1&fert==`birth'+1)|(T_After==0&fert==`birth')
					local cond_all (T_Twin==1&fert==`birth'+1)|(T_Twin==0&fert==`birth')

					reg `y' T_After $basecont $morecont [pw=sweight] if `cond'&``cond2''
					outreg2 T_After $baseout $moreout using `out', excel append
				}
			}
		local ++loop
		}
	}
}


********************************************************************************
**** (5) Reduced Form Regressions on pre-twins by birth order
********************************************************************************
if `"`bordpretwin'"'=="yes" {
	if `"`bordafter_pre'"' == "yes" {
		local cond agefirstbirth>=14&age<22&pretwinafter==1
		cap rm "$Results/Outreg/`twinbordafter_pre'.xls"
		cap rm "$Results/Outreg/`twinbordafter_pre'.txt"

		local out "$Results/Outreg/`twinbordafter_pre'.xls"
		foreach birth of numlist 2(1)8 {
			dis in yellow "We are on birth number `birth' of 8"	
			local cond2 (T_After==1&fert==`birth'+1)|(T_After==0&fert==`birth')

			foreach outcome of varlist school_zscore educ attendance highschool {
				reg `outcome' T_After $basecont $morecont [pw=sweight] if `cond'&`cond2'
				outreg2 T_After $baseout $moreout using `out', excel append


				reg `outcome' T_After $basecont [pw=sweight] if `cond'&`cond2'&e(sample)
				outreg2 T_After $baseout using `out', excel append

			}
		}
	}

	if `"`bordall_pre'"' == "yes" {
		local cond agefirstbirth>=14&age<22&pretwin==1
		cap rm "$Results/Outreg/`twinbordall_pre'.xls"
		cap rm "$Results/Outreg/`twinbordall_pre'.txt"

		local out "$Results/Outreg/`twinbordall_pre'.xls"
		foreach birth of numlist 2(1)8 {
			dis in yellow "We are on birth number `birth' of 8"	
			local cond2 (T_Twin==1&fert==`birth'+1)|(T_Twin==0&fert==`birth')

			foreach outcome of varlist school_zscore educ attendance highschool {
				reg `outcome' T_Twin $basecont $morecont [pw=sweight] if `cond'&`cond2'
				outreg2 T_Twin $baseout $moreout using `out', excel append


				reg `outcome' T_Twin $basecont [pw=sweight] if `cond'&`cond2'&e(sample)
				outreg2 T_Twin $baseout using `out', excel append
			}
		}
	}	
}
