/* TwinIVCheck 1.00                  UTF-8                         dh:2012-03-16
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 3000m

global Base H:\ExtendedEssay\Twins
log using $Base\Log\20120316_TwinIVCheck.txt, text replace
*use $Base\..\DHS\world_childsmall //small is 10% sample
use $Base\..\DHS\world_child

*_______________________________________________________________________________*
**SETUP**
gen twind=1 if twinc>0  //twind is actually multiple birth
replace twind=0 if twinc==0
sort caseid2
foreach num of numlist 1(1)10{
local num1=`num'+1
local num2=`num'+2
gen twinb`num'=1 if twind==1 & bord==`num' & twinc==1
*replace twinb`num'=1 if twind==1 & bord==`num1' & twinc==2
*replace twinb`num'=1 if twind==1 & bord==`num2' & twinc==3
replace twinb`num'=0 if twinb`num'!=1
}
foreach num of numlist 1(1)10{
by caseid2: egen twinfam`num'=max(twinb`num')
}

gen magebirth=agema/12
rename v301 contracept_know
rename v302 contracept_use
rename v501 maritalstatus
rename v504 husbandhouse
rename v715 educ_husband
replace educ_husband=0 if educ_husband==98
replace educ_husband=. if educ_husband>26
*tab partocc, gen(husb_work)
global x_complete i.bord i.fert malec b2006.yearc magebirth poor1 educfyrs /*
*/ educ_husband height bmi i.ncode
global x_complete_lessfert i.bord malec b2006.yearc magebirth poor1 educfyrs /*
*/ educ_husband height bmi i.ncode
global x_completeiv malec b2006.yearc magebirth poor1 educfyrs /*
*/ educ_husband height bmi i.ncode
global x_minimal i.bord i.fert
global x_completeL bord fert malec b2006.yearc magebirth poor1 educfyrs /*
*/educ_husband height bmi i.ncode
global x_minimalL i.bord fert 
global z twind

*gen y variables
*Gen ht/age, wt/age
gen child_age=round(agechild_cmc/12)
gen ht_age=hw3/child_age if agec<19
gen wt_age=hw2/child_age if agec<19 //these are no good.
keep if height<210 & height>85
*_______________________________________________________________________________*

**TWIN PREDICT**
gen death_u5=1 if b7<61
replace death_u5=0 if b7>61

reg twind $x_complete  //this is quite nice
reg fert $x_complete_lessfert
probit twind $x_complete


*_______________________________________________________________________________*
**OLS FULL SAMPLE**
reg mort15 $x_minimal [pw=sweight],vce(cluster ncode) //size and birthorder significant
reg mort15 $x_complete [pw=sweight], vce(cluster ncode)  //WHATS GOING ON WITH BIRTH ORDER?! Opposite to Black et al.
*could be that I am using full sample rather than similar family sizes.  Think.
outreg2 using $Base\Results\OLS, excel replace
reg mort15 $x_completeL [pw=sweight], vce(cluster ncode)
outreg2 using $Base\Results\OLS, excel append

**IV Strategy**
*A: TWIN AT SECOND BIRTH, LOOK AT FIRST BORNS IN FAMILIES W 2+ CHILDREN
gen mort15_1=mort15
replace mort15_1=. if bord!=1 | twind==1
replace mort15_1=. if fert==1
reg mort15_1 $x_complete [pw=sweight] if fert>1, vce(cluster ncode)
tab ncode, gen(dcncode)
ivreg2 mort15_1  malec yearc magebirth poor1 educfyrs /*
*/ educ_husband height bmi dcncode* (fert=twinb3)/*
*/ [pw=sweight], robust cluster(ncode) first

