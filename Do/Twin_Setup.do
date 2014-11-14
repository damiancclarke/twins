/* Twin_Setup 2.00               damiancclarke   	 		  yyyy-mm-dd:2012-03-22
*---|---------|---------|-----   soniabhalotra   -----|---------|---------|-----
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

This file generates data to use in the Twin Instrument paper.  It uses as input
the full set of publicly available DHS files up to October 2013.  To replicate
results exactly no DHS files released after 2013 should be included.  Full deta-
ils regarding creating this paper from source including downloading and merging
DHS, creating crude data and formatting tables can be found in the README file
located in this directory.

This file merges all DHS BR (birth recode) and PR (household member recode) fil-
es to generate an output file with one line per child.  Each child is linked to
their mother, and for those children who still live in the same household as th-
eir mother, their educational attainment is available.

The file can be controlled in section (0).  This defines the directory structure
where crude data is stored and where completed data should be saved. A database
called DHS_twins.dta will be generated.

For optimal viewing set tab width as 2 in text editor.

Questions should be directed to damian.clarke@economics.ox.ac.uk.


Major version highlights:
> 2012-03: Completed Thesis version
> 2013-01: Major changes based on presentations: Bristol, ESPE, NEUDC
> 2013-06: Change to incorporate desired tests
> 2014-05: Change to incorporate adjusted fertility
*/

clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000


********************************************************************************
*** (0) Globals and locals
********************************************************************************
global DATA   "~/database/DHS/XDHS_Data"
global SOURCE "~/investigacion/Activa/Twins/Do"
global LOG    "~/investigacion/Activa/Twins/Log"
global TEMP   "~/investigacion/Activa/Twins/Temp"
global OUT    "~/investigacion/Activa/Twins/Data"

cap mkdir $TEMP
log using "$LOG/Twins_Setup.txt", text replace

********************************************************************************
*** (1) Take necessary variables from BR (mother births) and PR (household me-
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
*** (2) Setup Variables which are used in TwinRegression
*** (2A) Generate sibling size subgroups (1+, 2+, 3+,...)  As per Angrist et al.
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
*** (2B) "Quality" variables
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

foreach n of numlist 3(1)6 {
    bys id: egen Qvariance`n'p=sd(school_zscore) if bord<`n'
}

********************************************************************************
*** (2C) Control variables
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
gen educf_level=v149 if v149<8
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
gen prenateEither=(prenate_doc==1|prenate_nurse==1)
bys _cou _year v001: egen prenateCluster=max(prenateEither)
bys _cou _year v101: egen prenateRegion=max(prenateEither)


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
*** (2D) Twin variables
********************************************************************************
bys id: egen twinfamily=max(twin)
bys id: egen twin_bord_fam=max(twin_bord)
bys id: egen nummultiple=max(twin)
gen finaltwin=(fert==bord)&twind==1
bys id: egen finaltwinfamily=max(finaltwin)
replace finaltwinfamily=0 if finaltwinfamily==.
gen twindfamily=twinfamily!=0

********************************************************************************
*** (2E) Fertility variables
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

**Correct fertility, birth order and twinning for children who died young
gen aliveafter1=childageatdeath>1
bys id: egen ADJfert=sum(aliveafter1)
bys id aliveafter1 (bord): gen ADJbord=_n
replace ADJbord=. if aliveafter1==0
gen twin_aliveafter1=childageatdeath>1&twin!=0
bys id age: egen at=sum(twin_aliveafter1)
gen ADJtwind=twind==1&at>1
bys id ADJtwind age (bord): gen ADJtwin=_n
replace ADJtwin=0 if ADJtwind==0

bys id: egen ADJtwinfamily=max(ADJtwin)
gen ADJtwin_bord=ADJbord-ADJtwin+1 if ADJtwin>0
bys id: egen ADJtwin_bord_fam=max(ADJtwin_bord)
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
drop aliveafter1 twin_aliveafter1 at

********************************************************************************
*** (2F) Desired Fertility variables
********************************************************************************
bys _cou v001: egen desiredfert_cluster=mean(idealnumkids)
bys _cou _year v001: egen desiredfert_clusterYEAR=mean(idealnumkids)
bys _cou v101: egen desiredfert_region=mean(idealnumkids)
bys _cou v131: egen desiredfert_ethnic=mean(idealnumkids)

local group1 _cou _year v101
local group2 _cou _year v001
local group3 _cou _year educf_level
local group4 _cou _year v101 educf_level
local names region clust educ regionEduc

tokenize `names'
foreach group in group1 group2 group3 group4 {
	bys ``group'': egen gtotal=sum(idealnumkids)
	bys ``group'': gen N=_N
	gen `1'DesiredLeaveOut=(gtotal-idealnumkids)/(N-1)
	drop gtotal N
	macro shift
}

********************************************************************************
*** (2G) Sex composition variables
********************************************************************************
foreach num of numlist 1(1)5 {
	gen sex`num'=sex if bord==`num'
	bys id: egen g`num'=min(sex`num')

	gen gend`num'="g" if g`num'==2
	replace gend`num'="b" if g`num'==1
	drop g`num' sex`num'
}
gen  mix1=gend1
egen mix2=concat(gend1 gend2)
egen mix3=concat(gend1 gend2 gend3)
egen mix4=concat(gend1 gend2 gend3 gend4)
egen mix5=concat(gend1 gend2 gend3 gend4 gend5)

