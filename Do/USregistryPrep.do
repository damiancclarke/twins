/*USregistryPrep.do v0.00        damiancclarke             yyyy-mm-dd:2014-06-30
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Import raw text files of US birth and fetal death data and clean variables to c-
reate a set of standardised variables which exist (where possible) over all yea-
rs. The location of raw fixed width text files (zipped) is:
http://www.cdc.gov/nchs/data_access/Vitalstatsonline.htm#Tools

Processed files along with dictionary files are located on NBER's data reposito-
ry: http://www.nber.org/data/vital-statistics-natality-data.html

For optimal viewing of this file, set tab width=2.

For further details, including download details of birth and fetal death files
along with dictionary files for fetal death data:

contact: mailto:damian.clarke@economics.ox.ac.uk
code: https://github.com/damiancclarke/nchs-fetaldata

NOTES: 1969 has no plurality variable
       1970 has no plurality variable 
       Need to fix state variable for fetal death 2003
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
log using "$LOG/USregistryPrep.txt", text replace


local cleanBirths  0
local appendBirths 0
local cleanFDeath  1
local appendFDeath 1

********************************************************************************
*** (2a) Import and process birth data
********************************************************************************
if `cleanBirths'==1 {
use "$DAT/Births/dta/natl1968", clear
count
keep datayear stateres frace mrace birmon dmage birattnd dlegit dplural dbirwt/*
*/ dgestat dlivord

gen twin=dplural==2
drop if dplural>2
rename dmage motherAge
rename stateres state
destring state, replace
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
  destring state, replace
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
destring state, replace
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
  destring state, replace
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
  destring state, replace
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder>10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dmar==1
	gen marryUnreported=dmar==9
	gen educYrs=dmeduc if dmeduc<66
  gen meducNone     =dmeduc==0
	gen meducPrimary  =dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary =dmeduc>12&dmeduc<=17
  gen meducMissing  =dmeduc>=66

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meduc* educYrs state twin
	save "$DAT/Births/dta/clean/n`yy'", replace	
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
  destring state, replace
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder>10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dmar==1
	gen marryUnreported=dmar==9
	gen educYrs=dmeduc if dmeduc<66
  gen meducNone     =dmeduc==0
	gen meducPrimary  =dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary =dmeduc>12&dmeduc<=17
  gen meducMissing  =dmeduc>=66
	foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
	*/ pre4000 preterm renal {
      gen `var'Miss = `var'==9
	}
	replace pre4000=2 if pre4000==8
	gen tobaccoNR=tobacco==9
	gen tobaccoUse=tobacco==1
	gen alcoholNR=alcohol==9
	gen alcoholUse=alcohol==1

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meduc* educYrs state anemia cardiac lung twin   /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR  /*
	*/ tobaccoUse alcoholNR alcoholUse *Miss
	save "$DAT/Births/dta/clean/n`yy'", replace

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
  destring state, replace
	rename birmon birthMonth
	rename dtotord birthOrder
	replace birthOrder=. if birthOrder==99
	replace birthOrder=11 if birthOrder>10
	gen africanAmerican=mrace==2
	gen white=mrace==1
	gen otherRace=mrace>2
	gen year=`yy'
	gen married=dmar==1
	gen marryUnreported=dmar==9
	gen educYrs=dmeduc if dmeduc<66
  gen meducNone     =dmeduc==0
	gen meducPrimary  =dmeduc>0&dmeduc<=8
	gen meducSecondary=dmeduc>8&dmeduc<=12
	gen meducTertiary =dmeduc>12&dmeduc<=17
  gen meducMissing  =dmeduc>=66
	foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
	*/ pre4000 preterm renal {
      gen `var'Miss = `var'==9
	}
	replace pre4000=2 if pre4000==8
	gen tobaccoNR=tobacco==9
	gen tobaccoUse=tobacco==1
	gen alcoholNR=alcohol==9
	gen alcoholUse=alcohol==1

	keep motherAge africanAm white otherRace birthMon year birthOrder /*
	*/ married marryU meduc* educYrs state anemia cardiac lung twin   /*
	*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR  /*
	*/ tobaccoUse alcoholNR alcoholUse *Miss
	save "$DAT/Births/dta/clean/n`yy'", replace

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
replace motherAge=motherAge+13
rename ostate state
destring state, replace
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2003
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducNone     =dmeduc==0
gen meducPrimary  =dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary =dmeduc>12&dmeduc<=17
gen meducMissing  =dmeduc>=66
foreach var of varlist anemia card lung diab chyper /*
*/ phyper eclam pre4000 preterm renal {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
      rename urf_`var' `var'
}
rename card cardiac
rename cardMiss cardiacMiss
rename diab diabetes
rename diabMiss diabetesMiss
rename eclam eclamp
rename eclamMiss eclampMiss
gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder /*
*/ married marryU meduc* educYrs state anemia cardiac lung twin   /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR  /*
*/ tobaccoUse alcoholNR alcoholUse *Miss
save "$DAT/Births/dta/clean/n2003", replace