reg fert twinb1 if fert==1 //of course multicolinear
outreg2 using $Base\Results\twinb, excel replace
foreach num of numlist 2(1)10{
reg fert twinb`num'
outreg2 using $Base\Results\twinb, excel append
}
***NOTE: REVIEW SIGNS ON TWINNING ON FERTILITY BY BIRTH ORDER.  HIGHLY VARIABLE!
***INTERESTING AT B.ORDERS 1 AND 2.  


*no control
reg fert twind	
reg death_u5 fert
ivreg2 death_u5 (fert=twind), first

*control stage 2*
reg death_u5 fert educfyrs height bmi poor1

*IVreg w controls*
reg fert twind
reg death_u5 fert educfyrs height bmi poor1
ivreg2 death_u5 educfyrs height bmi poor1 (fert=twind), first



reg mort15 fert
outreg2 using $Base\Results\Result1, excel replace
ivreg2 mort15 (fert=twind)
outreg2 using $Base\Results\Result1, excel append
tab bord, gen(birthord)
ivreg2 mort15 malec yearc magebirth birthord* (fert=twind)
outreg2 using $Base\Results\Result1, excel append
ivreg2 mort15  malec yearc magebirth poor1 educfyrs /*
*/ educ_husband height bmi birthord* dcncode* (fert=twind)
outreg2 using $Base\Results\Result1, excel append


*_______________________________________________________________________________*
*
*NEW IV METHODOLOGY WITH MORTALITY FOLLOWED BY TWIN AS INDICATOR*
gen int_close=1 if b12<25
gen one_plus=1 if bord==1 & fert>=2
replace one_plus=0 if bord>1|fert==1
replace one_plus=0 if twinc!=0
gen twin2=1 if twinc==1 & bord==2
replace twin2=0 if twin2!=1
bys caseid2: egen twin_one_fam=max(twin2)

*RUN THIS FOR 2 PLUS ETC.
gen two_plus=1 if bord==2 & fert>=3
replace two_plus=0 if two_plus!=1
replace two_plus=0 if twinc!=0
gen twin3=1 if twinc==1 & bord==3
replace twin3=0 if twin3!=1
bys caseid2: egen twin_two_fam=max(twin3)

gen three_plus=1 if bord==3 & fert>=4
replace three_plus=0 if three_plus!=1
replace three_plus=0 if twinc!=0
gen twin4=1 if twinc==1 & bord==4
replace twin4=0 if twin4!=1
bys caseid2: egen twin_three_fam=max(twin4)

gen four_plus=1 if bord==4 & fert>=5
replace four_plus=0 if four_plus!=1
replace four_plus=0 if twinc!=0
gen twin5=1 if twinc==1 & bord==5
replace twin5=0 if twin5!=1
bys caseid2: egen twin_four_fam=max(twin5)


tab country, gen(country)
tab agec, gen(age)
tab yearc, gen(yearc)
tab v701, gen(educmale)
drop educfyrs2
tab educfyrs, gen(educfyrs)
tab cont_name, gen(cont_name)
tab bord, gen(borddummy)

global borddummies_one
global borddummies_two borddummy2
global borddummies_three borddummy2 borddummy3
global borddummies_four borddummy2 borddummy3 borddummy4

foreach region in country1-country46 cont_name1-cont_name3{
foreach x in one two three  {
reg mort15 fert yearc1-yearc84 `region' /*
*/ $borddummies_`x' if int_close==1 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Mort1.xls, excel append
ivreg2 mort15 (fert=twin_`x'_fam) yearc1-yearc84 `region'/*
*/ $borddummies_`x' if int_close==1 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Mort1.xls, excel append
ivreg2 mort15 (fert=twin_`x'_fam) educfyrs height bmi poor1 /*
*/ yearc1-yearc84 `region' $borddummies_`x' if int_close==1 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Mort1.xls, excel append
ivreg2 mort15 (fert=twin_`x'_fam) educmale1- educmale6 educfyrs1- educfyrs28 height bmi poor1 /*
*/ yearc1-yearc84 `region' $borddummies_`x' if int_close==1 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Mort1.xls, excel append
}
}
