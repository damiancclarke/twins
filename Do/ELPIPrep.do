/* ELPIPrep.do                   damiancclarke             yyyy-mm-dd:2015-12-26
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Refactorisation of ELPI setup and regression file. This file takes ELPI data and
generates data on births, their type (twin/singleton) and variables recording ma
ternal health and health behaviours in and prior to pregnancy.

Regressions are now run in worldTwins.do

*/

clear all
version 11
set more off
cap log close
    
********************************************************************************
*** (1) Global and locals
********************************************************************************
global DAT "~/database/ELPI/Base"
global LOG "~/investigacion/Activa/Twins/Log"
global OUT "~/investigacion/Activa/Twins/Data"

log using "$LOG/ELPIPrep.txt", text replace

local w [pw=fexp_enc]


********************************************************************************
*** (1) Create relevant vars from Hogar database
*** Note that a16 is member identifier. Value 6 implies sibling, and value 13 is
*** the child to be followed.
********************************************************************************
use "$DAT/Hogar"
bys folio: egen fert=total(a16==6) 
replace fert=fert+1

gen child=1 if a16==6 | a16==13 
gsort folio child -a19 
bys folio: gen birthorder=_n if child==1

bys folio: gen m_age=a19 if a16==1
bys folio: egen motherAge=mean(m_age)

generat motherAgeSq    = motherAge*motherAge
generat motherAgeBirth = motherAge-a19 if a16==6 | a16==13
replace motherAgeBirth = . if motherAgeBirth<10

generat educ=1 if b02n==19|b02n==99
replace educ=2 if b02n<=4
replace educ=3 if b02n>4 & b02n<=7
replace educ=4 if b02n>7 & b02n<=11 & b02c<4
replace educ=5 if b02n>7 & b02n<=11 & b02c>=4
replace educ=6 if b02n==12|b02n==14
replace educ=7 if b02n==16
replace educ=8 if b02n==13|b02n==15
replace educ=9 if b02n==17|b02n==18
#delimit ;
label def elab 1 "None" 2 "Pre-school" 3 "Primary" 4 "Secondary incomplete"
  5 "Secondary complete" 6 "Technical incomplete" 7 "University incomplete"
  8 "Technical complete" 9 "University Complete";
label val educ elab;
#delimit cr

gen mateduc=educ if a16==1
bys folio: egen motherEduc = mean(mateduc)
gen primary   = educ<4&educ!=1
gen secondary = (educ>=5&educ<=7)
gen tertiary  = (educ>7&educ!=.)

gen MP = primary   if a16==1
gen MS = secondary if a16==1
gen MT = tertiary  if a16==1

bys folio: egen Mprimary=max(MP)
by  folio: egen Msecondary=max(MS)
by  folio: egen Mtertiary=max(MT)


generat familyI = d11m
replace familyI = 50000   if d11t==1
replace familyI = 98000   if d11t==2
replace familyI = 191000  if d11t==3
replace familyI = 300000  if d11t==4
replace familyI = 400000  if d11t==5
replace familyI = 550000  if d11t==6
replace familyI = 750000  if d11t==7
replace familyI = 950000  if d11t==8
replace familyI = 1150000 if d11t==9
replace familyI = 1500000 if d11t==10
replace familyI = .       if familyI==99

bys folio: egen familyIncome=max(familyI)
gen incomePerCapita   = (familyIncome/tot_per)/1000
gen incomePerCapitaSq = incomePerCapita*incomePerCapita

rename a18 sex
gen indigenous=(a23!=10&a23!=99)

#delimit ;
keep folio a16 a19 orden tot_per d11m fexp_hog fert birthorder motherAge* educ
familyIncome sex indigenous child incomePerCapita* motherEduc Mprimar Msecondar
Mtertiary;
#delimit cr

    
********************************************************************************
*** (2) Create relevant vars from Entrevistada database
********************************************************************************
merge m:1 folio using "$DAT/Entrevistada"

