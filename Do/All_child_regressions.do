/* Regressions 2.00                 UTF-8                          dh:2013-02-24
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
global Base "~/investigacion/Activa/Twins"
global Data "$Base/Data"
global Results "~/investigacion/Activa/Twins/ResultsNEW2"
log using $Base/Log/All_child_regressions.log, text replace

*Q-Q CONTROLS
global basic malec agemay age17-age18 i.child_yob i._cou /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global socioeconomic educf_* poor1 malec agemay age17-age18 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global allcontrols educf_* poor1 height bmi malec agemay age17-age18 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7

*SWITCHES
local sumstats no
local bybirth no
local pooled yes
local ols no

*******************************************************************************
*** (1) Setup (+ discretionary choices)
*******************************************************************************
use $Data/DHS_twins_twinsonly

replace bmi=. if bmi>42
replace height=. if height>240
replace height=. if height<80



*******************************************************************************
*** (2) Summary Stats
*******************************************************************************
if `"`sumstats'"'=="yes" {
	
	*(1) Freq distribution of twins by bord of twins
	byhist bord  if bord<11, by(twin_birth) tw(legend(label(1 "Single Birth") ///
	label(2 "Twin Birth")) title("Birth type by birth order") ///
	graphregion(color(white)) bgcolor(white)) frac	
	graph export $Results/birthtype.eps, as(eps) replace
	graph export $Results/birthtype.png, as(png) replace	
	*byhist bord, by(twin_birth) frac
	*twoway kdensity bord if twin_birth==1 || kdensity bord if twin_birth==0, ///
	*legend(label(1 "Twin Birth") label(2 "Single Birth")) ///
	*title("Birth type by birth order")
	twoway kdensity fert if twin_birth==1, bw(2) || kdensity fert if twin_birth==0, ///
	bw(2) legend(label(1 "Twin Family") label(2 "Singleton Family")) ytitle("Density") ///
	title("Total births by Family Type") xtitle("total children ever born") 

	*(2) % twins at last birth, % twins at last birth with family size at ideal
	tab twintype
	tab singletype

	*(3) Distribution of twins overlaid with distbn of family size	
	byhist fert, by(twinfamily) tw(legend(label(1 "Singleton Family") ///
	label(2 "Twin family")) title("Total births by family type") ///
	graphregion(color(white)) bgcolor(white)) frac
	graph export $Results/familytype.eps, as(eps) replace	
	graph export $Results/familytype.png, as(png) replace		
	
	*(3b) Twins by bord
	sum twind	
	local meantwin %6.4f r(mean)
	preserve
	collapse twind, by(bord)
	line twind bord if bord<19, title("Twinning by birth order") ///
	ytitle("Fraction twins") xtitle("Birth Order") yline(0.0207) ///
	note("Single births are 1-frac(twins).  Total fraction of twins is 0.0207")	
	restore
	
	
	*(4) Do families continue with births when hitting ideal (with twins)?
	tab FAMtwinbinds FAMtwinbindsfinal

	*(5) % of unplanned births (after ideal number, also if wanted)
	tab idealfam

	*(6) characteristics of families who want different ideal sizes (P.Dev idea)
	areg idealnumkids educf_* fert agefirstbirth poor1 i.year_birth i.child_yob ///
	height bmi [pw=sweight], a(_cou) cluster(_cou)
	outreg2 educf_0 educf_1_4 educf_5_6 educf_7_10 fert agefirstbirth poor1 /*
	*/educ height bmi using $Results/fampref.tex, tex(pr) replace
	outreg2 educf_0 educf_1_4 educf_5_6 educf_7_10 fert agefirstbirth poor1 /*
	*/educ height bmi using $Results/fampref.xls, excel replace	
}

