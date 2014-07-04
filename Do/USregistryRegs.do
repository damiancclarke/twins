* USregistryRegs.do v0.00        damiancclarke             yyyy-mm-dd:2014-06-30
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* Import raw text files of US birth and fetal death data and run regressions of
twinning, fetal deaths and twin fetal deaths on characteristics. The location of
raw fixed width text files (zipped) is:
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

#delimit ;
local FetDeath VS82FETL.DETUSPUB VS83FETL.DETUSPUB VS84FETL.DETUSPUB
  VS85FETL.DETUSPUB VS86FETL.DETUSPUB VS87FETL.DETUSPUB VS88FETL.DETUSPUB
  VS89FETL.DETUSPUB VS90FETL.DETUSPUB VS91FETL.DETUSPUB VS92FETL.DETUSPUB
  VS93FETL.DETUSPUB VS94FETL.DETUSPUB VS95FETL.DETUSPUB VS96FETL.DETUSPUB
  VS97FETL.DETUSPUB VS98FETL.DETUSPUB VS99FETL.DETUSPUB VS00FETL.DETUSPUB
  VS01FETL.DETUSPUB VS02FETL.DETUSPUB VS03FETL.DETUSPUB VS04FETL.DETUSPUB
  vs05fetl.publicUS vs06fetal.DETUSPUB VS07Fetal.PublicUS
  VS09Fetal.Detailuspub.txt VS10Fetalupdated.Detailuspub.Detailuspub
  VS11Fetal.DetailUSpubfinalupdate.DetailUSpub VS12FetalDetailUSPub.txt;

#delimit cr


********************************************************************************
*** (2) Import and process birth data
********************************************************************************
use "$DAT/Births/dta/natl1968", clear
count
keep datayear stateres frace mrace birmon dmage birattnd dlegit dplural dbirwt/*
*/ dgestat dlivord

gen twin=dplural==2
drop if dplural>2
rename dmage motherAge
rename stateres state
rename birmon birthMonth
rename dlivord birthOrder
replace birthOrder=. if birthOrder==99
replace birthOrder=11 if birthOrder>10
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=1968
gen married=dlegit==1

keep twin motherAge africanAm white otherRace birthMon year birthOrder married /*
*/ state
save "$DAT/Births/dta/clean/n1968", replace

foreach yy of numlist 1969 1970 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt /*
	*/ dgestat nlbd dtotord dmeduc llbyr disllb

	rename dmage motherAge
	rename stateres state
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder>10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dlegit==1
	gen educYrs=dmeduc if dmeduc<66
	gen meducPrimary=dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married meducP meducS meducT educYrs state
	save "$DAT/Births/dta/clean/n`yy'", replace
}

use "$DAT/Births/dta/natl1971", clear
count
keep datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat /*
*/ nlbd dtotord dmeduc llbyr disllb dplural

gen twin=dplural==2
drop if dplural>2
rename dmage motherAge
rename stateres state
rename birmon birthMonth
rename dtotord birthOrder
replace birthOrder=. if birthOrder==99
replace birthOrder=11 if birthOrder>10
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=1971
gen married=dlegit==1
gen educYrs=dmeduc if dmeduc<66
gen meducPrimary=dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary=dmeduc>12&dmeduc<=17

keep twin motherAge africanAm white otherRace birthMon year birthOrder /*
*/ married meducP meducS meducT educYrs state
save "$DAT/Births/dta/clean/n1971", replace

foreach yy of numlist 1972(1)1977 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt /*
	*/ dgestat nlbd dtotord dmeduc llbyr disllb dplural

	rename dmage motherAge
	rename stateres state
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder<10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dlegit==1
	gen educYrs=dmeduc if dmeduc<66
	gen meducPrimary=dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married meducP meducS meducT educYrs state
	save "$DAT/Births/dta/clean/n`yy'", replace

}

foreach yy of numlist 1978(1)1988 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps

	rename dmage motherAge
	rename stateres state
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder<10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dmar==1
	gen marryUnreported=dmar==9
	gen educYrs=dmeduc if dmeduc<66
	gen meducPrimary=dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meducP meducS meducT educYrs state
	
}

kill here
foreach yy of numlist 1989(1)1994 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol /*
	*/ drink wtgain
}

foreach yy of numlist 1995(1)2002 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper    /*
	*/ phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
}

use "$DAT/Births/dta/natl2003", clear
count
keep dob_yy dob_mm ostate ubfacil umagerpt mrace mar meduc fagerpt priordead lbo /*
*/ precare wtgain cig_0 cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia  /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000        /*
*/ urf_preterm apgar5 dplural estgest combgest dbwt

use "$DAT/Births/dta/natl2004", clear
count
keep dob_yy dob_mm ostate ubfacil mager mrace mar meduc fagerpt priordead        /*
*/ lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia    /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000        /*
*/ urf_preterm apgar5 dplural estgest combgest dbwt

use "$DAT/Births/dta/natl2005", clear
count
keep dob_yy dob_mm xostate ubfacil mager mrace mar meduc fagerpt priordead       /*
*/ lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia    /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000        /*
*/ urf_preterm apgar5 dplural estgest combgest dbwt

use "$DAT/Births/dta/natl2006", clear
count
keep dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_1 /*
*/ cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab   /*
*/ urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest /*
*/ combgest dbwt

foreach yy of numlist 2007 2008 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain    /*
	*/ cig_1 cig_2 cig_3 tobuse cigs rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm    /*
	*/ apgar5 dplural estgest combgest dbwt
}

foreach yy of numlist 2009(1)2012 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain    /*
	*/ cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm  /*
	*/ apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi
}