gen twin = a03==1|a03==2
gen pregNoAttention       = g01
gen pregNumControls       = g02
gen pregAnemia            = g03_08==8
gen pregDiabetes          = g03_07==7
gen pregCondPhysical      = g03_13!=13
gen pregCondPsychological = g04a_9!=9
gen pregDepression        = g04a_1==1
gen pregNutrition         = g06a
gen pregLowWeight         = g06a==1
gen pregObese             = g06a==4
gen pregSmoked            = g07a==1
gen pregSmokedQuant       = g07b
gen pregDrugs             = g11b
gen pregAlcohol           = g09
gen pregHosp              = g16==1
gen pregPublicHosp        = g16==3
gen lowWeightPre          = g05b==1
gen obesePre              = g05b==4
gen nutritionPre           = g05b
exit
gen poor  = incomePerCapita <32000
gen age   = a19
gen rural = area

replace nutritionPre = . if nutritionPre>4
replace pregNutrition = . if pregNutrition>4
replace pregNoAttention = . if pregNoAttention==9
replace pregNumControls = . if pregNumControls==9
replace pregSmokedQuant = 0 if pregSmokedQuant==.
replace pregSmokedQuant = . if pregSmokedQuant==999
replace pregDrugs=. if pregDrugs==8
replace pregAlcohol=. if pregAlcohol==8
gen pregDrugsModerate   = pregDrugs==2 if pregDrugs!=.
gen pregDrugsHigh       = pregDrugs==3 if pregDrugs!=.
gen pregAlcoholModerate = pregAlcohol==2 if pregAlcohol!=.
gen pregAlcoholHigh     = pregAlcohol==3 if pregAlcohol!=.


label def nutr 1 "Low weight" 2 "Normal" 3 "Overweight" 4 "Obese"  
label val pregNutrition nutr
label val nutritionPre nutr



label var pregNoAttention "Mother received no medical attention during pregnancy"
label var pregNumControls "Number of pregnancy controls"
label var pregAnemia "Mother suffered from Anemia during pregnancy"
label var pregCondPhysical "Suffered from a physical condition during pregnancy"
label var pregCondPsych "Suffered from a psychological condition during pregnancy"
label var pregNutrition "Mother's nutritional status during pregnancy"
label var nutritionPre "Mother's nutritional status before pregnancy"
label var pregSmoked "Mother smoked during pregnancy (binary)"
label var pregSmokedQuant "Quantity cigarettes smoked per month during pregnancy"
label var pregDrugs "Mother consumed recreational drugs during pregnancy"
label var pregAlcohol "Mother consumed alcohol during pregnancy"
label var pregHosp "Birth took place in public hospital"
label var pregPublicHosp "Birth took place in private system"


label var m_age_birth "Age of mother at child's birth"
label var sex "Gender"
label var family_inc "Monthly family income"
label var educ "Education level (not years)"
label var mother_age "Current age of mother"
label var child "Selected child or sibling"
label var fert "Sibship size of selected child"
label var birthorder "Order of births in child's family"
label var ypc "Income per person in the household"
label var mother_educ "Maternal education (of followed child)"




exit

keep if a16==13

********************************************************************************
*** (3b) Updated output (pre versus during)
********************************************************************************
fvexpand Msecondary Mtertiary incomepc* lowWeightPre obesePre
local prePreg `r(varlist)'
fvexpand pregNoAt pregDiab pregDepr pregLowW pregObese pregSmoked  /*
*/ pregDrugsModerate pregDrugsHigh pregAlcoholModerate pregAlcoholHigh pregHosp
local preg `r(varlist)'

if `cleanreg'==1 {
	replace twin=twin*100
	eststo: reg twin `region' `prePreg' `preg' `base' `c' `w'
	estout est1 using "$RESULTS/twinELPI.xls", keep(`prePreg' `preg' `base') replace /*
	*/ cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) /*
	*/ stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)
  keep if e(sample)==1
	estpost sum `prePreg' `preg' `base', d
	
	esttab using "$RESULTS/ELPISum_2.xls", ///
	replace cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))")  ///
	label collabels("N" "Mean" "S.Dev." "Min." "Max.") ///
	nomtitles nonumbers addnotes("Sample of individuals of all index children ELPI")

}
