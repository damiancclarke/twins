/* ALSPACtests.do v0.00          damiancclarke             yyyy-mm-dd:2015-12-06
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file runs twin regressions using the ALSPAC data.  Regressions of the form:
  twin100_ij = a + B*Health_j + fert + MotherAge + u_ij
are run, where twin100 takes the value of 0 if child i of mother j is not a twin
and 100 if child i of mother j is a twin.  Independent variables consist of moth
er's health stocks and behvarious, as well as controls for completed fertility a
nd age at birth.

Locals are set in section (1b). These are the only things that should need to be
changed in the file if either (a) certain variable names are not as defined in t
hese locals, or if (b) certain variables are not available.  The globals DAT and
OUT also need to be set.  DAT is where the data is located, and OUT is where log
files and results files should be sent.  The local data gives the name of the AL
SPAC data file.

The only non-Stata library required is outreg2.  If this is not installed on the
computer/server, it will be installed. If it is not installed and the computer d
oes not have internet access, this file will fail to export results.
*/

vers 11
clear all
set more off
cap log close


cap which outreg2
if _rc!=0 ssc install outreg2

********************************************************************************
*** (1a) Set main globals and locals
********************************************************************************
global DAT "~/datafolderlocation"
global OUT "~/outputfolderlocation"


local data ALSPACdata
log using "$OUT/ALSPACtest.txt", text replace

********************************************************************************
*** (1b) Set locals of variables to include in analysis
********************************************************************************
#delimit ;
local y_var   twin100;
local health  pill prePreg5075kg prePreg75100kg prePreg100pkg height155165
              height165175 height175p diabetes hypertension infections preDrugs
              preAlcohol preSmoke anorexiaPast freqFattyFoods freqHealthFoods
              freqFreshFruit beerDrink beerDrinkHigh wineDrink wineDrinkHigh
              spiritsDrink spiritsDrinkHigh alcoholPreg alcoholPregHigh
              passiveSmoke1 passiveSmoke2 smokePreg smokeMissing depression
              depressionMissing miscarriages ageFirstBirth;
local FEs     i.motherAge i.fertility;
local gest    i.gestation;
local IVF     if ART==1;
#delimit cr

********************************************************************************
*** (2) Open data, label variable for output
********************************************************************************
use "$DAT/`data'"
********gen gestation        = 

gen twin100          = del_p50*100
gen pill             = d020 == 1 if d020!=-1
gen ART              = d031 == 1 if d031!=-1
gen fertility        = b005+1
gen motherAge        = e695
gen prePregWt        = dw002
gen prePreg0050kg    = dw002<50
gen prePreg5075kg    = dw002>=50&dw002<75
gen prePreg75100kg   = dw002>=75&dw002<100
gen prePreg100pkg    = dw002>=100
gen height           = dw021
gen height00155      = dw021<155
gen height155165     = dw021>=155&dw021<165
gen height165175     = dw021>=165&dw021<175
gen height175p       = dw021>=175
gen diabetes         = d041==2
gen hypertension     = d047==2
gen infections       = d059a if d059a!=-1
gen preDrugs         = d167==1|d167==2 if d167!=-1
gen preAlcohol       = d168==1|d168==2 if d168!=-1
gen preSmoke         = b650==2
gen anorexiaPast     = d170a==1
gen freqFattyFoods   = c200>3|c201>3|c210>3|c211>3|c220>3
gen freqHealthFoods  = c223>3|c224>3|c225>3
gen freqFreshFruit   = c229>3 
gen beerDrink        = c363>0&c363<5
gen beerDrinkHigh    = c363>=5
gen wineDrink        = c366>0&c366<5
gen wineDrinkHigh    = c366>=5
gen spiritsDrink     = c369>0&c369<5
gen spiritsDrinkHigh = c369>=5
gen alcoholPreg      = c373>0&c373<6
gen alcoholPregHigh  = 373>=6
gen passiveSmoke1    = c418a==2
gen passiveSmoke2    = c418a==3
gen smokePreg        = c482
gen smokeMissing     = c482<0
replace smokePrep    = 0 if c482<0
gen depression       = c579
gen depressionMissing= c579<0
replace depression   = 0 if c579<0
gen miscarriages     = b008>0
gen ageFirstBirth    = b023


********************************************************************************
*** (3) Regressions
********************************************************************************
tab twin100
sum twin100 `health'


reg twin100 `health'
outreg2 `health' using "$OUT/twinRegressions.xls", excel replace
reg twin100 `health' `FEs'
outreg2 `health' using "$OUT/twinRegressions.xls", excel append
reg twin100 `health' `FEs' `gestation'
outreg2 `health' using "$OUT/twinRegressions.xls", excel append


reg twin100 `health'                   `IVF'
outreg2 `health' using "$OUT/twinRegressions.xls", excel append
reg twin100 `health' `FEs'             `IVF'
outreg2 `health' using "$OUT/twinRegressions.xls", excel append
reg twin100 `health' `FEs' `gestation' `IVF'
outreg2 `health' using "$OUT/twinRegressions.xls", excel append

foreach var of varlist `health' {
    reg twin100 `var' `FEs' `gestation'
    outreg2 `var' using "$OUT/conditionalT-test.xls", excel append
}
