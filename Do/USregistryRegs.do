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
global FLE "~/investigacion/Activa/Twins/Data/FemaleLifeExpUSA"

cap mkdir $OUT
log using "$LOG/USregistryRegs.txt", text replace

local birthregs  0
local fdeathregs 0
local SumStats   0
local graph      1

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
	local a absorb(year)
	
	areg twin100 `base' motherAge* i.birthOrder, `a'
	outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' replace
	*reg twin100 `base' i.motherAge i.birthOrder
	*outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' append
	areg twin100 `base' alcohol* motherAge* i.birthOrder, `a'
	outreg2 `base' alcohol* using "$OUT/USBirths.`fmt'", `sheet' append
	areg twin100 `base' alcohol* motherAge* i.birthOrder, `a'
	outreg2 `base' alcohol* using "$OUT/USBirths.`fmt'", `sheet' append
	areg twin100 `base' alcohol* `health' motherAge* i.birthOrder, `a'
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

	**take 10% sample
	set seed 2727
	gen bin=runiform()
	keep if bin>0.9
	drop bin
	
	local base africanAmerican otherRace meducSecond meducTert tobacco*
	local health diabetes chyper phyper eclamp
	foreach v of varlist `base' `health' alcoholUse motherAge* {
		gen TwinX`v'=twin*`v'
	}
	local Tbase twin TwinXtobacco* TwinXmeduc* TwinXafrican TwinXotherR TwinXmot*
	local T2    `Tbase' TwinXalcohol*
	local TH    `Tbase' TwinXdiab TwinXchyper TwinXphyper TwinXeclamp
	local FEs   i.birthOrder
	local a     absorb(year)
	
	areg fetaldeath `base' `Tbase' motherAge* `FEs', `a'
	outreg2 `base' `Tbase' using "$OUT/USfdeaths.`fmt'", `sheet' replace
	*areg fetaldeath `base' `Tbase' i.motherAge `FEs', `a'
	*outreg2 `base' `Tbase' using "$OUT/USfdeaths.`fmt'", `sheet' append
	areg fetaldeath `base' `T2' alcohol* motherAge* `FEs', `a'
	outreg2 `base' `T2' alcohol* using "$OUT/USfdeaths.`fmt'", `sheet' append
	*areg fetaldeath `base' `T2' alcohol* i.motherAg `FEs', `a'
	*outreg2 using `base' `T2' alcohol* "$OUT/USfdeaths.`fmt'", `sheet' append
	areg fetaldeath `base' `TH' `health' motherAge* `FEs', `a'
	outreg2 `base' `TH' `health' using "$OUT/USfdeaths.`fmt'", `sheet' append
	areg fetaldeath `base' `TH' TwinXal alcohol* `health' motherAge* `FEs', `a'
	outreg2 `base' `TH' TwinXa* alcohol* `health' using "$OUT/USfdeaths.`fmt'", /*
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

	estpost sum twin africanAmeric otherRace white meduc* tobaccoUse alcoholUse /*
	*/ anemia cardiac lung diabetes chyper phyper eclamp year yearalc           /*
	*/ if fetaldeath==0, d
	esttab using "$OUT/USDescriptivesBirths.tex", ///
	replace cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))")  ///
	style(tex) label collabels("N" "Mean" "S.Dev." "Min." "Max.") ///
	nomtitles nonumbers addnotes("All births 2003-2012")
	
	estpost sum twin africanAmeric otherRace white meduc* tobaccoUse alcoholUse /*
	*/ diabetes chyper phyper eclamp year yearalc if fetaldeath==1, d
	esttab using "$OUT/USDescriptivesDeaths.tex", ///
	replace cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))")  ///
	style(tex) label collabels("N" "Mean" "S.Dev." "Min." "Max.") ///
	nomtitles nonumbers addnotes("All fetal deaths 2003-2012")
}

if `graph'==1 {
  insheet using "$FLE/sp.dyn.le00.fe.in_Indicator_en_csv_v2.csv", names comma
  keep if countryname=="United States"
  drop indicator*
  reshape long v, i(countryname) j(year)
  rename v LifeExpectancy
  replace year=year+1956
  keep if year>=1971&year<=2012
  tempfile lifeexp
  save `lifeexp'


  local files
  foreach y of numlist 1971(1)2012 {
      use $DAT/Births/dta/clean/n`y'
      collapse twin, by(year)
      list
      tempfile f`y'
      save `f`y''
      local files `files' `f`y''
  }
  append using `files'
  collapse twin, by(year)
  merge 1:1 year using `lifeexp'
  
  twoway line twin year, xtitle("Year") ytitle("Proportion Twin") ///
    scheme(s1mono) xline(1981.9, lpattern(dash))                  ///
    note("Data from NVSS Birth Certificate Data."                 ///
         "Dotted line represents first ever IVF birth in USA.")
  graph export "$OUT/USTwin.eps", as(eps) replace

  local WB "Female Life Expectancy data from World Bank."
  local lp lpattern(dash_dot)
  twoway (line twin year) (line LifeExpectancy year, yaxis(2) `lp'),      ///
    ytitle("Proportion Twin") ytitle("Female Life Expectancy", axis(2))   ///
    xtitle("Year") scheme(s1mono) xline(1981.9, lpattern(dash))           ///
    legend(label(1 "Proportion Twins") label(2 "Female Life Expectancy")) ///
    note("Twin data from NVSS Birth Certificate Data.  `WB'"              ///
         "Dotted line represents first ever IVF birth in USA.")
   graph export "$OUT/USTwinFLE.eps", as(eps) replace

}

log close