use "$DAT/Births/dta/natl2004", clear
count
keep dob_yy dob_mm ostate ubfacil mager mrace mar dmeduc fagerpt priordead        /*
*/ lbo_rec precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia /*
*/ urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000         /*
*/ urf_preterm urf_renal apgar5 dplural estgest combgest dbwt

gen twin=dplural==2
drop if dplural>2
rename mager motherAge
rename ostate state
destring state, replace
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2004
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducNone     =dmeduc==0
gen meducPrimary  =dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary =dmeduc>12&dmeduc<=17
gen meducMissing  =dmeduc>=66
foreach var of varlist anemia card lung diab chyper phyper eclam /*
*/ pre4000 preterm renal {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
      rename urf_`var' `var'
}
rename card cardiac
rename cardMiss cardiacMiss
rename diab diabetes
rename diabMiss diabetesMiss
rename eclam eclamp
rename eclamMiss eclampMiss

gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder  /*
*/ married marryU meduc* twin  educYrs state anemia cardiac lung   /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR   /*
*/ tobaccoUse alcoholNR alcoholUse *Miss
save "$DAT/Births/dta/clean/n2004", replace


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
*destring state, replace
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2005
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducNone     =dmeduc==0
gen meducPrimary  =dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary =dmeduc>12&dmeduc<=17
gen meducMissing  =dmeduc>=66
foreach var of varlist anemia card lung diab chyper phyper eclam /*
*/ pre4000 preterm renal {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
      rename urf_`var' `var'
}
rename card cardiac
rename cardMiss cardiacMiss
rename diab diabetes
rename diabMiss diabetesMiss
rename eclam eclamp
rename eclamMiss eclampMiss

keep motherAge africanAm white otherRace birthMon year birthOrder  /*
*/ married marryU meduc* twin educYrs anemia cardiac lung          /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR   /*
*/ tobaccoUse alcoholNR alcoholUse *Miss
save "$DAT/Births/dta/clean/n2005", replace

use "$DAT/Births/dta/natl2006", clear
count
keep dob_yy dob_mm ubfacil mager mrace mar dmeduc fagerpt lbo_rec precare cig_1   /*
*/ cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab   /*
*/ urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest /*
*/ combgest dbwt wtgain urf_renal

gen twin=dplural==2
drop if dplural>2
rename mager motherAge
rename dob_mm birthMonth
rename lbo_rec birthOrder
gen africanAmerican=mrace==2
gen white=mrace==1
gen otherRace=mrace>2
gen year=2006
gen married=mar==1
gen marryUnreported=mar==9
gen educYrs=dmeduc if dmeduc<66
gen meducNone     =dmeduc==0
gen meducPrimary  =dmeduc>0&dmeduc<=8
gen meducSecondary=dmeduc>8&dmeduc<=12
gen meducTertiary =dmeduc>12&dmeduc<=17
gen meducMissing  =dmeduc>=66
foreach var of varlist anemia card lung diab chyper phyper eclam /*
*/ pre4000 preterm renal {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
      rename urf_`var' `var'
}
rename card cardiac
rename cardMiss cardiacMiss
rename diab diabetes
rename diabMiss diabetesMiss
rename eclam eclamp
rename eclamMiss eclampMiss

