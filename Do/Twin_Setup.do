* Twin_Setup 2.00                damiancclarke   	 		  yyyy-mm-dd:2012-03-22
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
/* This is has been a pretty major refactorisation of the previous twin setup
file.  To rollback to the previous one, return to the git commit made on Nov 11
2013.  Here we are redefining to only look at reduced form and IV with treament
as described in Black et al, Angrist et al, and also to interact with desired
family size.  Our principal specification for desired is:

quality_{ij}=\beta_0+\beta_1*fert_{j}+\beta_2*fert*desired_{j}+X'\beta+u_{ij}

Major version highlights:
> 2012-03: Completed Thesis version
> 2013-01: Major changes based on presentations: Bristol, ESPE, NEUDC
> 2013-06: Change outlined about to incorporate desired tests

*/

clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000


********************************************************************************
*** (1) Globals and locals
********************************************************************************
global PATH "~/investigacion/Activa/Twins"
global DATA "~/database/DHS/XDHS_Data"
global LOG "$PATH/Log"
global TEMP "$PATH/Temp"

cap mkdir $PATH/Temp

log using "$LOG/Twins_Setup.txt", text replace
********************************************************************************
*** (2) Take necessary variables from BR (mother births) and PR (household me-
*** mber) The BR dataset has the majority of family and maternal characterist-
*** ics used in the regressions, however there is no child education variables
*** in this dataset.  The child education information comes from PR.
********************************************************************************
***Do in parts as merge of full dataset is impossible with 8gb of RAM
foreach num of numlist 1(1)7 {
	use $DATA/World_BR_p`num', clear

	keep _cou _year caseid v000-v026 v101 v106 v107 v130 v131 v133 v136 v137 /*
 	*/ v149 v150 v151 v152 v190 v191 v201 v202 v203 v204 v205 v206 v207 v208 /*
	*/ v209 v211 v212 v213 v228 v229 v230 v437 v438 v445 v457 v463a v481 v501/*
	*/ v504 v602 v605 v715 v701 v730 bord b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11/*
	*/ b12 b13 b14 b15 b16 v613 v614 m19 m19a v367 v312 v364 m4 m5 m8 m9 m10 /*
	*/ m12 m14 m15 m16 m17 m18 m19 m19a m2a m2b m2n bidx
	
	cap rename v010 year_birth
	cap rename v012 agemay
	cap rename v106 educlevel_f
	cap rename v130 religion
	cap rename v133 educf
	cap rename v137 kids_under5
	cap rename v140 rural
	cap rename v190 wealth
	cap rename v201 fert
	cap rename v212 agefirstbirth
	cap rename v228 terminated_preg
	cap rename v437 weightk
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
	cap rename b11 birthspacing
	cap rename v715 educp
	cap rename v701 educp_level
	cap rename m14 antenatal
	cap rename m2a prenate_doc
	cap rename m2b prenate_nurse
	cap rename m2n prenate_none
	
	replace age=floor(v007-child_yob+(v006-b1/12)) if age==.

	cap drop if _cou=="Cameroon" & _year=="1991"
	* no v002 recorded.  This could be saved by a split of caseid if desired...
	
	**The following lines correct for the fact that we only observe each births'
	**mothers' relationship to the household head.  In this way, if the mother 
	**is the wife, the birth must be the child of the household head.
	gen relationship=3 if v150==1|v150==2|v150==9
	replace relationship=5 if v150==3|v150==4|v150==11
	replace relationship=8 if v150==6|v150==7
	replace relationship=10 if v150==8|v150==10|v150==12|v150==5

	egen id=concat(_cou _year v001 v002)
	bys id relationship age sex (bidx): gen counter=_n
	bys id relationship age sex counter: gen tester=_N

	sum tester
	if r(max)!=1 {
		tab _cou if tester!=1
		dis as err "Merging error. Check that country id (v001, v002) is correct"
		exit 2727
	}
	drop tester
	
	save $TEMP/BR`num', replace
}


foreach num of numlist 1(1)7 {
	use $DATA/World_PR_p`num', clear

	keep _cou _year hhid hvidx hv000-hv003 hv101 hv104 hv105 hv106 hv121 hv122/*
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
	rename hv003 v003
	egen id=concat(_cou _year v001 v002)

	bys id relationship age sex (hvidx): gen counter=_n
	bys id relationship age sex counter: gen tester=_N

	sum tester
	if r(max)!=1 {
		tab _cou if tester!=1
		dis as err "Merging error. Check that country id (v001, v002) is correct"
		exit 2727
	}
	drop tester
	save $TEMP/PR`num', replace
}

