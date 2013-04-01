/* TwinSetup 1.00                    UTF-8                         dh:2012-04-02
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 2000m

*******************************************************************************
****(1) Globals
*******************************************************************************
global Base "~/investigacion/Activa/Twins"
global Data "~/database/DHS"

log using $Base/Log/TwinSetup.log, text replace

*******************************************************************************
****(2) Check which DHS surveys coincide for education and child data
*******************************************************************************
use $Data/world_childsmall.dta
bys country yearint: gen num=_N
collapse yearint num, by(id2 country)
save $Data/world_childsmall1.dta,replace

*MUST CORRECT AS yearint IN CHILD DATA NOT ALWAYS THE SAME AS YEAR (CAN BE +/-1)
*NOTE: THIS ONLY CORRECTS FOR YEARS WHICH ALSO APPEAR IN EDUCATION SURVEY DATA
	do $Base/Do/countrynaming
	label var year "year of interview"
	drop yearint
	save $Data/Twins/DHSyears_childdata, replace

rm $Data/world_childsmall1.dta
use $Data/dhs_educBASE, clear
bys country year: gen num_educ=_N
collapse num_educ, by(country year)
save $Data/Twins/DHSyears_educdata, replace

merge m:m country year using $Data/Twins/DHSyears_childdata
*THIS GIVES 99 MATCHES (country-year surveys)
*ALL MATCHES OCCUR BETWEEN 1990-2005
keep if _merge==3
drop _merge
save $Data/Twins/MatchedSurveys, replace

*******************************************************************************
****(3) Keep educational data for countries with household data
*******************************************************************************
use $Data/dhs_educBASE
merge m:m country year using $Data/Twins/MatchedSurveys
keep if _merge==3
drop _merge
*drop if relationship==1|relationship==2|relationship==6

*******************************************************************************
****(4) Adjust household id for consistency
*This is to create an identical hh variable in both datasets.  The education
*data includes an id with one extra number at the end.
*******************************************************************************
split hhid, destring
gen hhii=1 if hhid5==. & hhid4==.  & hhid3==.  & hhid2==. & hhid1!=.
replace hhii=2 if hhid5==. & hhid4==.  & hhid3==.  & hhid2!=. & hhid1!=.
replace hhii=3 if hhid5==. & hhid4==.  & hhid3!=.  & hhid2!=. & hhid1!=.
replace hhii=4 if hhid5==. & hhid4!=.  & hhid3!=.  & hhid2!=. & hhid1!=.
replace hhii=5 if hhid5!=. & hhid4!=.  & hhid3!=.  & hhid2!=. & hhid1!=.
drop hhid1-hhid5
split hhid
gen space=" "
gen hhid_m=hhid1 if hhii==1
egen hh=concat(hhid1 space hhid2) if hhii==2
replace hhid_m=hh if hhii==2
drop hh
egen hh=concat(hhid1 space hhid2 space hhid3) if hhii==3
replace hhid_m=hh if hhii==3
drop hh
egen hh=concat(hhid1 space hhid2 space hhid3 space hhid4) if hhii==4
replace hhid_m=hh if hhii==4
drop hh
egen hh=concat(hhid1 space hhid2 space hhid3 space hhid4 space hhid5) if hhii==5
replace hhid_m=hh if hhii==5
drop hh hhii hhid1-hhid5 space
save $Data/Twins/dhs_educBASEavail, replace

use $Data/world_child
do $Base/Do/countrynaming
*NOTE, NEPAL SURVEY np2 HAS NO CHILD BIRTHYEAR INFO.  CAN BE CALCULATED FROM AGE
*AND SURVEY DATE:
	replace yearc=yearint-agec+v006/12-monthc/12 if id2=="np2"
	replace yearc=floor(yearc) if id2=="np2"
*NOTE: bidx (used for caseid3 is calculated as follows):
*gsort caseid2 -dobc -twinc
*by caseid2: gen bidx3=_n
gen twind=1 if twinc>0  //twind is actually multiple birth
replace twind=0 if twinc==0

rename yearint year
label var year "year of interview"
merge m:m country year using $Data/Twins/MatchedSurveys
keep if _merge==3
drop _merge


*******************************************************************************
****(5) Merge education and child datasets (this requires hhid as above)
*******************************************************************************
*IN ORDER TO MERGE IT WILL BE NECESSARY TO CALCULATE EACH OBSERVATION'S RELATION
*TO HH HEAD.  AS THIS IS NOT AVAILABLE, THIS WILL BE CALCULATED INDIRECTLY. 
*WE HAVE THE CHILD'S MOTHER'S RELATION TO HH HEAD, THIS ALLOWS ME TO CALCULATE
*CHILD RELATION (NECESSARY TO MERGE WITH EDUC DATASET)
gen relationship=3 if v150==1|v150==2|v150==9
replace relationship=5 if v150==3|v150==4|v150==11
replace relationship=8 if v150==6|v150==7
replace relationship=10 if v150==8|v150==8|v150==12
gen sex=1 if malec==1
replace sex=2 if malec==0
rename agec age

*hhid:
gen hhi=caseid
split hhi, destring
gen hhii=1 if hhi6==. & hhi5==. & hhi4==.  & hhi3==.  & hhi2==. & hhi1!=.
replace hhii=2 if hhi6==. & hhi5==. & hhi4==.  & hhi3==.  & hhi2!=. & hhi1!=.
replace hhii=3 if hhi6==. & hhi5==. & hhi4==.  & hhi3!=.  & hhi2!=. & hhi1!=.
replace hhii=4 if hhi6==. & hhi5==. & hhi4!=.  & hhi3!=.  & hhi2!=. & hhi1!=.
replace hhii=5 if hhi6==. & hhi5!=. & hhi4!=.  & hhi3!=.  & hhi2!=. & hhi1!=.
replace hhii=6 if hhi6!=. & hhi5!=. & hhi4!=.  & hhi3!=.  & hhi2!=. & hhi1!=.

drop hhi1-hhi6
split hhi
gen space=" "
gen hhid_m=hhi1 if hhii==1|hhii==2
egen hh=concat(hhi1 space hhi2) if hhii==3
replace hhid_m=hh if hhii==3
drop hh
egen hh=concat(hhi1 space hhi2 space hhi3) if hhii==4
replace hhid_m=hh if hhii==4
drop hh
egen hh=concat(hhi1 space hhi2 space hhi3 space hhi4) if hhii==5
replace hhid_m=hh if hhii==5
drop hh
egen hh=concat(hhi1 space hhi2 space hhi3 space hhi4 space hhi5) if hhii==6
replace hhid_m=hh if hhii==6
drop hh hhii hhi1-hhi5 space

bys caseid2: gen kidcount2=_N
scatter kidcount2 fert
save $Data/Twins/world_childavail, replace

merge m:m country year hhid_m relationship sex age using $Data/Twins/dhs_educBASEavail
save $Data/Twins/DHS_MergedBase, replace

*PROBLEM: many don't merge.  Twins of course merge doubly.
* 1,698,362 matched, 1,299,051 not matched.
use $Data/Twins/DHS_MergedBase, clear

keep if _merge==3
keep caseid caseid2 caseid3 id2 bidx country continent ssa bord twinc monthc /*
*/ yearc dobc malec age b11 b12 m1b m5 m15 m18 m19 hw2 hw3 m1a m2 m3 m34 v001/*
*/ v002 v003 sweight v006 /*yearint*/ year v009 yearm dobm agem v013 v020 v024 v025 /*
*/v026 v106 v107 v113 v115 v116 educfyrs v136 v137 educf v150 v151 v152 fert /*
*/v208 v209 v211 v213 v301 v302 v312 v320 v426 v437 height bmi anemia v501 /*
*/v504 agefirstma v602 v701 v702 v108 v751 v325 v118 cont_name educf1- educf6/*
*/ educm1- educm6 mort15 under5_exp wealth wealthq wealthwq poor1 rich1 poor2/*
*/ rich2 poor3 rich3 ht_miss bmi_normal bmi_low bmi_high bmi1 educfyrs2 /*
*/relationship sex hv005 hhid hv007 urban edulevel eduyears eduattainment v228 /*
*/enrolment aiquin p_attendence s_attendence birth_y cohort twind ncode agemay /*
*/ v206 v207 v212

