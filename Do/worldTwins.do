/* worldTwins.do v0.00           damiancclarke             yyyy-mm-dd:2015-10-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Generate figures to present characteristics of twin and non-twin mothers across
 countries/regions.  It uses nationally representative surveys or administrative
 records of births.  Data comes from:
   Albania: DHS
   Armenia: DHS
   Kenya  : DHS
   USA    : Administrative data (NVSS)


*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data"
global GRA "~/investigacion/Activa/Twins/Figures"
global LOG "~/investigacion/Activa/Twins/Log"
global OUT "~/investigacion/Activa/Twins/Results/Sum"

log using "$LOG/worldTwins.txt", text replace
/*
********************************************************************************
*** (2) DHS figures
********************************************************************************
use "$DAT/DHS_twins"
keep if _merge==3
keep if motherage>17&motherage<50

replace height = . if height>240
replace height = . if height<70

levelsof country, local(cc)
gen countryName = ""
gen heightEst   = .
gen heightLB    = .
gen heightUB    = .
gen educEst     = .
gen educLB      = .
gen educUB      = .


local iter = 1
foreach c of local cc {
    if `"`c'"'=="Indonesia"|`"`c'"'=="Pakistan"|`"`c'"'=="Paraguay"      exit
    if `"`c'"'=="Philippines"|`"`c'"'=="South-Africa"|`"`c'"'=="Ukraine" exit
    if `"`c'"'=="Vietnam"|`"`c'"'=="Yemen" exit
    qui areg height twindfamily i.fert if country=="`c'", abs(motherage)
    local estl `=_b[twindfamily]-1.96*_se[twindfamily]'
    local estu `=_b[twindfamily]+1.96*_se[twindfamily]'
    dis "country is `c', 95% CI is [`estl',`estu']"

    qui replace countryName = "`c'" in `iter'
    qui replace heightEst   = _b[twindfamily] in `iter'
    qui replace heightLB    = `estl' in `iter'
    qui replace heightUB    = `estu' in `iter'

    qui areg educf twindfamily i.fert if country=="`c'", abs(motherage)
    local estl `=_b[twindfamily]-1.96*_se[twindfamily]'
    local estu `=_b[twindfamily]+1.96*_se[twindfamily]'
    dis "country is `c', educ 95% CI is [`estl',`estu']"

    qui replace educEst   = _b[twindfamily] in `iter'
    qui replace educLB    = `estl' in `iter'
    qui replace educUB    = `estu' in `iter'

    local ++iter
}
dis "Number of countries: `iter'"

keep in 1/`iter'
keep countryName heightEst heightLB heightUB educEst educLB educUB
outsheet using "$OUT/countryEstimates.csv", comma replace
*/

********************************************************************************
*** (3) Make Graph
********************************************************************************
insheet using "$OUT/countryEstimates.csv", comma names
gsort -heightest
gen numb = _n


encode countryname, gen(cc)
#delimit ;
eclplot heightest heightlb heightub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Height Difference (cm)" "twin - non-twin")
xlabel(1 "Guyana" 2 "Brazil" 3 "Maldives" 4 "Sao Tome" 5 "Azerbaijan" 6 "CAR"
       7 "Albania" 8 "Guatemala" 9 "Dom. Rep." 10 "Ghana" 11 "Mozambiqu" 12
       "Kyrgyz Rep." 13 "Colombia" 14 "Honduras" 15 "Burundi" 16 "Sierra Leone"
       17 "DRC" 18 "Gabon" 19 "Ethiopia" 20 "Namibia" 21 "Jordan" 22 "Nepal" 23
       "Lesotho" 24 "Peru" 25 "Bolivia" 26 "Malawi" 27 "Togo" 28 "Turkey" 29
       "Uganda" 30 "Moldova" 31 "Congo Brazzaville" 32 "Kazakhstan" 33 "Rwanda"
       34 "Senegal" 35 "Swaziland" 36 "Cameroon" 37 "Kenya" 38 "Morocco" 39
       "Egypt" 40 "Armenia" 41 "Nicaragua" 42 "Burkina Faso" 43 "India" 44
       "Nigeria" 45 "Haiti" 46 "Mali" 47 "Tanzania" 48 "Niger" 49 "Madagascar"
       50 "Cote D'Ivoire" 51 "Bangladesh" 52 "Comoros" 53 "Zambia" 54 "Chad"
       55 "Liberia" 56 "Guinea" 57 "Zimbabwe" 58 "Benin" 59 "Cambodia" 60
       "Uzbekistan"
       ,angle(65) labsize(vsmall))
;
#delimit cr
graph export "$GRA/HeightDif.eps", as(eps) replace


drop numb
gsort -educest
gen numb = _n
#delimit ;
eclplot educest educlb educub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Education Difference (years)" "twin - non-twin")
xlabel(1 "Nigeria" 2 "Cameroon" 3 "India" 4 "Ghana" 5 "Peru" 6 "Bolivia"
       7 "Burundi" 8 "Egypt" 9 "Guyana" 10 "Jordan" 11 "Kenya" 12 "Colombia"
       13 "Dom. Rep." 14 "Malawi" 15 "Tanzania" 16 "Armenia" 17 "DRC" 18
       "Madagascar" 19 "Gabon" 20 "Honduras" 21 "Turkey" 22 "Bangladesh"
       23 "Maldives" 24 "Nepal" 25 "Azerbaijan" 26 "Zimbabwe" 27 "Moldova"
       28 "Albania" 29 "Uganda" 30 "Nicaragua" 31 "CAR" 32 "Mozambique" 33
       "Uzbekistan" 34 "Sao Tome" 35 "Haiti" 36 "Benin" 37 "Togo" 38 "Zambia"
       39 "Cambodia" 40 "Congo Brazzaville" 41 "Guatemala" 42 "Brazil" 43
       "Ethiopia" 44 "Comoros" 45 "Rwanda" 46 "Namibia" 47 "Cote D'Ivoire"
       48 "Senegal" 49 "Niger" 50  "Kazakhstan" 51 "Mali" 52 "Burkina Faso"
       53 "Morocco" 54 "Chad" 55 "Swaziland" 56 "Lesotho" 57 "Sierra Leone"
       58 "Guinea" 59 "Liberia" 60 "Kyrgyz Republic"
       ,angle(65) labsize(vsmall))
;
#delimit cr
graph export "$GRA/EducDif.eps", as(eps) replace