***Merge PR and BR (still in parts)
foreach num of numlist 1(1)7 {
	use $TEMP/PR`num'
	merge 1:1 id relationship age sex counter using $TEMP/BR`num'
	keep if _merge==3|_merge==2 //updated Apr 24, 2013
	save $TEMP/c`num', replace
	clear
	rm "$TEMP/PR`num'.dta"
	rm "$TEMP/BR`num'.dta"
}


use $TEMP/c1
append using $TEMP/c2 $TEMP/c3 $TEMP/c4 $TEMP/c5 $TEMP/c6 $TEMP/c7

foreach num of numlist 1(1)7 {
	rm $TEMP/c`num'.dta
}
rmdir $TEMP

replace _cou="CAR" if hv000=="CF3" &_cou==""
replace _cou="Zimbabwe" if hv000=="ZW6" &_cou==""
replace _year="2004" if hv000=="CF3" &_year==""
replace _year="2010" if hv000=="ZW6" &_year==""

***Year of birth for Nepal (convert from Vikram Samvat to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+2000 if _cou=="Nepal" & `year'<100
	replace `year'=`year'-57 if _cou=="Nepal"
}
***Year of birth for Ethiopia (convert from Ge'ez to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+8 if _cou=="Ethiopia"
}

replace child_yob=child_yob+1900 if child_yob<100&child_yob>2
replace child_yob=child_yob+2000 if child_yob<=2
replace year_birth=year_birth+1900 if year_birth<100
replace age=age+100 if age<0

********************************************************************************
*** (3) Setup Variables which are used in TwinRegression
*** (3A) Generate sibling size subgroups (1+, 2+, 3+,...)  As per Angrist et al.
********************************************************************************
gen mid="a"
drop id
egen id=concat(_cou mid _year mid v001 mid v002 mid v150 mid caseid)
drop mid

local max 1
local fert 2

gen twin_bord=bord-twin+1 if twin>0

foreach num in two three four five {
	gen `num'_plus=(bord>=1&bord<=`max')&fert>=`fert'
	gen `num'_plus_twins=((bord>=1&bord<=`fert')&fert>=`fert')|twin_bord==`fert'
	replace `num'_plus=0 if twin!=0
	gen twin`num'=(twin==1 & bord==`fert')|(twin==2 & bord==`fert'+1)
	bys id: egen twin_`num'_fam=max(twin`num')
	drop twin`num'
	local ++max
	local ++fert
}


********************************************************************************
*** (3B) "Quality" variables
********************************************************************************
*** Attendance (attend_year==2 is sometimes)
gen attendance=0 if attend_year==0
replace attendance=1 if attend_year==2
replace attendance=2 if attend_year==1
replace attendance=. if age<6

*** Z-Score
replace educ=. if educ>25 // come back here when compiling summary stats.
bys _cou age: egen sd_educ=sd(educ)
bys _cou age: egen mean_educ=mean(educ)
gen school_zscore=(educ-mean_educ)/sd_educ
replace school_zscore=. if age<6

*** Highschool
gen highschool=1 if (educlevel==2|educlevel==3)&age>=11
replace highschool=0 if (educlevel==0|educlevel==1)&age>=11

*** No Educ
gen noeduc=1 if educlevel==0&age>6
replace noeduc=0 if (educlevel==1|educlevel==2|educlevel==3)&age>6

*** Health
gen childsurvive=child_alive
gen childageatdeath=b7/12
gen infantmortality=childageatdeath<=1
replace infantmortality=. if age<1
gen childmortality=childageatdeath<=5
replace childmortality=. if age<5

********************************************************************************
*** (3C) Control variables
********************************************************************************
gen ALL=1
gen gender="F" if sex==2
replace gender="M" if sex==1

gen educfyrs_sq=educf*educf
gen educf_0=educf==0
gen educf_1_4=educf>0&educf<5
gen educf_5_6=educf>4&educf<7
gen educf_7_10=educf>6&educf<11
gen educf_11plus=educf>10
gen twind=1 if twin>=1&twin!=.
replace twind=0 if twin==0
gen twind100=twin*100
gen malec=(gender=="M")

replace educp=. if educp>25

replace height=height/10
replace weight=weight/10
replace bmi=bmi/100
replace antenatal=. if antenatal>20
gen antenateDummy=antenatal!=0 if antenatal!=.
foreach var of varlist prenate_doc prenate_nurse prenate_none {
	replace `var'=. if `var'==9
}