rename v228 terminated_preg

save $Data/Twins/DHS_Base, replace
*cap rm $Data/Twins/DHS_MergedBase
cap rm $Data/Twins/MatchedSurveys
cap rm $Data/Twins/DHSyears_childdata
cap rm $Data/Twins/DHSyears_educdata



*******************************************************************************
****(6) Variable creation
*******************************************************************************
use $Data/Twins/DHS_Base, clear
tab country, gen(country)

*The creation of Q-Q subgroups is quite inefficient, but for now I will keep
*it as is since I can't be bothered to change it, plus it is understandable.
*QUALITY-QUANTITY (1+)
gen one_plus=1 if bord==1 & fert>=2
replace one_plus=0 if bord>1|fert==1
replace one_plus=0 if twinc!=0
gen twin2=1 if twinc==1 & bord==2
replace twin2=0 if twin2!=1
bys caseid2: egen twin2fam=max(twin2)

*QUALITY-QUANTITY (2+)
gen two_plus=1 if bord==1 & fert>=3
replace two_plus=1 if bord==2 & fert>=3
replace two_plus=0 if two_plus!=1
replace two_plus=0 if twinc!=0
gen twin3=1 if twinc==1 & bord==3
replace twin3=0 if twin3!=1
bys caseid2: egen twin3fam=max(twin3) 