*******************************************************************************
*** (2b) OLS/ AltonjiTaber
*******************************************************************************
if `"`ols'"'=="yes" {
	local base malec age agesq agemay magesq agefirstbirth i.year_birth i._cou
	local socioec educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1
	local health height bmi

	cap rm $Base/Results/ols_AT.xls
	cap rm $Base/Results/ols_AT.txt

	cap gen a=1
	local group1 a==1 
	local group2 income_s=="LOWINCOME"
	local group3 income_s=="LOWERMIDDLE"
	local group4 income_s=="UPPERMIDDLE"

	foreach outcome of varlist school_zscore attendance educ highschool {
		foreach cond1 in `group1' `group2' `group3' `group4'{
			if `"`outcome'"'=="highschool" local condition if age>13
			else local condition if age>6&age<19
			
			reg `outcome' fert `base' [pw=sweight] `condition'&(`cond1'), cluster(_cou)
			outreg2 fert using $Base/Results/ols_AT.xls, excel append
			reg `outcome' fert `base' `socioec' [pw=sweight] `condition'&(`cond1'), cluster(_cou)
			outreg2 fert using $Base/Results/ols_AT.xls, excel append
			reg `outcome' fert `base' `socioec' `health' [pw=sweight] `condition'&(`cond1'), cluster(_cou)
			outreg2 fert using $Base/Results/ols_AT.xls, excel append
		}
	}
}

