* USregistryRegs.do v0.00 damiancclarke yyyy-mm-dd:2014-06-30
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* Take cleaned data from USregistryPrep.do and run regressions of twinning, fet-
al deaths and twin fetal deaths on characteristics. The location of raw fixed wi-
dth text files (zipped) is:
http://www.cdc.gov/nchs/data_access/Vitalstatsonline.htm#Tools

Processed files along with dictionary files are located on NBER's data reposit-
ory: http://www.nber.org/data/vital-statistics-natality-data.html

For optimal viewing of this file, set tab width=2.

NOTES: 1969 has no plurality variable
1970 has no plurality variable
*/

vers 11
set more off
cap log close
clear all


********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/database/NVSS"
global OUT "~/investigacion/Activa/Twins/Results/NVSS_USA"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir $OUT
log using "$LOG/USregistryRegs.txt", text replace

********************************************************************************
*** (2) Birth Regressions
********************************************************************************
use "$DAT/Births/AppendedBirths.dta", clear
gen twin100=twin*100
gen motherAgeSq=motherAge*motherAge

local base africanAmerican white meduc* tobacco*
local health anemia cardiac lung diabetes chyper phyper eclamp


reg twin100 `base'  motherAge* i.birthOrder i.year
outreg2 using "$OUT/USBirths.xls", excel replace
reg twin100 `base' i.motherAge i.birthOrder i.year
outreg2 using "$OUT/USBirths.xls", excel append
reg twin100 `base' alcohol* motherAge* i.birthOrder i.year
outreg2 using "$OUT/USBirths.xls", excel append
reg twin100 `base' alcohol* i.motherAge i.birthOrder i.year
outreg2 using "$OUT/USBirths.xls", excel append
reg twin100 `base' alcohol* `health' i.motherAge i.birthOrder i.year 
outreg2 using "$OUT/USBirths.xls", excel append


