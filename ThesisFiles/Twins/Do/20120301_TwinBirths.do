/* TwinBirths 1.00                  UTF-8                       dh:2012-03-01
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base H:\ExtendedEssay\Twins
cd $Base\Log
log using $Base\Log\20120301_TwinBirths.txt, text replace
use $Base\..\DHS\world_child
*use $Base\..\DHS\world_childsmall //small is 10% sample

**(1) SETUP
gen twind=1 if twinc>0  //twind is actually multiple birth
replace twind=0 if twinc==0
*rename v301 contracept_know
*rename v302 contracept_use
rename v501 maritalstatus
rename v504 husbandhouse
rename v715 educ_husband
replace educ_husband=. if educ_husband>24
tab partocc, gen(husb_work)

global x_complete bord educfyrs height bmi poor1 contracept_use contracept_know
global x_minimal bord educfyrs poor1 contracept_use contracept_know 
global z twind

*gen y variables
*Gen ht/age, wt/age
gen child_age=round(agechild_cmc/12)
gen ht_age=hw3/child_age if agec<19
gen wt_age=hw2/child_age if agec<19 //these are no good.



**(2)MISSING VARIABLES
count if height==.
tab twind if height==.
tab twind if height!=.

sum twind fert $x_complete if height!=.
sum twind fert $x_complete if height==.
keep if height<210 & height>85




**(3)TESTED SPECIFICATIONS

*probit twind fert educfyrs maritalstatus husbandhouse contracept_use /*
**/contracept_know height i.yearint i.continent [pw=sweight]
*probit twind fert educfyrs maritalstatus husbandhouse contracept_use /*
**/contracept_know height i.yearint i.ncode [pw=sweight]
*probit twind fert educfyrs maritalstatus husbandhouse contracept_use /*
**/contracept_know height wealthq i.yearint [pw=sweight], vce(cluster ncode)
*probit twind fert educfyrs maritalstatus husbandhouse contracept_use /*
**/contracept_know height bmi i.yearc [pw=sweight] if v015==1, vce(cluster ncode)

*probit twind fert $x_complete [pw=sweight] if v015==1, vce(cluster ncode)
*mfx
*outreg2 using $Base\twinprob, tex(pr) replace 

*probit twind fert $x_complete educ_husband [pw=sweight] if v015==1, /*
**/vce(cluster ncode)

reg twind bord agemay educfyrs educfyrs2 height bmi poor1 i.ncode i.yearc [pw=sweight] if v015==1, vce(cluster ncode)
outreg2 bord agemay educfyrs educfyrs2 height bmi poor1 using $Base\Results\TwinEndog, tex(pr) replace 
reg twind bord agemay i.educfyrs height bmi poor1 i.ncode i.yearc [pw=sweight] if v015==1, vce(cluster ncode)
outreg2 bord agemay educfyrs educfyrs2 height bmi poor1 using $Base\Results\TwinEndog, tex(pr) append
reg twind bord i.agemay educfyrs educfyrs2 height bmi1 poor1 i.ncode i.yearc [pw=sweight] if v015==1, vce(cluster ncode)

probit twind fert $x_complete anemia i.yearc [pw=sweight] if v015==1, vce(cluster ncode)




**(4)TEST CHILD QUANTITY-QUALITY MODEL
probit b5 $x_complete anemia fert i.yearc i.ncode [pw=sweight], vce(cluster ncode)
ivprobit b5 $x_complete anemia i.yearc i.ncode (fert=$z), twos
ivprobit b5 $x_complete anemia i.yearc (fert=twind) [pw=sweight], difficult


log close