gen tobaccoNR=tobuse==9
gen tobaccoUse=tobuse==1
gen alcoholNR=alcohol==9
gen alcoholUse=alcohol==1

keep motherAge africanAm white otherRace birthMon year birthOrder /*
*/ married marryU meduc* twin educYrs anemia cardiac lung         /*
*/ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR  /*
*/ tobaccoUse alcoholNR alcoholUse *Miss
save "$DAT/Births/dta/clean/n2006", replace


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
  gen meducNone     =dmeduc==0
  gen meducPrimary  =dmeduc>0&dmeduc<=8
  gen meducSecondary=dmeduc>8&dmeduc<=12
  gen meducTertiary =dmeduc>12&dmeduc<=17
  gen meducMissing  =dmeduc>=66
	gen diabetes=rf_diab=="Y"
	gen chyper=rf_phyp=="Y"
	gen phyper=rf_ghyp=="Y"
	gen eclamp=rf_eclam=="Y"
	gen preterm=rf_ppterm=="Y"
	gen diabetesMiss=0
	gen chyperMiss  =0
	gen phyperMiss  =0
	gen eclampMiss  =0
	gen pretermMiss =0

	gen tobaccoNR=tobuse==9|tobuse==.
	gen tobaccoUse=tobuse==1

	keep motherAge africanAm white otherRace birthMon year birthOrder   /*
	*/ married marryU meduc* twin educYrs chyper phyper eclamp          /*
	*/ preterm tobaccoNR tobaccoUse *Miss
	save "$DAT/Births/dta/clean/n`yy'", replace

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
  gen meducNone     =meduc==0
	gen meducPrimary  =meduc==1|meduc==2
	gen meducSecondary=meduc==3|meduc==4
	gen meducTertiary =meduc>=5&meduc<=8
  gen meducMissing  =meduc>8
  
	gen diabetes=rf_diab=="Y"
	gen chyper=rf_phyp=="Y"
	gen phyper=rf_ghyp=="Y"
	gen eclamp=rf_eclam=="Y"
	gen preterm=rf_ppterm=="Y"
	gen diabetesMiss=0
	gen chyperMiss  =0
	gen phyperMiss  =0
	gen eclampMiss  =0
	gen pretermMiss =0

	gen tobaccoNR=cig_r=="U"|cig_r==""
	gen tobaccoUse=cig_r=="Y"

	gen infertility=rf_inftr=="Y"
	gen infertilityNR=rf_inftr=="U"|rf_inftr==""

	keep motherAge africanAm white otherRace birthMon year birthOrder        /*
	*/ married marryU chyper phyper eclamp preterm twin meducP meducS meducT /*
	*/ tobaccoNR tobaccoUse infertility* meducMissing meducNone *Miss
	save "$DAT/Births/dta/clean/n`yy'", replace

}
}
********************************************************************************
*** (2b) Optionally append desired files into a huge all year file
********************************************************************************
if `appendBirths'==1 {
    clear
    foreach yy of numlist 2003(1)2012 {
        append using "$DAT/Births/dta/clean/n`yy'"
        count
    }
    save "$DAT/Births/AppendedBirths.dta", replace

    /*
    clear
    foreach yy of numlist 1980(1)1989 {
        append using "$DAT/Births/dta/clean/n`yy'"
        count
    }
    save "$DAT/Births/AppendedBirthsEarly.dta", replace
    */
    clear
    foreach yy of numlist 1989(1)2001 {
        dis "`yy'"
        append using "$DAT/Births/dta/clean/n`yy'"
        count
    }
    save "$DAT/Births/AppendedBirths90s.dta", replace

}