*******************************************************************************
*** (3) Twin effect on all siblings
*******************************************************************************
if `"`bybirth'"'=="yes" {
	gen pretwin=bord<twin_bord_fam&twinfamily==1
	*replace pretwin=0 if bord>=twinbord&twinfamily==1
	gen posttwin=bord>twin_bord_fam&twind!=1&twinfamily==1
	*replace posttwin=0 if posttwin==.&twinfamily==1

	cap rm $Base/Results/AltSpec/all_school_zscore.xls
	cap rm $Base/Results/AltSpec/all_school_zscore.txt
	cap rm $Base/Results/AltSpec/all_attendance.xls
	cap rm $Base/Results/AltSpec/all_attendance.txt
	cap rm $Base/Results/AltSpec/all_educ.xls
	cap rm $Base/Results/AltSpec/all_educ.txt
	cap rm $Base/Results/AltSpec/all_twinfamily.xls
	cap rm $Base/Results/AltSpec/all_twinfamily.txt
	cap rm $Base/Results/AltSpec/all_highschool.xls
	cap rm $Base/Results/AltSpec/all_highschool.txt

	foreach num of numlist 1(1)8 {
		dis in red "`num'"
		local num1 `num'+1
		preserve
		keep if (fert==`num'&twinfamily==0)|(fert==`num1'&twinfamily==1)
		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			}
			reg `outcome' twinfamily malec age agesq agemay magesq i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily malec age agesq agemay magesq using $Base/Results/AltSpec/all_twinfamily.xls, excel append
			reg `outcome' twinfamily malec age agesq agemay magesq height bmi educf_* poor1 i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily malec age agesq agemay magesq educf_* poor1 using $Base/Results/AltSpec/all_twinfamily.xls, excel append

			reg `outcome' twinfamily pretwin posttwin malec age agesq agemay magesq i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily pretwin posttwin malec age agesq agemay magesq using $Base/Results/AltSpec/all_`outcome'.xls, excel append
			reg `outcome' twinfamily pretwin posttwin malec age agesq agemay magesq height bmi /*educf_**/ educf poor1 i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily pretwin posttwin malec age agesq agemay magesq height bmi /*educf_**/ educf poor1 using $Base/Results/AltSpec/all_`outcome'.xls, excel append
		}
		restore
	}


	*******************************************************************************
	*** (4) Twin effect where twin is final birth (binds in some way)
	*******************************************************************************
	*family with three kids where singleton is born on final birth vs four kids
	*where twins are born on third birth

	cap rm $Base/Results/AltSpec/final_school_zscore.xls
	cap rm $Base/Results/AltSpec/final_school_zscore.txt
	cap rm $Base/Results/AltSpec/final_attendance.xls
	cap rm $Base/Results/AltSpec/final_attendance.txt
	cap rm $Base/Results/AltSpec/final_educ.xls
	cap rm $Base/Results/AltSpec/final_educ.txt
	cap rm $Base/Results/AltSpec/final_twinfamily.xls
	cap rm $Base/Results/AltSpec/final_twinfamily.txt
	cap rm $Base/Results/AltSpec/final_highschool.xls
	cap rm $Base/Results/AltSpec/final_highschool.txt

	foreach num of numlist 2(1)8 {
		preserve
		local num1 `num'+1
		keep if (fert==`num'&twinfamily==0)|(fert==`num1'&finaltwinfamily==1)
		gen pretwin_f=bord<`num'
		gen pretwinXfinaltwin=pretwin_f*finaltwinfamily

		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			} 
			reg `outcome' finaltwinfamily malec age agemay i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 finaltwinfamily malec age agemay using $Base/Results/AltSpec/final_twinfamily.xls, excel append
			reg `outcome' finaltwinfamily malec age agemay height bmi educf_* poor1 i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 finaltwinfamily malec age agemay height bmi educf_* poor1 using $Base/Results/AltSpec/final_twinfamily.xls, excel append

			reg `outcome' finaltwinfamily pretwinXfinaltwin pretwin_f malec age agemay i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 finaltwinfamily pretwinXfinaltwin pretwin_f malec age agemay using $Base/Results/AltSpec/final_`outcome'.xls, excel append
			reg `outcome' finaltwinfamily pretwinXfinaltwin pretwin_f malec age agemay height bmi /*educf_**/ educf poor1 i._cou i.year_birth [pw=sweight] `condition', cluster(_cou)
			outreg2 finaltwinfamily pretwinXfinaltwin pretwin_f malec age agemay height bmi /*educf_**/ educf poor1 using $Base/Results/AltSpec/final_`outcome'.xls, excel append
		}
		restore
	}

	*******************************************************************************
	*** (5) Twin pushes family over ideal birth number
	*******************************************************************************
	** Family wants three kids and has twins on 3rd birth vs family wants 3 kids
	** and has singleton on third birth
	cap rm $Base/Results/AltSpec/bind_school_zscore.xls
	cap rm $Base/Results/AltSpec/bind_school_zscore.txt
	cap rm $Base/Results/AltSpec/bind_attendance.xls
	cap rm $Base/Results/AltSpec/bind_attendance.txt
	cap rm $Base/Results/AltSpec/bind_educ.xls
	cap rm $Base/Results/AltSpec/bind_educ.txt
	cap rm $Base/Results/AltSpec/bind_twinfamily.xls
	cap rm $Base/Results/AltSpec/bind_twinfamily.txt
	cap rm $Base/Results/AltSpec/bind_highschool.xls
	cap rm $Base/Results/AltSpec/bind_highschool.txt

	foreach num of numlist 2(1)8 {
		local num1 `num'+1

		gen sample=1 if idealnumkids==`num' & (fert==`num'&FAMtwinbindsfinal==0|fert==`num1'&FAMtwinbindsfinal==1)
		gen pre`num'=bord<`num' if sample==1
		gen twinbindfamily`num'=FAMtwinbindsfinal if sample==1
		gen twinXpre`num'=pre`num'*twinbindfamily`num' if sample==1
		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			}		
			reg `outcome' twinbindfamily`num' malec age agemay i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 twinbindfamily`num' malec age agemay using $Base/Results/AltSpec/bind_twinfamily.xls, excel append
			reg `outcome' twinbindfamily`num' malec age agemay height bmi educf_* poor1 i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 twinbindfamily`num' malec age agemay height bmi educf_* poor1 using $Base/Results/AltSpec/bind_twinfamily.xls, excel append
		
			reg `outcome' twinbindfamily`num' twinXpre`num' pre`num' malec age agemay i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 twinbindfamily`num' twinXpre`num' pre`num' malec age agemay using $Base/Results/AltSpec/bind_`outcome'.xls, excel append
			reg `outcome' twinbindfamily`num' twinXpre`num' pre`num' malec age agemay height bmi /*educf_**/ educf poor1 i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 twinbindfamily`num' twinXpre`num' pre`num' malec age agemay height bmi /*educf_**/ educf poor1 using $Base/Results/AltSpec/bind_`outcome'.xls, excel append
		}
		drop sample