gen boy1     = gend1=="b"
gen boy2     = gend2=="b"
gen boy3     = gend3=="b"
gen boy4     = gend4=="b"
gen boy12    = mix2=="bb"   if fert>1
gen girl12   = mix2=="gg"   if fert>1
gen boy123   = mix3=="bbb"  if fert>2
gen girl123  = mix3=="ggg"  if fert>2
gen boy1234  = mix4=="bbbb" if fert>3
gen girl1234 = mix4=="gggg" if fert>3
gen smix12   = mix2=="bb"  |mix2=="gg"   if fert>1
gen smix123  = mix3=="bbb" |mix3=="ggg"  if fert>2
gen smix1234 = mix4=="bbbb"|mix4=="gggg" if fert>3


********************************************************************************
*** (3) Labels
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
lab var Qvariance3p "Variance in quality of 1st and 2nd borns in the family"
lab var Qvariance4p "Variance in quality of 1st to 3rd borns in the family"
lab var Qvariance5p "Variance in quality of 1st to 4th borns in the family"
lab var Qvariance6p "Variance in quality of 1st to 5th borns in the family"
lab var gender "string variable: F or M"
lab var educf "Mother's years of education"
lab var educfyrs_sq "Mother's years of education squared"
lab var educf_0 "Mother has 0 years of education (binary)"
lab var educf_1_4 "Mother has 1-4 years of education (binary)"
lab var educf_5_6 "Mother has 5-6 years of education (binary)"
lab var educf_7_10 "Mother has 7-10 years of education (binary)"
lab var educf_11plus "Mother has 11+ years of education (binary)"
lab var educf_level "Mother's education level"
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
lab var prenateCluster "Prenatal care reported in cluster"
lab var prenateRegion "Prenatal care reported in region"
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
lab var twindfamily "Binary for twin birth in the family"
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
lab var regionDesiredLeaveOut "Average desired fertility at the region"
lab var clustDesiredLeaveOut "Average desired fertility at cluster leve"
lab var educDesiredLeaveOut "Average desired fertility by country/education level"
lab var regionEducDesiredLeaveOut "Average desired fertility by region/education"
lab var mix1     "Gender mix of first 1 births"
lab var mix2     "Gender mix of first 2 births"
lab var mix3     "Gender mix of first 3 births"
lab var mix4     "Gender mix of first 4 births"
lab var mix5     "Gender mix of first 5 births"
lab var boy1     "First born was a boy"
lab var boy2     "Second born was a boy"
lab var boy3     "Third born was a boy"
lab var boy4     "Fourth born was a boy"
lab var boy12    "First and second born were boys (at least 2 births)"
lab var girl12   "First and second born were girls (at least 2 births)"
lab var boy123   "First to third born were boys (at least 3 births)"
lab var girl123  "First to third born were girls (at least 3 births)"
lab var boy1234  "First to fourth born were boys (at least 4 births)"
lab var girl1234 "First to fourth born were girls (at least 4 births)"
lab var smix12   "1st and 2nd born were of the same gender (at least 2 births)"
lab var smix123  "1st to 3rd born were of the same gender (at least 3 births)"
lab var smix1234 "1st to 4th born were of the same gender (at least 4 births)"


lab def ideal -1 "< ideal number" 0 "Ideal number" 1 "> than ideal number"
lab val idealfam ideal

********************************************************************************
*** (4) Create country income levels and weight variables
********************************************************************************
do "$SOURCE/countrynaming.do"

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
*/ educf_7_10 educf_11plus educf_level educp educp_level twind twin twind100   /*
*/ malec height weightk bmi poor1 age agemay agesq magesq sweight country _cou /*
*/ twinfamily twin_bord twin_bord_fam nummultiple finaltwinfamily idealnumkids /*
*/ lastbirth wantedbirth idealfam quant_exceed exceeder twinexceeder _year     /*
*/ twinexceedfamily twin_undesired twin_desired twinexceed singlexceed         /*
*/ twinattain desiredfert_region desiredfert_ethnic inc_stat contracep_intent  /*
*/ _merge birthspacing m* childageatdeath child_alive antenatal antenateDummy  /*
*/ prenate_doc prenate_nurse prenate_none prenateCluster prenateRegion v001    /*
*/ WBcountry desiredfert_cluster* income motherage* antesq bmi_sq height_sq    /*
*/ underweight overweight ALL ADJfert ADJbord ADJtwin ADJtwinfamily            /*
*/ ADJtwin_bord ADJtwin_bord_fam ADJnummultiple ADJtwo_plus ADJthree_plus      /*
*/ ADJfour_plus ADJfive_plus ADJtwo_plus_twins ADJthree_plus_twins             /*
*/ ADJfour_plus_twins ADJfive_plus_twins ADJtwin_two_fam ADJtwin_three_fam     /*
*/ ADJtwin_four_fam ADJtwin_five_fam ADJtwind twindfamily *DesiredLeaveOut     /*
*/ mix1 mix2 mix3 mix4 mix5 boy1 boy2 boy3 boy4 girl12 girl123 girl1234 boy12  /*
*/ boy123 boy1234 smix12 smix123 smix1234 Qvariance3p Qvariance4p Qvariance5p  /*
*/ Qvariance6p

save "$OUT/DHS_twins", replace
log close