********************************************************************************
*** (3) Import and process fetal death data
********************************************************************************
if `cleanFDeath'==1 {
    foreach year of numlist 1989(1)2001 {
        use $DAT/FetalDeaths/dta/fetl`year', clear
        gen twin = dplural==2
        drop if dplural > 2
        rename dmage motherAge
        rename stateres state
        destring state, replace
        rename delmon deliveryMonth
        rename dtotord birthOrder
        replace birthOrder=. if birthOrder==99
        replace birthOrder=11 if birthOrder>10
        gen africanAmerican=mrace==2
        gen white=mrace==1
        gen otherRace=mrace>2
        gen year=`year'
        gen married=dmar==1
        gen marryUnreported=dmar==9
        gen educYrs=dmeduc if dmeduc<66
        gen meducNone     =dmeduc==0
        gen meducPrimary  =dmeduc>0&dmeduc<=8
        gen meducSecondary=dmeduc>8&dmeduc<=12
        gen meducTertiary =dmeduc>12&dmeduc<=17
        gen meducMissing  = dmeduc==99
        replace educYrs = 0 if meducMissing==1
        
        foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
        */ pre4000 preterm renal {
            gen `var'Miss = `var'==9|`var'==8
        }
        replace pre4000=2 if pre4000==8
        gen tobaccoNR=tobacco==9
        gen tobaccoUse=tobacco==1
        gen alcoholNR=alcohol==9
        gen alcoholUse=alcohol==1

        keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
        */ married marryU meducP meducS meduc* educYrs state anemia cardiac lung /*
        */ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
        */ tobaccoUse alcoholNR alcoholUse twin  *Miss
        save "$DAT/FetalDeaths/dta/clean/f`year'", replace
    }
    


    use $DAT/FetalDeaths/dta/fetl2002, clear

    gen twin=dplural==2
    drop if dplural>2
    rename dmage motherAge
    rename stateres state
    destring state, replace
    rename delmon deliveryMonth
    rename dtotord birthOrder
    replace birthOrder=. if birthOrder==99
    replace birthOrder=11 if birthOrder>10
    gen africanAmerican=mrace==2
    gen white=mrace==1
    gen otherRace=mrace>2
    gen year=2002
    gen married=dmar==1
    gen marryUnreported=dmar==9
    gen educYrs=dmeduc if dmeduc<66
    gen meducNone     =dmeduc==0
    gen meducPrimary  =dmeduc>0&dmeduc<=8
    gen meducSecondary=dmeduc>8&dmeduc<=12
    gen meducTertiary =dmeduc>12&dmeduc<=17
    gen meducMissing  = dmeduc==99
    foreach var of varlist anemia cardiac lung diabetes chyper phyper eclamp /*
    */ pre4000 preterm renal {
        gen `var'Miss = `var'==9|`var'==8
    }
    gen tobaccoNR=tobacco==9
    gen tobaccoUse=tobacco==1
    gen alcoholNR=alcohol==9
    gen alcoholUse=alcohol==1

    keep motherAge africanAm white otherRace deliveryMonth   year birthOrder /*
    */ married marryU meducP meducS meduc* educYrs state anemia cardiac lung /*
    */ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
    */ tobaccoUse alcoholNR alcoholUse twin *Miss
    save "$DAT/FetalDeaths/dta/clean/f2002", replace


    use "$DAT/FetalDeaths/dta/fetl2003", clear
    count

    gen twin=dplural==2
    drop if dplural>2
    rename mager motherAge
    replace motherAge=motherAge+13
    rename ostate state
    destring state, replace
    rename dod_mm deliveryMonth
    rename lbo_rec birthOrder
    gen africanAmerican=mrace==2
    gen white=mrace==1
    gen otherRace=mrace>2
    gen year=2003
    gen married=mar==1
    gen marryUnreported=mar==9
    gen educYrs=umeduc if umeduc<66
    gen meducNone     =umeduc==0
    gen meducPrimary  =umeduc>0&umeduc<=8
    gen meducSecondary=umeduc>8&umeduc<=12
    gen meducTertiary =umeduc>12&umeduc<=17
    gen meducMissing  =umeduc==99
    foreach var of varlist anemia card lung diab chyper /*
    */ phyper eclam pre4000 preterm renal {
        gen `var'Miss = urf_`var'==9|urf_`var'==8
    }
    rename card      cardiac
    rename diab      diabetes
    rename eclam     eclamp
    rename cardMiss  cardiacMiss
    rename diabMiss  diabetesMiss
    rename eclamMiss eclampMiss

    destring tobuse, replace
    gen tobaccoNR=tobuse==9
    gen tobaccoUse=tobuse==1
    gen alcoholNR=alcohol==9
    gen alcoholUse=alcohol==1
    
    keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
    */ married marryU meducP meducS meduc* educYrs state anemia cardiac lung /*
    */ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
    */ tobaccoUse alcoholNR alcoholUse twin *Miss
    save "$DAT/FetalDeaths/dta/clean/f2003", replace

    use "$DAT/FetalDeaths/dta/fetl2004", clear
    count

    gen twin=dplural==2
    drop if dplural>2
    rename mager motherAge
    rename ostate state
    destring state, replace
    rename dod_mm deliveryMonth
    rename lbo_rec birthOrder
    gen africanAmerican=mrace==2
    gen white=mrace==1
    gen otherRace=mrace>2
    gen year=2004
    gen married=mar==1
    gen marryUnreported=mar==9
    gen educYrs=umeduc if umeduc<66
    gen meducNone     =umeduc==0
    gen meducPrimary  =umeduc>0&umeduc<=8
    gen meducSecondary=umeduc>8&umeduc<=12
    gen meducTertiary =umeduc>12&umeduc<=17
    gen meducMissing  =umeduc==99
    foreach var of varlist anemia card lung diab chyper /*
    */ phyper eclam pre4000 preterm renal {
        gen `var'Miss = urf_`var'==9|urf_`var'==8
    }
    rename card      cardiac
    rename diab      diabetes
    rename eclam     eclamp
    rename cardMiss  cardiacMiss
    rename diabMiss  diabetesMiss
    rename eclamMiss eclampMiss

    destring tobuse, replace
    gen tobaccoNR=tobuse==9
    gen tobaccoUse=tobuse==1
    gen alcoholNR=alcohol==9
    gen alcoholUse=alcohol==1
    
    keep motherAge africanAm white otherRace deliveryMonth year birthOrder     /*
    */ married marryU meducP meducS meduc* educYrs state anemia cardiac lung /*
    */ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
    */ tobaccoUse alcoholNR alcoholUse twin *Miss
    save "$DAT/FetalDeaths/dta/clean/f2004", replace

    use "$DAT/FetalDeaths/dta/fetl2005", clear
    count

    gen twin=dplural==2
    drop if dplural>2
    rename mager motherAge
    *rename ostate state
    rename dod_mm deliveryMonth
    rename lbo_rec birthOrder
    gen africanAmerican=mrace==2
    gen white=mrace==1
    gen otherRace=mrace>2
    gen year=2005
    gen married=mar==1
    gen marryUnreported=mar==9
    gen educYrs=umeduc if umeduc<66
    gen meducNone     =umeduc==0
    gen meducPrimary  =umeduc>0&umeduc<=8
    gen meducSecondary=umeduc>8&umeduc<=12
    gen meducTertiary =umeduc>12&umeduc<=17
    gen meducMissing  =umeduc==99
    foreach var of varlist anemia card lung diab chyper /*
    */ phyper eclam pre4000 preterm renal {
        gen `var'Miss = urf_`var'==9|urf_`var'==8
    }
    rename card      cardiac
    rename diab      diabetes
    rename eclam     eclamp
    rename cardMiss  cardiacMiss
    rename diabMiss  diabetesMiss
    rename eclamMiss eclampMiss
    destring tobuse, replace
    gen tobaccoNR=tobuse==9
    gen tobaccoUse=tobuse==1
    gen alcoholNR=alcohol==9
    gen alcoholUse=alcohol==1
    
    keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
    */ married marryU meducP meducS meduc* educYrs anemia cardiac lung       /*
    */ diabetes chyper phyper eclamp pre4000 preterm renal tobaccoNR         /*
    */ tobaccoUse alcoholNR alcoholUse twin *Miss
    save "$DAT/FetalDeaths/dta/clean/f2005", replace

    use "$DAT/FetalDeaths/dta/fetl2006", clear
    count

    gen twin=dplural==2
    drop if dplural>2
    rename mager motherAge
    rename dod_mm deliveryMonth
    rename lbo_rec birthOrder
    gen africanAmerican=mracerec==2
    gen white=mracerec==1
    gen otherRace=mracerec>2
    gen year=2006
    gen married=mar==1
    gen marryUnreported=mar==9
    gen educYrs=umeduc if umeduc<66
    gen meducNone     =umeduc==0
    gen meducPrimary  =umeduc>0&umeduc<=8
    gen meducSecondary=umeduc>8&umeduc<=12
    gen meducTertiary =umeduc>12&umeduc<=17
    gen meducMissing  =umeduc==99
    foreach var of varlist diab chyper phyper eclam {
        gen `var'Miss = urf_`var'==9|urf_`var'==8
    }
    rename diab      diabetes
    rename eclam     eclamp
    rename diabMiss  diabetesMiss
    rename eclamMiss eclampMiss
    destring tobuse, replace
    gen tobaccoNR=tobuse==9
    gen tobaccoUse=tobuse==1
    
    keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
    */ married marryU meducP meducS meduc* educYrs diabetes chyper phyper    /*
    */ eclamp tobaccoNR tobaccoUse twin *Miss
    save "$DAT/FetalDeaths/dta/clean/f2006", replace