/*		gen finaltwin`num'=1 if twin==1&fert==`num1'&bord==`num'  //CHECK THIS.  SHOULDN'T IT BE -1?
*		replace finaltwin`num'=1 if twin==2&fert==`num1'&bord==`num'
*		bys id: egen finaltwinfamily`num'=max(finaltwin`num')

		gen sample=1 if idealnumkids==`num' & (fert==`num'|fert==`num1'&finaltwinfamily`num'==1)
		gen pre`num'=bord<`num' if sample==1
		replace finaltwinfamily`num'=0 if finaltwinfamily`num'==. & sample==1
		gen twinXpre`num'=pre`num'*finaltwinfamily`num' if sample==1

		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			}		
			reg `outcome' finaltwinfamily`num' malec age agemay i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 finaltwinfamily`num' malec age agemay using $Base/Results/AltSpec/bind_twinfamily.xls, excel append
			reg `outcome' finaltwinfamily`num' malec age agemay height bmi educf_* poor1 i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 finaltwinfamily`num' malec age agemay height bmi educf_* poor1 using $Base/Results/AltSpec/bind_twinfamily.xls, excel append
		
			reg `outcome' finaltwinfamily`num' twinXpre`num' pre`num' malec age agemay i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 finaltwinfamily`num' twinXpre`num' pre`num' malec age agemay using $Base/Results/AltSpec/bind_`outcome'.xls, excel append
			reg `outcome' finaltwinfamily`num' twinXpre`num' pre`num' malec age agemay height bmi /*educf_**/ educf poor1 i._cou i.year_birth [pw=sweight] `condition' & sample==1, cluster(_cou)
			outreg2 finaltwinfamily`num' twinXpre`num' pre`num' malec age agemay height bmi /*educf_**/ educf poor1 using $Base/Results/AltSpec/bind_`outcome'.xls, excel append
		}
		drop sample
*/


	}
}

