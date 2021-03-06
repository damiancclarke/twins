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
if `"`fmt'"'=="tex" local sheet tex(pretty frag) label
if `"`fmt'"'=="xls" local sheet excel label

********************************************************************************
*** (2) Birth Regressions
********************************************************************************
if `birthregs'==1 {
    use "$DAT/Births/AppendedBirthsEarly.dta", clear
    **take 10% sample
    set seed 2727
    gen bin=runiform()
    keep if bin>0.9
    drop bin

    gen twin100=twin*100
    gen motherAgeSq=motherAge^2

    lab var africanAmerican "African American"
    lab var otherRace       "Other Race"
    lab var married         "Married"
    lab var meducSecondary  "Secondary Education"
    lab var meducTertiary   "Tertiary Education"

    local base africanAm otherRa meducSeco meducTer married
    local a absorb(year)

    areg twin100 `base' motherAge* birthOrder marryUn, `a'
    outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' replace

    use "$DAT/Births/AppendedBirths.dta", clear
    keep if year>=2003
    **take 10% sample
    set seed 2727
    gen bin=runiform()
    keep if bin>0.9
    drop bin

    gen twin100=twin*100
    gen motherAgeSq=motherAge*motherAge

    lab var africanAmerican "African American"
    lab var otherRace       "Other Race"
    lab var married         "Married"
    lab var meducSecondary  "Secondary Education"
    lab var meducTertiary   "Tertiary Education"
    lab var tobaccoUse      "Consumed tobacco (pre-birth)"
    lab var alcoholUse      "Consumed alcohol (pre-birth)"
  
    local base africanAmerican otherRace meducSecond meducTert tobacco*
    local health anemia cardiac lung diabetes chyper phyper eclamp
	
    areg twin100 `base' motherAge* i.birthOrder, `a'
    outreg2 `base' using "$OUT/USBirths.`fmt'", `sheet' append
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
  tab year
	gen fetaldeath=0

  keep if motherAge>15&motherAge<40
	**take 5% sample
	set seed 27
	gen bin=runiform()
	keep if bin>0.90
	drop bin

  append using "$DAT/FetalDeaths/AppendedFDeaths.dta"
  tab year
  drop if year==2002
  keep if motherAge>15&motherAge<40
	replace fetaldeath=1 if fetaldeath==.
	gen twin100=twin*100
	gen motherAgeSq=motherAge*motherAge
	gen Twin100fetaldeath=twin100*fetaldeath

  
	local base africanAmerican otherRace meducNo meducPri meducSec meducMiss tobac*
	local health phyper eclamp 
	foreach v of varlist `base' `health' alcoholUse motherAge* {
		gen TwinX`v'=twin*`v'
	}

	local Tbase twin TwinXtobacco* TwinXmeduc* TwinXafrican TwinXotherR
	local T2    `Tbase' TwinXalcohol*
	local H     `health' TwinXphyper TwinXeclamp 
	local FEs   i.birthOrder i.motherAge i.motherAge#c.twin
	local a     absorb(year)
  local out1  africanAmerican meducPrim meducSecond meducNone tobaccoUse
  local Tout1 TwinXafr TwinXmeducP TwinXmeducS TwinXmeducN TwinXtobaccoU twin
  local out2  africanAmerican meducPrim meducSecond tobaccoUse alcoholU 
  local Tout2 `Tout1' TwinXalcoholU

  lab var africanAmerican "African American"
  lab var meducSecondary  "Secondary Education"
  lab var meducPrim       "Primary Education"
  lab var meducTer        "Tertiary Education"
  lab var meducNone       "No Education"
  lab var tobaccoUse      "Consumed tobacco (pre-birth)"
  lab var alcoholUse      "Consumed alcohol (pre-birth)"
  lab var phyper          "Pregnancy related hypertension"
  lab var eclamp          "Eclampsia"
  lab var twin            "Twin"
  lab var TwinXafricanA   "Twin $\times$ African American"
  lab var TwinXmeducSecon "Twin $\times$ Secondary"
  lab var TwinXmeducPrim  "Twin $\times$ Primary Education"
  lab var TwinXmeducNone  "Twin $\times$ No Education"
  lab var TwinXtobaccoUse "Twin $\times$ Tobacco"
  lab var TwinXalcoholUse "Twin $\times$ Alcohol"
  lab var TwinXphyper     "Twin $\times$ Hypertension"
  lab var TwinXeclamp     "Twin $\times$ Eclampsia"
  
  gen miscarry100=fetaldeath*100

	areg miscarry100 `base' `Tbase' `FEs', `a'
	outreg2 `out1' `Tout1' using "$OUT/USfdeaths.`fmt'", `sheet' replace
	areg miscarry100 `base' `T2' alcohol* `FEs', `a'
	outreg2 `out2' `Tout2' using "$OUT/USfdeaths.`fmt'", `sheet' append
	areg miscarry100 `base' `T2' `H' alcohol* `FEs', `a'
	outreg2 `out2' `Tout2' `H' using "$OUT/USfdeaths.`fmt'", `sheet' append
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
      keep if motherAge<35
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
    legend(label(1 "Proportion Twins") label(2 "Female Life Expectancy")) 
    *note("Twin data from NVSS Birth Certificate Data.  `WB'"             ///
    *     "Dotted line represents first ever IVF birth in USA.")
   graph export "$OUT/USTwinFLE.eps", as(eps) replace

}

log close
