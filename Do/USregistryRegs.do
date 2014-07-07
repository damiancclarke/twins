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
	gen meducPrimary=dmeduc>0&dmeduc<=8
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
gen meducPrimary=dmeduc>0&dmeduc<=8
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

	gen twin=dplural==2
	drop if dplural>2
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
	gen meducPrimary=dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married meducP meducS meducT educYrs state twin
	save "$DAT/Births/dta/clean/n`yy'", replace

}

foreach yy of numlist 1978(1)1988 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps

	gen twin=dplural==2
	drop if dplural>2
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
	gen meducPrimary=dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meducP meducS meducT educYrs state twin
	
}

foreach yy of numlist 1989(1)1994 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol /*
	*/ drink wtgain

	gen twin=dplural==2
	drop if dplural>2
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
	gen meducPrimary=dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17
	foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
	*/ pre4000 preterm renal {
		replace `var'=. if `var'==9
	}
	replace pre4000=2 if pre4000==8
	gen tobaccoNR=tobacco==9
	gen tobaccoUse=tobacco==1
	gen alcoholNR=alcohol==9
	gen alcoholUse=alcohol==1

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meducP meducS meducT educYrs state anemia cardiac lung /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR /*
	*/ tobaccoUse alcoholNR alcoholUse twin	
}

foreach yy of numlist 1995(1)2002 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat /*
	*/ nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper    /*
	*/ phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain

	gen twin=dplural==2
	drop if dplural>2
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
	gen meducPrimary=dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17
	foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
	*/ pre4000 preterm renal {
		replace `var'=. if `var'==9
	}
	replace pre4000=2 if pre4000==8
	gen tobaccoNR=tobacco==9
	gen tobaccoUse=tobacco==1
	gen alcoholNR=alcohol==9
	gen alcoholUse=alcohol==1

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meducP meducS meducT educYrs state anemia cardiac lung /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR /*
	*/ tobaccoUse alcoholNR alcoholUse twin
}

use "$DAT/Births/dta/natl2003", clear
count
keep dob_yy dob_mm ostate ubfacil mager41 mrace mar dmeduc priordead lbo_rec /*
*/ precare wtgain cig_0 cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia  /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000        /*
*/ urf_preterm urf_renal apgar5 dplural estgest combgest dbwt

gen twin=dplural==2
drop if dplural>2
rename mager41 motherAge
rename ostate state
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2003
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducPrimary=dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary=dmeduc>12&dmeduc<=17
foreach var of varlist urf_anemia urf_card urf_lung urf_diab urf_chyper /*
*/ urf_phyper urf_eclam urf_pre4000 urf_preterm urf_renal {
	replace `var'=. if `var'==9|`var'==8
}
gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder /*
*/ married marryU meducP meducS meducT educYrs state anemia cardiac lung /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR /*
*/ tobaccoUse alcoholNR alcoholUse twin

use "$DAT/Births/dta/natl2004", clear
count
keep dob_yy dob_mm ostate ubfacil mager mrace mar dmeduc fagerpt priordead        /*
*/ lbo_red precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000         /*
*/ urf_preterm urf_renal apgar5 dplural estgest combgest dbwt

gen twin=dplural==2
drop if dplural>2
rename mager motherAge
rename ostate state
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2004
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducPrimary=dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary=dmeduc>12&dmeduc<=17
foreach var of varlist urf_anemia urf_card urf_lung urf_diab urf_chyper /*
*/ urf_phyper urf_eclam urf_pre4000 urf_preterm urf_renal {
	replace `var'=. if `var'==9|`var'==8
}
rename urf_anemia anemia
rename urf_card cardiac
rename urf_lung lung
rename urf_diab diabetes
rename urf_chyper chyper
rename urf_phyper phyper
rename urf_eclam eclamp
rename urf_pre4000 pre4000
rename urf_preterm preterm
rename urf_renal renal
gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder        /*
*/ married marryU meducP meducS meducT educYrs state anemia cardiac lung /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
*/ tobaccoUse alcoholNR alcoholUse twin


use "$DAT/Births/dta/natl2005", clear
count
keep dob_yy dob_mm xostate ubfacil mager mrace mar dmeduc fagerpt priordead       /*
*/ lbo_rec precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000         /*
*/ urf_preterm urf_renal apgar5 dplural estgest combgest dbwt

