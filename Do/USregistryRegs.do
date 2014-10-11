/* USregistryRegs.do v0.00       damiancclarke             yyyy-mm-dd:2014-06-30
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

Take cleaned data from USregistryPrep.do and run regressions of twinning, fetal
deaths and twin fetal deaths on characteristics. The location of raw fixed width
text files (zipped) is:
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

local birthregs 0
local fdeathregs 1

local fmt tex

if `"`fmt'"'=="tex" local sheet tex(pretty)
if `"`fmt'"'=="xls" local sheet excel
********************************************************************************
*** (2) Birth Regressions
********************************************************************************
if `birthregs'==1 {
	use "$DAT/Births/AppendedBirths.dta", clear
	gen twin100=twin*100
	gen motherAgeSq=motherAge*motherAge

	local base africanAmerican white meduc* tobacco*
	local health anemia cardiac lung diabetes chyper phyper eclamp

	reg twin100 `base'  motherAge* i.birthOrder i.year
	outreg2 using "$OUT/USBirths.`fmt'", `sheet' replace
	reg twin100 `base' i.motherAge i.birthOrder i.year
	outreg2 using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* motherAge* i.birthOrder i.year
	outreg2 using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* i.motherAge i.birthOrder i.year
	outreg2 using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* `health' i.motherAge i.birthOrder i.year 
	outreg2 using "$OUT/USBirths.`fmt'", `sheet' append
}

********************************************************************************
*** (3) Fetal Deaths Regressions
********************************************************************************
if `fdeathregs'==1 {
	use "$DAT/Births/AppendedBirths.dta", clear
	gen fetaldeath=0
	append using "$DAT/FetalDeaths/AppendedFDeaths.dta"
	replace fetaldeath=1 if fetaldeath==.
	gen twin100=twin*100
	gen motherAgeSq=motherAge*motherAge
	gen Twin100fetaldeath=twin100*fetaldeath
	drop if year<2003
	
	local base africanAmerican white meduc* tobacco*
	local health diabetes chyper phyper eclamp

	foreach var of varlist fetaldeath Twin100fetaldeath {
		reg `var' `base'  motherAge* i.birthOrder i.year
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' replace
		reg `var' `base' i.motherAge i.birthOrder i.year
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' append
		reg `var' `base' alcohol* motherAge* i.birthOrder i.year
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' append
		reg `var' `base' alcohol* i.motherAge i.birthOrder i.year
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' append
		reg `var' `base' `health' i.motherAge i.birthOrder i.year 
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' append
		reg `var' `base' alcohol* `health' i.motherAge i.birthOrder i.year 
		outreg2 using "$OUT/US`var'.`fmt'", `sheet' append
	}
}

log close

********************************************************************************
*** (4) Summary stats
********************************************************************************
