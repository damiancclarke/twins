/* CheckTwins 1.00                  UTF-8                       dh:2012-02-10
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cd "H:\ExtendedEssay\Twins"
cap log close
log using "log\20120210_CheckTwins.log", text replace
set more off
set mem 50m

use "Data\Birthdatabase19902008v4.dta"
tab sex

sort year_birth month_birth day_birth
gen sameday=day_birth[_n]-day_birth[_n-1]
gen sameday2=sameday[_n+1]

gen birthday=mdy( month_birth , day_birth , year_birth )
sort birthday health_service age_mother age_father
gen PT1=birthday[_n]-birthday[_n-1]
gen PT2=health_service[_n]-health_service[_n-1]
gen PT3=age_mother[_n]-age_mother[_n-1]
gen PT4=age_mother[_n]-age_mother[_n-1]

gen potential_twin=1 if PT1==0 & PT2==0 & PT3==0 & PT4==0