gen twin=dplural==2
drop if dplural>2
rename mager motherAge
*rename ostate state
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2005
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducPrimary=dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary=dmeduc>12&dmeduc<=17
foreach var of varlist urf_anemia urf_card urf_lung urf_diab urf_chyper /*
*/ urf_phyper urf_eclam urf_pre4000 urf_preterm urf_renal {
	replace `var'=. if `var'==9|`var'==8
}
rename urf_anemia anemia
rename urf_card cardiac
rename urf_lung lung
rename urf_diab diabetes
rename urf_chyper chyper
rename urf_phyper phyper
rename urf_eclam eclamp
rename urf_pre4000 pre4000
rename urf_preterm preterm
rename urf_renal renal
gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder        /*
*/ married marryU meducP meducS meducT educYrs anemia cardiac lung       /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
*/ tobaccoUse alcoholNR alcoholUse twin

use "$DAT/Births/dta/natl2006", clear
count
keep dob_yy dob_mm ubfacil mager mrace mar dmeduc fagerpt lbo_rec precare cig_1   /*
*/ cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab   /*
*/ urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest /*
*/ combgest dbwt wtgain urf_renal

gen twin=dplural==2
drop if dplural>2
rename mager motherAge
*rename ostate state
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2006
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducPrimary=dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary=dmeduc>12&dmeduc<=17
foreach var of varlist urf_anemia urf_card urf_lung urf_diab urf_chyper /*
*/ urf_phyper urf_eclam urf_pre4000 urf_preterm urf_renal {
	replace `var'=. if `var'==9|`var'==8
}
rename urf_anemia anemia
rename urf_card cardiac
rename urf_lung lung
rename urf_diab diabetes
rename urf_chyper chyper
rename urf_phyper phyper
rename urf_eclam eclamp
rename urf_pre4000 pre4000
rename urf_preterm preterm
rename urf_renal renal
gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder        /*
*/ married marryU meducP meducS meducT educYrs anemia cardiac lung       /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
*/ tobaccoUse alcoholNR alcoholUse twin


foreach yy of numlist 2007 2008 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep dob_yy dob_mm ubfacil mager mrace mar dmeduc fagerpt lbo precare wtgain /*
	*/ cig_1 cig_2 cig_3 tobuse cigs rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm  /*
	*/ apgar5 dplural estgest combgest dbwt

	gen twin=dplural==2
	drop if dplural>2
	rename mager motherAge
	rename dob_mm birthMonth
	rename lbo birthOrder
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=mar==1
	gen marryUnreported=mar==9
	gen educYrs=dmeduc if dmeduc<66
	gen meducPrimary=dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary=dmeduc>12&dmeduc<=17
	foreach var of varlist rf_diab rf_phyp rf_ghyp rf_eclam rf_ppterm {
		replace `var'=. if `var'==9|`var'==8
	}
	rename rf_diab diabetes
	rename rf_phyp chyper
	rename rf_ghyp phyper
	rename rf_eclam eclamp
	rename rf_ppterm preterm
	gen tobaccoNR=tobuse==9
	gen tobaccoUse=tobuse==1

	keep motherAge africanAm white otherRace birthMon year birthOrder   /*
	*/ married marryU meducP meducS meducT educYrs chyper phyper eclamp /*
	*/ preterm tobaccoNR tobaccoUse twin

}

foreach yy of numlist 2009(1)2012 {
	use "$DAT/Births/dta/natl`yy'", clear
	count
	keep dob_yy dob_mm ubfacil mager mracerec mar meduc fagerpt lbo precare wtgain /*
	*/ cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm  /*
	*/ apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi

	gen twin=dplural==2
	drop if dplural>2
	rename mager motherAge
	rename dob_mm birthMonth
	rename lbo birthOrder
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=mar==1
	gen marryUnreported=mar==9
*	gen educYrs=dmeduc if dmeduc<66
*	gen meducPrimary=dmeduc>0&dmeduc<=8
*	gen meducSecondary=dmeduc>8&dmeduc<=12
*	gen meducTertiary=dmeduc>12&dmeduc<=17
	foreach var of varlist rf_diab rf_phyp rf_ghyp rf_eclam rf_ppterm {
		replace `var'=. if `var'==9|`var'==8
	}
	rename rf_diab diabetes
	rename rf_phyp chyper
	rename rf_ghyp phyper
	rename rf_eclam eclamp
	rename rf_ppterm preterm
*	gen tobaccoNR=tobuse==9
*	gen tobaccoUse=tobuse==1

	keep motherAge africanAm white otherRace birthMon year birthOrder   /*
	*/ married marryU chyper phyper eclamp preterm twin
	*tobaccoNR tobaccoUse meducP meducS meducT educYrs 

}
