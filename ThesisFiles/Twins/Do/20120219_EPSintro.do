/* EPS_Intro 1.00                  UTF-8                   		dh:2012-02-19
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/

version 11.2
cap log close
*cd "Z:/home/damian/Escritorio/DCC/Universidades/Oxford/MSc/ExtendedEssay" //Ub
*cd "E:/DCC/Universidades/Oxford/MSc/ExtendedEssay" //External Drive
cd "H:\ExtendedEssay\Twins" // Manor Road
log using "log\20120219_EPSintro.log", text replace
clear all
set more off
set mem 20m

global Data H:\ExtendedEssay\Twins\Data\EPS\base_2009_Stata

use "$Data/hogar"
keep if a5==3
keep folio orden a8 a9 a11 a12c a12n
rename a8 sex
rename a9 age
rename a11 educ
rename a12c curso
rename a12n nivel


reshape wide sex age educ curso nivel, i(folio) j(orden)

foreach x of numlist 1(1)18{
foreach num of numlist 1(1)18{
gen age`x'_`num'=age`x'-age`num'
}
}
*drop age1_1 age2_2 age3_3 age4_4 age5_5 age6_6 age7_7 age8_8 age9_9 age10_10
*drop age11_11 age12_12 age13_13 age14_14 age15_15 age16_16 age17_17 age18_18
replace age1_1=.
replace age2_2=.
replace age3_3=.
replace age4_4=.
replace age5_5=.
replace age6_6=.
replace age7_7=.
replace age8_8=.
replace age9_9=.
replace age10_10=.
replace age11_11=.
replace age12_12=.
replace age13_13=.
replace age14_14=.
replace age15_15=.
replace age16_16=.
replace age17_17=.
replace age18_18=.

gen twinfam=.
foreach x of numlist 1(1)18{
foreach num of numlist 1(1)18{
replace twinfam=1 if age`x'_`num'==0
}
}

keep folio twinfam

merge 1:m folio using "$Data/hogar"
keep if a4==3
sort twinfam folio a9
egen twincalc=concat(folio a9)
gen twincalc12=real(twincalc)
replace twincalc1=twincalc1/10000
gen twincalc2=twincalc1[_n]-twincalc1[_n-1]
gen twin=1 if twincalc2==0
gen twincalc3=twincalc1[_n]-twincalc1[_n+1]
replace twin=1 if twincalc3==0