gen poor1=wealth==1
gen agesq=age*age
gen magesq=agemay*agemay

gen motherage   = agemay - age
gen motheragesq = motherage^2 
gen motheragecub= motherage^3
gen antesq = antenatal^2

gen bmi_sq    = bmi*bmi
gen height_sq = height*height

gen underweight=bmi<=18.5 if bmi!=.
gen overweight =bmi>25 if bmi!=.

*** General variables (country year)
rename _cou country
rename v005 sweight
encode country, gen(_cou)

********************************************************************************
*** (3D) Twin variables
********************************************************************************
bys id: egen twinfamily=max(twin)
bys id: egen twin_bord_fam=max(twin_bord)
bys id: egen nummultiple=max(twin)
gen finaltwin=(fert==bord)&twind==1
bys id: egen finaltwinfamily=max(finaltwin)
replace finaltwinfamily=0 if finaltwinfamily==.


********************************************************************************
*** (3E) Fertility variables
********************************************************************************
gen idealnumkids=v613 if v613<25
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
gen twinexceeder=exceeder==1&(twin==2|twin==3|twin==4)
bys id: egen twinexceedfamily=max(twinexceeder)
gen tu=twin_bord>=idealnumkids
gen td=twin_bord>=idealnumkids
bys id: egen twin_undesired=max(tu)
bys id: egen twin_desired=max(td)
drop td tu

*Twins born on final birth causing parents to exceed desired family size
gen twinexceed=finaltwinfamily==1&idealfam==1
gen singlexceed=finaltwinfamily==0&idealfam==1
gen twinattain=finaltwinfamily==1&idealfam==0

**Generate sub-region (and ethnicity) specific desired fertility
bys _cou v001: egen desiredfert_cluster=mean(idealnumkids)
bys _cou _year v001: egen desiredfert_clusterYEAR=mean(idealnumkids)
bys _cou v101: egen desiredfert_region=mean(idealnumkids)
bys _cou v131: egen desiredfert_ethnic=mean(idealnumkids)

**Correct fertility, birth order and twinning for children who died young
gen aliveafter3=childageatdeath>3
bys id: egen ADJfert=sum(aliveafter3)
bys id aliveafter3 (bord): gen ADJbord=_n
replace ADJbord=. if aliveafter3==0
gen twin_aliveafter3=childageatdeath>3&twin!=0
bys id age: egen at=sum(twin_aliveafter3)
gen ADJtwind=twind==1&at>1
bys id ADJtwind age (bord): gen ADJtwin=_n
replace ADJtwin=0 if ADJtwind==0

bys id: egen ADJtwinfamily=max(ADJtwin)
gen ADJtwin_bord=ADJbord-ADJtwin+1 if ADJtwin>0
bys id: egen ADJtwin_bord_fam=max(ADJ_twinbord)
bys id: egen ADJnummultiple=max(ADJtwin)

local max 1
local fert 2