*QUALITY-QUANTITY (3+)
gen three_plus=1 if bord==1 & fert>=4
replace three_plus=1 if bord==2 & fert>=4
replace three_plus=1 if bord==3 & fert>=4
replace three_plus=0 if three_plus!=1
replace three_plus=0 if twinc!=0
gen twin4=1 if twinc==1 & bord==4
replace twin4=0 if twin4!=1
bys caseid2: egen twin4fam=max(twin4) 

*QUALITY-QUANTITY (4+)
gen four_plus=1 if bord==1 & fert>=5
replace four_plus=1 if bord==2 & fert>=5
replace four_plus=1 if bord==3 & fert>=5
replace four_plus=1 if bord==4 & fert>=5
replace four_plus=0 if four_plus!=1
replace four_plus=0 if twinc!=0
gen twin5=1 if twinc==1 & bord==5
replace twin5=0 if twin5!=1
bys caseid2: egen twin5fam=max(twin5) 

*QUALITY-QUANTITY (5+)
gen five_plus=1 if bord==1 & fert>=6
replace five_plus=1 if bord==2 & fert>=6
replace five_plus=1 if bord==3 & fert>=6
replace five_plus=1 if bord==4 & fert>=6
replace five_plus=1 if bord==5 & fert>=6
replace five_plus=0 if five_plus!=1
replace five_plus=0 if twinc!=0
gen twin6=1 if twinc==1 & bord==6
replace twin6=0 if twin6!=1
bys caseid2: egen twin6fam=max(twin6) 

*QUALITY-QUANTITY (6+)
gen six_plus=1 if bord==1 & fert>=7
replace six_plus=1 if bord==2 & fert>=7
replace six_plus=1 if bord==3 & fert>=7
replace six_plus=1 if bord==4 & fert>=7
replace six_plus=1 if bord==5 & fert>=7
replace six_plus=1 if bord==6 & fert>=7
replace six_plus=0 if six_plus!=1
replace six_plus=0 if twinc!=0
gen twin7=1 if twinc==1 & bord==7
replace twin7=0 if twin7!=1
bys caseid2: egen twin7fam=max(twin7) 

gen attendance=0 if enrolment==0
replace attenda=1 if enrolment==2
replace attenda=2 if enrolment==1
*GAP
gen gap=age-eduyears-6 if age>6 & age<17
replace gap=. if gap<-2

tab v701, gen(educmale)
drop educfyrs2
tab educfyrs, gen(educfyrs)
tab age, gen(age)
tab yearc, gen(yearc)
tab bord, gen(borddummy)

rename twin2fam twin_one_fam
rename twin3fam twin_two_fam
rename twin4fam twin_three_fam
rename twin5fam twin_four_fam
rename twin6fam twin_five_fam
rename twin7fam twin_six_fam

gen educfyrs_sq=educfyrs*educfyrs

gen educf_0=educfyrs==0
gen educf_1_4=educfyrs>0&educfyrs<5
gen educf_5_6=educfyrs>4&educfyrs<7
gen educf_7_10=educfyrs>6&educfyrs<11
gen educf_11plus=educfyrs>10

gen twind100=twind*100

tab cont_name, gen(cont_name)

*GENERATE STANDARD YEARS OF SCHOOLING
foreach country of varlist country1-country46 {
	foreach num of numlist 6(1)39 {
		egen school_zscore_`num'=std(eduyears) if age==`num' & `country'==1
	}
	egen school_zscore_`country'=rowtotal(school_zscore_6-school_zscore_39)
	drop school_zscore_6-school_zscore_39
}
egen school_zscore=rowtotal(school_zscore_country1-school_zscore_country46)
drop school_zscore_countr*

do $Base/Do/countrynaming
save $Data/Twins/DHS_Base, replace


*******************************************************************************
****(7) Maternal Data for terminated pregnancies
*******************************************************************************
use $Data/Twins/DHS_MergedBase, clear
