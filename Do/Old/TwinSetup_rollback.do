* DHS_Twins 1.00                  dh:2012-07-25                 Damian C. Clarke
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000

*GLOBALS FOR COMPUTER AND DATA
if c(username)=="damian" {
        global PATH "/media/DCC/MMR"
        global COMPUTER "Damian"
}
else if c(os)=="Unix" {
        global PATH "~/investigacion/Activa/Twins"
        global COMPUTER "damiancclarke@dcc-linux"
}

global DATA "~/database/DHS/DHS_Data"
global DO "$PATH/Do"
global LOG "$PATH/Log"
global RESULTS "$PATH/Results"
global TEMP "$PATH/Temp"

cap mkdir $PATH/Temp

log using "$LOG/Twins_DHS.txt", text replace

******************************************************************************
*** (1) Take necessary variables from BR (mother births) and PR (household me-
*** mber) The IR dataset has the majority of family and maternal characterist-
*** ics used in the regressions, however there is no child education variables
*** in this dataset.  The child education information comes from PR.
******************************************************************************
cd $DATA

***Do in parts as merge of full dataset is impossible with 8gb of RAM
foreach num of numlist 1(1)7 {
        use World_BR_p`num', clear

        keep _cou _year caseid v000-v026 v101 v106 v107 v130 v131 v133 v136 v137 /*
        */ v149 v150 v151 v152 v190 v191 v201 v202 v203 v204 v205 v206 v207 v208 /*
        */ v209 v211 v212 v213 v228 v229 v230 v437 v438 v445 v457 v463a v481 v501/*
        */ v504 v602 v605 v715 v701 v730 bord b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 /*
        */ b12 b13 b14 b15 b16 v613 v614 m19 m19a v367
        
        cap rename v010 year_birth
        cap rename v012 agemay
        cap rename v106 educlevel_f
        cap rename v130 religion
        cap rename v133 educf
        cap rename v137 kids_under5
        cap rename v140 rural
*       cap rename v150 relation_hhh
        cap rename v190 wealth
        cap rename v201 fert
        cap rename v212 agefirstbirth
        cap rename v228 terminated_preg
        cap rename v437 weight
        cap rename v438 height
        cap rename v445 bmi
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
        use World_PR_p`num', clear

        keep _cou _year hhid hvidx hv000-hv002 hv101 hv104 hv105 hv106 hv121 hv122 /*
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
        keep if _merge==3
        save $TEMP/twins`num', replace
}

// Remove partial PR/BR datasets
foreach t in PR BR {
        foreach file in `t'1.dta `t'2.dta `t'3.dta `t'4.dta `t'5.dta `t'6.dta `t'7.dta {
                rm $TEMP/`file'
        }
}

use $TEMP/twins1
append using $TEMP/twins2 $TEMP/twins3 $TEMP/twins4 $TEMP/twins5 $TEMP/twins6 $TEMP/twins7

foreach num of numlist 1(1)7 {
        rm $TEMP/twins`num'.dta
}
rmdir $TEMP
save $PATH/Data/DHS_twins_rollback, replace

******************************************************************************
*** (2) Setup Variables which are used in TwinRegression
******************************************************************************
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

        *** Schooling gap
gen gap=age-educ-6 if age>6 & age<17
replace gap=. if gap<-2


replace educ=. if educ>25
        *** Z-Score
tab _cou, gen(country)
bys _cou age: egen sd_educ=sd(educ)
bys _cou age: egen mean_educ=mean(educ)
gen school_zscore=(educ-mean_educ)/sd_educ

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

replace bmi=. if bmi>4200
replace height=. if height>2400

rename _cou country
rename v005 sweight
encode country, gen(_cou)

***Year of birth for Nepal
destring _year, replace
replace child_yob=_year-age+v006/12-b1/12 if country=="Nepal"&_year!=1996
replace child_yob=floor(child_yob) if country=="Nepal"&_year!=1996
replace child_yob=child_yob+1900 if child_yob<100
replace child_yob=child_yob+100 if child_yob>=1900&child_yob<=1902

******************************************************************************
*** (3) Create country income levels
******************************************************************************
do $PATH/Do/countrynaming

******************************************************************************
*** (4) Save data as working directory
******************************************************************************
save $PATH/Data/DHS_twins_rollback, replace