foreach num in two three four five {
	gen ADJ`num'_plus=(ADJbord>=1&ADJbord<=`max')&ADJfert>=`fert'
	gen ADJ`num'_plus_twins=((ADJbord>=1&ADJbord<=`fert')&ADJfert>=`fert')|ADJtwin_bord==`fert'
	replace ADJ`num'_plus=0 if ADJtwin!=0
	gen ADJtwin`num'=(ADJtwin==1 & ADJbord==`fert')|(ADJtwin==2 & ADJbord==`fert'+1)
	bys id: egen ADJtwin_`num'_fam=max(ADJtwin`num')
	drop ADJtwin`num'
	local ++max
	local ++fert
}
drop aliveafter3 twin_aliveafter3 at

********************************************************************************
*** (4) Labels
********************************************************************************
lab var year_birth "Mother's year of birth"
lab var religion "Reported religion"
lab var fert "Total number of children in the family"
lab var bord "Child's birth order"
lab var agefirstbirth "Mother's age at first birth"
lab var child_yob "Child's year of birth"
lab var two_plus "First born child in families with at least two births"
lab var three_plus "1,2 born children in families with at least 3 births"
lab var four_plus "1,2,3 born children in families with at least 4 births"
lab var five_plus "1,2,3,4 born children in families with at least 5 births"
lab var two_plus_twins "1,2 born children in families with >=2 births"
lab var three_plus_twins "1,2,3 born children in families with >=3 births"
lab var four_plus_twins "1,2,3,4 born children in families with >=4 births"
lab var five_plus_twins "1-5 born children in families with >=5 births"
lab var twin_two_fam "Twin birth at second birth"
lab var twin_three_fam "twin birth at third birth"
lab var twin_four_fam "twin birth at fourth birth"
lab var twin_five_fam "twin birth at fifth birth"
lab var id "Unique family identifier"
lab var attendance "child attends school (1=sometimes, 2=always)"
lab var educ "Years of education (child)"
lab var school_zscore "Standardised educ attainment compared to country cohort"
lab var highschool "Attends or attended highschool (>=12 years)"
lab var noeduc "No education (>7 years)"
lab var infantmortality "child died before 1 year of age"
lab var childmortality "child died before 5 years of age"
lab var gender "string variable: F or M"
lab var educf "Mother's years of education"
lab var educfyrs_sq "Mother's years of education squared"
lab var educf_0 "Mother has 0 years of education (binary)"
lab var educf_1_4 "Mother has 1-4 years of education (binary)"
lab var educf_5_6 "Mother has 5-6 years of education (binary)"
lab var educf_7_10 "Mother has 7-10 years of education (binary)"
lab var educf_11plus "Mother has 11+ years of education (binary)"
lab var educp "Partner's years of education"
lab var educp_level "Partner's education level"
lab var twind "Child is a twin (binary)"
lab var twin "Child is a twin (0-4) for no, twin, triplet, ... "
lab var twind100 "Child is twin (binary*100)"
lab var malec "Child is a boy"
lab var height "height in centimetres"
lab var height_sq "mother's height in centimetres squared"
lab var weightk "Weight in kilograms"
lab var bmi "Body Mass Index (weight in kilos squared/height in cm)"
lab var bmi_sq "Body Mass Index squared (weight in kilos squared/height in cm)"
lab var underweight "Mother's BMI is less than or equal to 18.5"
lab var overweight "Mother's BMI is greater than 25"
lab var antenatal "Number of antenatal check-ups for mother"
lab var antenateDummy "Antenatal checkup (binary)"
lab var prenate_doc "Prenatal care by doctor"
lab var prenate_nurse "Prenatal care by nurse"
lab var prenate_none "No prenatal care"
lab var poor1 "In lowest asset quintile"
lab var age "Child's age in years"
lab var agemay "Mother's age in years"
lab var agesq "Child's age squared"
lab var magesq "Mother's age squared"
lab var motherage "Mother's age at date of birth of child"
lab var motheragesq "Mother's age at date of birth of child squared"
lab var motheragecub "Mother's age at date of birth of child cubed"
lab var sweight "Sample weight (from DHS)"
lab var country "Coutry name"
lab var _cou "country (numeric code)"
lab var twinfamily "At least one twin birth in family"
lab var twin_bord "Birth order when twins occur (for twins only)"
lab var twin_bord_fam "Birth order when twins occur (for whole family)"
lab var nummultiple "0 if singleton family, 1 if twins, 2 if triplets, ..."
lab var finaltwinfamily "The family had twins at their final birth"
lab var idealnumkids "Ideal number of children reported (truncate at 25)"
lab var lastbirth "Child is family's last birth (singleton or both twins)"
lab var wantedbirth "Birth occurs before optimal target"
lab var idealfam "Has family obtained ideal size? (negative implies < ideal)"
lab var quant_exceed "Difference between total births and desired births"
lab var exceeder "1 if child causes family to exceed optimal size"
lab var twinexceeder "Twin birth causes parents to exceed optimal size"
lab var twinexceedfamily "Family exceeds desired N and twin caused exceed"
lab var twin_undesired "Family has had twins, and twins were >desired births"
lab var twin_desired "Family has had twins, and twins were <=desired births"
lab var twinexceed "Twin birth causes parents to exceed optimal size"
lab var singlexceed "Single birth causes parents to exceed optimal size"
lab var twinattain "Twin birth causes parents to attain optimal size"
lab var desiredfert_cluster "Average desired family size by DHS cluster"
lab var desiredfert_region "Average desired family size by (subcountry) region"
lab var desiredfert_ethnic "Average desired family size by ethnicity"
lab var birthspacing "Time between child and previous birth (in months)"
lab var wealth "Wealth quartile based on observed assets"
lab var childageatdeath "Age of child (years) at death"
lab var ADJfert "Total fertility adjusted for children surviving beyond 3"
lab var ADJbord "Birth order of child adjusted for children surviving beyond 3"
lab var ADJtwin "Child is a twin adjusted for survival (0-4) for no, twin, triplet"
lab var ADJtwind "Adjusted twin indicator (takes 1 if both twins survive)"
lab var ADJtwinfamily "At least one twin birth in family where both twins survive"
lab var ADJtwin_bord "Birth order when adjusted twins occur (for twins only)"
lab var ADJtwin_bord_fam "Birth order when adjusted twins occur (for whole family)"
lab var ADJnummultiple "0 if singleton family, 1 if twins, 2 if triplets, ..."
lab var ADJtwo_plus "Adjusted first born child in families with at least two births"
lab var ADJthree_plus "Adjusted 1,2 born children in families with at least 3 births"
lab var ADJfour_plus "Adjusted 1,2,3 born children in families with at least 4 births"
lab var ADJfive_plus "Adjusted 1-4 born children in families with at least 5 births"
lab var ADJtwo_plus_twins "Adjusted 1,2 born children in families with >=2 births"
lab var ADJthree_plus_twins "Adjusted 1-3 born children in families with >=3 births"
lab var ADJfour_plus_twins "Adjusted 1-4 born children in families with >=4 births"
lab var ADJfive_plus_twins "Adjusted 1-5 born children in families with >=5 births"
lab var ADJtwin_two_fam "Adjusted twin birth at second birth"
lab var ADJtwin_three_fam "Adjusted twin birth at third birth"
lab var ADJtwin_four_fam "Adjusted twin birth at fourth birth"
lab var ADJtwin_five_fam "Adjusted twin birth at fifth birth"

lab def ideal -1 "< ideal number" 0 "Ideal number" 1 "> than ideal number"
lab val idealfam ideal

********************************************************************************
*** (5) Create country income levels and weight variables
********************************************************************************
do $PATH/Do/countrynaming

gen income="low" if inc_status=="L"
replace income="mid" if inc_status!="L"

********************************************************************************
*** (6) Keep required variables.  Save data as working file.
********************************************************************************
keep year_birth religion fert bord agefirstbirth child_yob two_plus three_plus /*
*/ four_plus five_plus two_plus_twins three_plus_twins four_plus_twins         /*
*/ five_plus_twins twin_two_fam twin_three_fam twin_four_fam twin_five_fam id  /*
*/ attendance educ school_zscore highschool noeduc infantmortality wealth      /* 
*/ childmortality gender educf educfyrs_sq educf_0 educf_1_4 educf_5_6         /*
*/ educf_7_10 educf_11plus educp educp_level twind twin twind100 malec height  /*
*/ weightk bmi poor1 age agemay agesq magesq sweight country _cou _year        /*
*/ twinfamily twin_bord twin_bord_fam nummultiple finaltwinfamily idealnumkids /*
*/ lastbirth wantedbirth idealfam quant_exceed exceeder twinexceeder           /*
*/ twinexceedfamily twin_undesired twin_desired twinexceed singlexceed         /*
*/ twinattain desiredfert_region desiredfert_ethnic inc_stat contracep_intent  /*
*/ _merge birthspacing m* childageatdeath child_alive antenatal antenateDummy  /*
*/ prenate_doc prenate_nurse prenate_none WBcountry v001 desiredfert_cluster*  /*
*/ income motherage* antesq bmi_sq height_sq underweigh overweight ALL ADJfert /*
*/ ADJbord ADJtwin ADJtwinfamily ADJtwin_bord ADJtwin_bord_fam ADJnummultiple  /*
*/ ADJtwo_plus ADJthree_plus ADJfour_plus ADJfive_plus ADJtwo_plus_twins       /*
*/ ADJthree_plus_twins ADJfour_plus_twins ADJfive_plus_twins ADJtwin_two_fam   /*
*/ ADJtwin_three_fam ADJtwin_four_fam ADJtwin_five_fam ADJtwind

save "$PATH/Data/DHS_twins", replace
log close
