* Twin_Setup 1.00              Damian C. Clarke			   yyyy-mm-dd:2012-07-25    
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000


********************************************************************************
****(1) Globals and locals
********************************************************************************
global PATH "~/investigacion/Activa/Twins"
global DATA "~/database/DHS/DHS_Data"
global LOG "$PATH/Log"
global TEMP "$PATH/Temp"

cap mkdir $PATH/Temp


log using "$LOG/Twins_DHS.txt", text replace
********************************************************************************
*** (2) Take necessary variables from BR (mother births) and PR (household me-
*** mber) The IR dataset has the majority of family and maternal characterist-
*** ics used in the regressions, however there is no child education variables
*** in this dataset.  The child education information comes from PR.
********************************************************************************
***Do in parts as merge of full dataset is impossible with 8gb of RAM
foreach num of numlist 1(1)7 {
	use $DATA/World_BR_p`num', clear

	keep _cou _year caseid v000-v026 v101 v106 v107 v130 v131 v133 v136 v137 /*
	*/ v149 v150 v151 v152 v190 v191 v201 v202 v203 v204 v205 v206 v207 v208 /*
	*/ v209 v211 v212 v213 v228 v229 v230 v437 v438 v445 v457 v463a v481 v501/*
	*/ v504 v602 v605 v715 v701 v730 bord b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 /*
	*/ b12 b13 b14 b15 b16 v613 v614 m19 m19a v367 v312 v364
	
	cap rename v010 year_birth
	cap rename v012 agemay
	cap rename v106 educlevel_f
	cap rename v130 religion
	cap rename v133 educf
	cap rename v137 kids_under5
	cap rename v140 rural
*	cap rename v150 relation_hhh
	cap rename v190 wealth
	cap rename v201 fert
	cap rename v212 agefirstbirth
	cap rename v228 terminated_preg
	cap rename v437 weight
	cap rename v438 height
	cap rename v445 bmi
	cap rename v367 wanted_last_child
	cap rename v312 contracep_method
	cap rename v364 contracep_intent
	cap rename b0 twin
	cap rename b2 child_yob
	cap rename b3 child_dob
	cap rename b4 sex
	cap rename b5 child_alive
	cap rename b8 age 

	replace age=floor(v007-child_yob+(v006-b1/12)) if age==.


	**The following lines correct for the fact that we only observe each births'
	**mothers' relationship to the household head.  In this way, if the mother 
	**is the wife, the birth must be the child of the household head.
	gen relationship=3 if v150==1|v150==2|v150==9
	replace relationship=5 if v150==3|v150==4|v150==11
	replace relationship=8 if v150==6|v150==7
	replace relationship=10 if v150==8|v150==10|v150==12|v150==5
	
	egen id=concat(_cou _year v001 v002)

	save $TEMP/BR`num', replace
}


foreach num of numlist 1(1)7 {
	use $DATA/World_PR_p`num', clear

	keep _cou _year hhid hvidx hv000-hv002 hv101 hv104 hv105 hv106 hv121 hv122/*
	*/ hv123 hv129 hv108

	cap rename hv101 relationship
	cap rename hv104 sex
	cap rename hv105 age
	cap rename hv106 educlevel
	cap rename hv121 attend_year
	cap rename hv129 attend
	cap rename hv108 educ
	rename hv001 v001
	rename hv002 v002
	egen id=concat(_cou _year v001 v002)
	
	save $TEMP/PR`num', replace
}

***Merge PR and BR (still in parts)
foreach num of numlist 1(1)7 {
	use $TEMP/PR`num'
	merge m:m id relationship sex age using $TEMP/BR`num'
	keep if _merge==3|_merge==2 //updated Apr 24, 2013
	save $TEMP/twins`num', replace
}

// Remove partial PR/BR datasets
foreach t in PR BR {
	foreach file in `t'1 `t'2 `t'3 `t'4 `t'5 `t'6 `t'7 {
		rm "$TEMP/`file'.dta"
	}
}

use $TEMP/twins1
append using $TEMP/twins2 $TEMP/twins3 $TEMP/twins4 $TEMP/twins5 $TEMP/twins6 /*
*/ $TEMP/twins7