foreach yy of numlist 2007 2008 {
	use "$DAT/FetalDeaths/dta/fetl`yy'", clear
	count

	gen twin=dplural==2
	drop if dplural>2
	rename mager motherAge
	rename dod_mm deliveryMonth
	rename lbo_rec birthOrder
	gen africanAmerican=mracerec==2
	gen white=mracerec==1
	gen otherRace=mracerec>2
	gen year=`yy'
	gen married=mar==1
	gen marryUnreported=mar==9
  foreach var of varlist diab chyper phyper eclam {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
  }
  rename diab      diabetes
  rename eclam     eclamp
  rename diabMiss  diabetesMiss
  rename eclamMiss eclampMiss

  gen meducNone     =0
  gen meducPrimary  =0
  gen meducSecondary=0
  gen meducTertiary =0
  gen meducMissing  =1

	keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
	*/ married marryU diabetes chyper phyper eclamp twin meduc* *Miss
	save "$DAT/FetalDeaths/dta/clean/f`yy'", replace
}

foreach yy of numlist 2009(1)2012 {
	use "$DAT/FetalDeaths/dta/fetl`yy'", clear
	count

	gen twin=dplural==2
	drop if dplural>2
	rename mager motherAge
	rename dod_mm deliveryMonth
	rename lbo_rec birthOrder
	gen africanAmerican=mracerec==2
	gen white=mracerec==1
	gen otherRace=mracerec>2
	gen year=`yy'
	gen married=mar==1
	gen marryUnreported=mar==9

  gen meducNone     =0
  gen meducPrimary  =0
  gen meducSecondary=0
  gen meducTertiary =0
  gen meducMissing  =1

  foreach var of varlist diab chyper phyper eclam {
      gen `var'Miss = urf_`var'==9|urf_`var'==8
  }
  rename diab      diabetes
  rename eclam     eclamp
  rename diabMiss  diabetesMiss
  rename eclamMiss eclampMiss
		
	keep motherAge africanAm white otherRace deliveryMonth year birthOrder   /*
	*/ married marryU chyper phyper eclamp twin meduc* *Miss
	save "$DAT/FetalDeaths/dta/clean/f`yy'", replace

}
}

********************************************************************************
*** (3b) Alternatively append desired files into a large all year file
********************************************************************************
if `appendFDeath'==1 {
    clear
    foreach yy of numlist 2002(1)2012 {
        append using "$DAT/FetalDeaths/dta/clean/f`yy'"
        cap drop state
        count
    }
    save "$DAT/FetalDeaths/AppendedFDeaths.dta", replace


    clear
    foreach yy of numlist 1989(1)2001 {
        append using "$DAT/FetalDeaths/dta/clean/f`yy'"
        count
    }
    save "$DAT/FetalDeaths/AppendedFDeaths90s.dta", replace
}

