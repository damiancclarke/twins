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

local birthregs  1
local fdeathregs 1
local SumStats   1

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

	local base africanAmerican otherRace meducSecond meducTert tobacco*
	local health anemia cardiac lung diabetes chyper phyper eclamp

	reg twin100 `base' motherAge* i.birthOrder i.year
	outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' replace
	reg twin100 `base' i.motherAge i.birthOrder i.year
	outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* motherAge* i.birthOrder i.year
	outreg2 `base' alcohol* using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* i.motherAge i.birthOrder i.year
	outreg2 `base' alcohol* using "$OUT/USBirths.`fmt'", `sheet' append
	reg twin100 `base' alcohol* `health' i.motherAge i.birthOrder i.year 
	outreg2 `base' alcohol* `health' using "$OUT/USBirths.`fmt'", `sheet' append
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
	
	local base africanAmerican otherRace meducSecond meducTert tobacco*
	local health diabetes chyper phyper eclamp
	foreach var of varlist tobaccoUse meducS meducT `health' alcoholUse {
		gen TwinX`var'=twin*`var'
	}
	local Tbase twin TwinXtobacco TwinXmeduc* 
	local T2    twin TwinXtobacco TwinXmeduc* TwinXalcohol
	local TH    `Tbase' TwinXdiab TwinXchyper TwinXphyper TwinXeclamp
	local FEs   i.birthOrder i.year
	
	reg fetaldeath `base' `Tbase' motherAge* `FEs'
	outreg2 `base' `Tbase' using "$OUT/US`var'.`fmt'", `sheet' replace
	reg fetaldeath `base' `Tbase' i.motherAge `FEs'
	outreg2 `base' `Tbase' using "$OUT/US`var'.`fmt'", `sheet' append
	reg fetaldeath `base' `T2' alcohol* motherAge* `FEs'
	outreg2 `base' `T2' alcohol* using "$OUT/US`var'.`fmt'", `sheet' append
	reg fetaldeath `base' `T2' alcohol* i.motherAg `FEs'
	outreg2 using `base' `T2' alcohol* "$OUT/US`var'.`fmt'", `sheet' append
	reg fetaldeath `base' `TH' `health' i.motherAge `FEs'
	outreg2 `base' `TH' `health' using "$OUT/US`var'.`fmt'", `sheet' append
	reg fetaldeath `base' `TH' TwinXal alcohol* `health' i.motherAge `FEs' 
	outreg2 `base' `TH' TwinX* alcohol* `health' using "$OUT/US`var'.`fmt'", /*
	*/ `sheet' append
}

********************************************************************************
*** (4) Summary stats
********************************************************************************
if `SumStats'==1 {
	use "$DAT/Births/AppendedBirths.dta", clear
	gen fetaldeath=0
	append using "$DAT/FetalDeaths/AppendedFDeaths.dta"
	replace fetaldeath=1 if fetaldeath==.
	gen yearalc=year if alcoholUse!=.

	sum twin africanAmerica otherRace white meduc* tobaccoUse alcoholUse anemia /*
	*/ cardiac lung diabetes chyper phyper eclamp year yearalc if fetaldeath==0

	sum twin africanAmerican otherRace white meduc* tobaccoUse alcoholUse       /*
	*/ diabetes chyper phyper eclamp year yearalc if fetaldeath==1

}

log close