foreach num of numlist 1(1)7 {
	rm $TEMP/twins`num'.dta
}
rmdir $TEMP

replace _cou="CAR" if hv000=="CF3" &_cou==""
replace _cou="Zimbabwe" if hv000=="ZW6" &_cou==""
replace _year="2004" if hv000=="CF3" &_year==""
replace _year="2010" if hv000=="ZW6" &_year==""

save $PATH/Data/DHS_twins, replace

********************************************************************************
*** (3) Setup Variables which are used in TwinRegression
********************************************************************************
use $PATH/Data/DHS_twins, clear
*** Generate sibling size subgroups (1+, 2+, 3+, 4+,...)  As per Angrist et al.
local max 1
local fert 2
//For a more extensive version of this loop see TwinSetup.do
foreach num in one two three four five six {
	gen `num'_plus=(bord>=1&bord<=`max')&fert>=`fert'  
	replace `num'_plus=0 if twin!=0
	gen twin`num'=(twin==1 & bord==`fert')
	bys id: egen twin_`num'_fam=max(twin`num') 
	local ++max
	local ++fert
}

*** "Quality" variables
*** Attendance
gen attendance=0 if attend_year==0
replace attendance=1 if attend_year==2
replace attendance=2 if attend_year==1
replace attendance=. if age<6

*** Schooling gap
gen gap=age-educ-6 if age>6 & age<17
replace gap=. if gap<-2

replace educ=. if educ>25 // come back and check what this means to sample
*** Z-Score
bys _cou age: egen sd_educ=sd(educ)
bys _cou age: egen mean_educ=mean(educ)
gen school_zscore=(educ-mean_educ)/sd_educ
replace school_zscore=. if age<6

*** Highschool
gen highschool=1 if (educlevel==2|educlevel==3)&age>11
replace highschool=0 if (educlevel==0|educlevel==1)&age>11

*** Control variables
tab v701, gen(educmale)
tab bord, gen(borddummy)
tab age, gen(age)

gen educfyrs_sq=educf*educf
gen educf_0=educf==0
gen educf_1_4=educf>0&educf<5
gen educf_5_6=educf>4&educf<7
gen educf_7_10=educf>6&educf<11
gen educf_11plus=educf>10
gen twind=1 if twin>=1&twin!=.
gen twind100=twin*100
gen malec=(sex==1)

replace height=height/10
replace bmi=bmi/100

gen poor1=wealth==1
gen agesq=age*age
gen magesq=agemay*agemay

*** General variables (country year)
rename _cou country
rename v005 sweight
encode country, gen(_cou)

***Year of birth for Nepal (convert from Vikram Samvat to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+2000 if country=="Nepal" & `year'<100
	replace `year'=`year'-57 if country=="Nepal"
}
***Year of birth for Ethipia (convert from Ge'ez to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+8 if country=="Ethiopia"
}
replace child_yob=child_yob+1900 if child_yob<100&child_yob>2
replace child_yob=child_yob+2000 if child_yob<=2
replace year_birth=year_birth+1900 if year_birth<100

*ID
gen mid="a"
drop id
egen id=concat(_cou mid _year mid v001 mid v002 mid v150 mid caseid)

********************************************************************************
*** (3a) Twin variables
********************************************************************************
replace twind=0 if twin==0
gen twin_birth=twind
bys id: egen twinfamily=max(twind)

gen twin_bord=bord if twin==1
replace twin_bord=bord-1 if twin==2
replace twin_bord=bord-2 if twin==3
replace twin_bord=bord-3 if twin==4

bys id: egen twin_bord_fam=max(twin_bord)

/*There are two ways to generate the twin binding variable.  One is to look at 
all twins that occur on the final birth where the family exceeds their ideal 
number (no matter what the number).  This is twintype==3.

The second way is to look at twins which are born and which make the family 
exceed their ideal number exactly (eg twins birth at bord=2 where family only 
wanted 2. Then if the family stops after the twin we have the most rigid 
possible definition.
*/

*Twins born on final birth (not nice, but effective at finding final twin bord.)
bys id: egen nummultiple=max(twin)  // is family singleton, twin, triplet,...
gen finaltwin=1 if (twin==2&fert==bord)&nummultiple<=2
replace finaltwin=1 if (twin==1&(fert-1)==bord)&nummultiple<=2
replace finaltwin=1 if (twin==3&fert==bord)&nummultiple==3
replace finaltwin=1 if (twin==2&(fert-1)==bord)&nummultiple==3
replace finaltwin=1 if (twin==1&(fert-2)==bord)&nummultiple==3
replace finaltwin=1 if (twin==4&fert==bord)&nummultiple==4
replace finaltwin=1 if (twin==3&(fert-1)==bord)&nummultiple==4
replace finaltwin=1 if (twin==2&(fert-2)==bord)&nummultiple==4
replace finaltwin=1 if (twin==2&(fert-3)==bord)&nummultiple==4
replace finaltwin=0 if finaltwin==.


bys id: egen finaltwinfamily=max(finaltwin)
replace finaltwinfamily=0 if finaltwinfamily==.