*******************************************************************************
**** (6) Pooled sample
*******************************************************************************
if `"`pooled'"'=="yes" {
	cap gen a=1
	local allinc a==1 
	local lowinc income_s=="LOWINCOME"
	local midinc income_s=="LOWERMIDDLE"|income_s=="UPPERMIDDLE"

	foreach inc in `allinc' `lowinc' `midinc' {
		if `"`inc'"'==`"`allinc'"' {
			local folder allinc
			dis "allinc loop"
			dis "`folder'"
		}
		else if `"`inc'"'==`"`lowinc'"' {
			local folder lowinc
			dis "lowinc loop"			
			dis "`folder'"
		}
		else if `"`inc'"'==`"`midinc'"' {
			local folder midinc
			dis "midinc loop"
			dis "`folder'"
		}
		
		cap mkdir $Base/Results/AltSpec/`folder'
		
		
		local basecontrols malec age agesq agemay magesq i._cou i.year_birth 
		local morecontrols height bmi educf_1_4 educf_5_6 educf_7_10 educf_11plus poor1
		local baseoutregvars malec age agesq agemay magesq 
		local moreoutregvars malec age agesq agemay magesq `morecontrols'

		foreach outcome in school_zscore attendance educ highschool twinfamily {
	*		cap rm $Base/Results/AltSpec/POOLall_`outcome'.xls
	*		cap rm $Base/Results/AltSpec/POOLall_`outcome'.txt
			cap rm $Base/Results/AltSpec/`folder'/POOLfinal_`outcome'.xls
			cap rm $Base/Results/AltSpec/`folder'/POOLfinal_`outcome'.txt
			cap rm $Base/Results/AltSpec/`folder'/POOLbind_`outcome'.xls
			cap rm $Base/Results/AltSpec/`folder'/POOLbind_`outcome'.txt
		}

		*ALL
		cap gen pretwin=bord<twin_bord_fam&twinfamily==1
		cap gen posttwin=bord>twin_bord_fam&twind!=1&twinfamily==1

		
	/*	foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			}
			reg `outcome' twinfamily `basecontrols' [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily `baseoutregvars' using $Base/Results/AltSpec/POOLall_twinfamily.xls, excel append
			reg `outcome' twinfamily `basecontrols' `morecontrols' [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily `moreoutregvars' using $Base/Results/AltSpec/POOLall_twinfamily.xls, excel append

			reg `outcome' twinfamily pretwin posttwin `basecontrols' [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily pretwin posttwin `baseoutregvars' using $Base/Results/AltSpec/POOLall_`outcome'.xls, excel append
			reg `outcome' twinfamily pretwin posttwin `basecontrols' `morecontrols' [pw=sweight] `condition', cluster(_cou)
			outreg2 twinfamily pretwin posttwin `moreoutregvars' using $Base/Results/AltSpec/POOLall_`outcome'.xls, excel append
		}
	*/	
		*FINAL BIRTH
		cap gen pretwin_f=bord<twin_bord_fam
		cap replace pretwin_f=pretwin_f*finaltwinfamily

		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13
			}
			else {
				local condition if age>6&age<19
			}
			reg `outcome' finaltwinfamily `basecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 finaltwinfamily `baseoutregvars' using $Base/Results/AltSpec/`folder'/POOLfinal_twinfamily.xls, excel append
			reg `outcome' finaltwinfamily `basecontrols' `morecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 finaltwinfamily `moreoutregvars' using $Base/Results/AltSpec/`folder'/POOLfinal_twinfamily.xls, excel append

			reg `outcome' finaltwinfamily pretwin_f `basecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 finaltwinfamily pretwin_f `baseoutregvars' using $Base/Results/AltSpec/`folder'/POOLfinal_`outcome'.xls, excel append
			reg `outcome' finaltwinfamily pretwin_f `basecontrols' `morecontrols'  [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 finaltwinfamily pretwin_f `moreoutregvars' using $Base/Results/AltSpec/`folder'/POOLfinal_`outcome'.xls, excel append
		}	
		*BINDING
		cap gen pretwin_f=bord<twin_bord_fam
		cap replace pretwin_f=pretwin_f*FAMtwinbindsfinal
		
		foreach outcome of varlist school_zscore attendance educ highschool {
			if `"`outcome'"'=="highschool" {
				local condition if age>13&(fert==idealnumkids&FAMtwinbindsfinal==0)|(fert==idealnumkids+1&FAMtwinbindsfinal==1)
			}
			else {
				local condition if age>6&age<19&(fert==idealnumkids&FAMtwinbindsfinal==0)|(fert==idealnumkids+1&FAMtwinbindsfinal==1)
			}
			reg `outcome' FAMtwinbindsfinal `basecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 FAMtwinbindsfinal `baseoutregvars' using $Base/Results/AltSpec/`folder'/POOLbind_twinfamily.xls, excel append
			reg `outcome' FAMtwinbindsfinal `basecontrols' `morecontrols'  [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 FAMtwinbindsfinal `moreoutregvars' using $Base/Results/AltSpec/`folder'/POOLbind_twinfamily.xls, excel append
			
			reg `outcome' FAMtwinbindsfinal pretwin_f `basecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 FAMtwinbindsfinal pretwin_f `baseoutregvars' using $Base/Results/AltSpec/`folder'/POOLbind_`outcome'.xls, excel append
			reg `outcome' FAMtwinbindsfinal pretwin_f `basecontrols' `morecontrols' [pw=sweight] `condition'&`inc', cluster(_cou)
			outreg2 FAMtwinbindsfinal pretwin_f `moreoutregvars' using $Base/Results/AltSpec/`folder'/POOLbind_`outcome'.xls, excel append
		}
	}
}