*FERTILITY VARS
gen idealnumkids=v613 if v613<11
replace idealnumkids=11 if v613>=11&v613<50
replace idealnumkids=11 if v613==94|v613==95|v613==96
lab def idealnumkids 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11+"
lab val idealnumkids numkids

gen lastbirth=fert==bord&twin==0
replace lastbirth=1 if (twin_bord==(fert-1))&nummultiple==2
replace lastbirth=1 if (twin_bord==(fert-2))&nummultiple==3
replace lastbirth=1 if (twin_bord==(fert-3))&nummultiple==4

gen wantedbirth=bord<=idealnumkids
gen idealfam=0 if idealnumkids==fert
replace idealfam=1 if idealnumkids<fert
replace idealfam=-1 if idealnumkids>fert

gen quant_exceed=fert-idealnumkids

gen exceeder=1 if bord-idealnumkids==1

gen twinexceeder=exceeder==1&twin==2|twin==3|twin==4
bys id: egen twinexceedfamily=max(twinexceeder)

*Twins born on final birth causing parents to exceed desired family size
gen twinexceed=finaltwin==1&idealfam==1
gen singlexceed=finaltwin==0&idealfam==1
gen twinattain=finaltwin==1&idealfam==0

gen twintype=1 if twind==1&lastbirth==0
replace twintype=2 if twind==1&lastbirth==1&idealfam!=1
replace twintype=3 if twind==1&lastbirth==1&idealfam==1

gen singletype=1 if twind==0&lastbirth==0
replace singletype=2 if twind==0&lastbirth==1&idealfam!=1
replace singletype=3 if twind==0&lastbirth==1&idealfam==1

/*twinbinds takes the value of 1 for all twins who cause parents 
to precisely exceed their desired number of children.  For twin
pairs this is twins who are first born at desired fertility, or
twins who are born second at desired fertility plus 1.  For triplets
this is the triplet who is born first at desired fertility or desired
fertility minus one, or the second or third birth at desired or 
desired+1 and desired or desired+2 respectively.  A similar definition 
exists for 4 multiple births
*/
gen twinbinds=1 if nummultiple<=2&((twin==1&bord==idealnumkids) /*
*/|(twin==2&bord==idealnumkids+1))
replace twinbinds=1 if nummultiple==3&((twin==1&bord==idealnumkids) /*
*/|(twin==1&bord==idealnumkids-1)|(twin==2&bord==idealnumkids+1) /*
*/|(twin==2&bord==idealnumkids)|(twin==3&bord==idealnumkids+1) /*
*/|(twin==3&bord==idealnumkids+2))
replace twinbinds=1 if nummultiple==4&((twin==1&bord==idealnumkids)| /*
*/(twin==1&bord==idealnumkids-1)|(twin==1&bord==idealnumkids-2)| /*
*/(twin==2&bord==idealnumkids-1)|(twin==2&bord==idealnumkids)| /*
*/(twin==2&bord==idealnumkids+1)|(twin==3&bord==idealnumkids)| /*
*/(twin==3&bord==idealnumkids+1)|(twin==3&bord==idealnumkids+2)| /*
*/(twin==4&bord==idealnumkids+1)|(twin==4&bord==idealnumkids+2)| /*
*/(twin==4&bord==idealnumkids+3))
replace twinbinds=0 if twinbinds!=1

/*twinbindsfinal takes the value of 1 for all twins who cause parents 
to precisely exceed their desired number of children, and who aren't
followed by other children.
*/

gen twinbindsfinal=1 if nummultiple<=2& /*
*/((twin==1&bord==idealnumkids&bord==fert-1)| /*
*/(twin==2&bord==idealnumkids+1&bord==fert))
replace twinbindsfinal=1 if nummultiple==3& /*
*/((twin==1&bord==idealnumkids&bord==fert-2)| /*
*/(twin==1&bord==idealnumkids-1&bord==fert-2)| /*
*/(twin==2&bord==idealnumkids+1&bord==fert-1)| /*
*/(twin==2&bord==idealnumkids&bord==fert-1)| /*
*/(twin==3&bord==idealnumkids+1&bord==fert)| /*
*/(twin==3&bord==idealnumkids+2&bord==fert-1))
replace twinbindsfinal=1 if nummultiple==4& /*
*/((twin==1&bord==idealnumkids&bord==fert-3)| /*
*/(twin==1&bord==idealnumkids-1&bord==fert-3)| /*
*/(twin==1&bord==idealnumkids-2&bord==fert-3)| /*
*/(twin==2&bord==idealnumkids-1&bord==fert-2)| /*
*/(twin==2&bord==idealnumkids&bord==fert-2)| /*
*/(twin==2&bord==idealnumkids+1&bord==fert-2)| /*
*/(twin==3&bord==idealnumkids&bord==fert-1)| /*
*/(twin==3&bord==idealnumkids+1&bord==fert-1)| /*
*/(twin==3&bord==idealnumkids+2&bord==fert-1)| /*
*/(twin==4&bord==idealnumkids+1&bord==fert)| /*
*/(twin==4&bord==idealnumkids+2&bord==fert)| /*
*/(twin==4&bord==idealnumkids+3&bord==fert))
replace twinbindsfinal=0 if twinbindsfinal!=1 

bys id: egen FAMtwinbindsfinal=max(twinbindsfinal)
bys id: egen FAMtwinbinds=max(twinbinds)

** Create treatment variables
*(1) treatment is twin born on final birth
gen T_Final=finaltwinfamily
gen T_FinalXtwin=T_Final*twind
gen pretwin=bord<twin_bord_fam if twinfam==1
replace pretwin=1 if twinfam==0
gen T_FinalXpretwin=T_Final*pretwin

*(2) treatment is twin born on final birth pushing family over desired number
gen T_Bind=FAMtwinbindsfinal if (fert==idealnumkids&FAMtwinbindsfinal==0)|/*
*/(fert==idealnumkids+1&FAMtwinbindsfinal==1)
gen T_BindXtwin=T_Bind*twind
gen T_BindXpretwin=T_Bind*pretwin

*(3) treatment is twin born after family's ideal number (control nontwin famili-
*es with births greater or equal to ideal)
gen twinafter=1 if twin_bord>=idealnumkids&twind==1
bys id: egen twinafterfamily=max(twinafter)
replace twinafterfamily=0 if idealfam==0&twinafterfamily==.
replace twinafterfamily=0 if idealfam==1&twinafterfamily==.
gen posttwinafter=1 if twinafterfamily==1&bord>twin_bord_fam&twind==0
replace posttwinafter=0 if twinafterfamily!=.&posttwinafter==. 
gen pretwinafter=1 if twinafterfamily==1&bord<twin_bord_fam&twind==0
replace pretwinafter=0 if twinafterfamily!=.&pretwinafter==. 
gen testtwinafter=1 if twinafterfamily==1&bord==twin_bord_fam
gen T_After=twinafterfamily
gen T_AfterXpretwin=T_After*pretwinafter
gen T_AfterXposttwin=T_After*posttwinafter

** Labels
lab var twind "Binary indicator for multiple birth"
lab var twin_birth "First born in twin birth (gives bord of twins)"
lab var id "Unique family identifier"
lab var poor1 "In lowest asset quintile"
lab var idealnumkids "Ideal number of children reported"
lab var lastbirth "Family's last birth (singleton or both twins)"
lab var twinfamily "At least one twin birth in family"
lab var wantedbirth "Birth occurs before optimal target"
lab var idealfam "Has family obtained ideal size? (negative implies < ideal)"
lab var twinexceed "Twin birth causes parents to exceed optimal size"
lab var singlexceed "Single birth causes parents to exceed optimal size"
lab var twintype "Twin isn't last bith/is last birth/is last birth and exceeds"
lab var singletype "Single isn't last bith/is last birth/is last birth+exceeds"
lab var quant_exceed "Difference between total births and desired births"
lab var exceeder "1 if child causes family to exceed optimal size"
lab var twinexceeder "1 if child is (2nd) twin and causes parents to exceed"
lab var T_Final "1 if twin born on last birth in family"
lab var T_Bind "1 if twin born last causes parents to exceed ideal family size"
lab var T_FinalXpretwin "Child born before twins in 'Final' treatment"
lab var T_BindXpretwin "Child born before twins in 'Bind' treatment"
lab var T_FinalXtwin "Twins in family in 'Final' treatment"
lab var T_BindXtwin "Twin in family in 'Bind' treatment"

lab def ideal -1 "< ideal number" 0 "Ideal number" 1 "> than ideal number"
lab val idealfam ideal
lab def birth 1 "Not last birth" 2 "Last birth" 3 "Last birth, exceeds ideal"
lab val twintype singletype birth

********************************************************************************
*** (3) Create country income levels and weight variables
********************************************************************************
do $PATH/Do/countrynaming

bys _cou _year: egen totalweight=sum(sweight)
gen cweight=(sweight/totalweight)*1000000

********************************************************************************
*** (4) Save data as working directory
********************************************************************************
save $PATH/Data/DHS_twins, replace
