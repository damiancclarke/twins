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
use "$DAT/GDPpc_WorldBank"
keep if year==2013
tempfile GDP
save `GDP', replace

insheet using "$OUT/countryEstimates.csv", comma names clear
gsort -heightest
gen numb = _n
encode countryname, gen(cc)

replace countryname=subinstr(countryname, "-", " ", .)
replace countryname= "Congo, Dem. Rep." if countryname == "Congo Democratic Republic"
replace countryname= "Congo, Rep." if countryname == "Congo Brazzaville"
replace countryname= "Cote d'Ivoire" if countryname == "Cote d Ivoire"
replace countryname= "Egypt, Arab Rep." if countryname == "Egypt"
merge 1:1 countryname using `GDP'
keep if _merge==3
gen logGDP = log(ny_gdp_pcap_cd)


format heightest %9.2f
format heightlb  %9.2f
format heightub  %9.2f
format educest   %9.2f
format educlb    %9.2f
format educub    %9.2f
format logGDP    %9.2f


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
       ,angle(65) labsize(vsmall));
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
       ,angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/EducDif.eps", as(eps) replace

#delimit ;
scatter heightest logGDP  [w=sp_pop_totl], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Height Difference (cm)" "twin - non-twin");
graph export "$GRA/HeightGDP.eps", as(eps) replace;

scatter educest logGDP  [w=sp_pop_totl], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Education Difference (years)" "twin - non-twin");
graph export "$GRA/EducGDP.eps", as(eps) replace;



scatter heighte logG [w=sp_] if regionc=="EAS", msymbol(O) mcolor(lavender) ||
scatter heighte logG [w=sp_] if regionc=="ECS", msymbol(O) mcolor(sandb)    ||
scatter heighte logG [w=sp_] if regionc=="LCN", msymbol(O) mcolor(mint)     ||
scatter heighte logG [w=sp_] if regionc=="MEA", msymbol(O) mcolor(navy)     ||
scatter heighte logG [w=sp_] if regionc=="SAS", msymbol(O) mcolor(magenta)  ||
scatter heighte logG [w=sp_] if regionc=="SSF", msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa"))
ytitle("Height Difference (cm)" "twin - non-twin")
xtitle("log(GDP per capita)");
graph export "$GRA/HeightGDPregion.eps", as(eps) replace;
#delimit cr

corr educest   logGDP
corr heightest logGDP
corr educest   ny_gdp
corr heightest ny_gdp

expand 6
sort countryname region
replace heightest=. if mod(_n,6) > 0
replace educest=.   if mod(_n,6) > 0

gen     regionNum = 1 if regionc=="EAS"
replace regionNum = 2 if regionc=="ECS"
replace regionNum = 3 if regionc=="LCN"
replace regionNum = 4 if regionc=="MEA"
replace regionNum = 5 if regionc=="SAS"
replace regionNum = 6 if regionc=="SSF"


recode regionN (1=2) (2=3) (3=4) (4=5) (5=6) (6=1) if mod(_n,6) == 1
recode regionN (1=3) (2=4) (3=5) (4=6) (5=1) (6=2) if mod(_n,6) == 2
recode regionN (1=4) (2=5) (3=6) (4=1) (5=2) (6=3) if mod(_n,6) == 3
recode regionN (1=5) (2=6) (3=1) (4=2) (5=3) (6=4) if mod(_n,6) == 4
recode regionN (1=6) (2=1) (3=2) (4=3) (5=4) (6=5) if mod(_n,6) == 5

#delimit ;
scatter heighte logG [w=sp_] if regionN==1, msymbol(O) mcolor(lavender) ||
scatter heighte logG [w=sp_] if regionN==2, msymbol(O) mcolor(sandb)    ||
scatter heighte logG [w=sp_] if regionN==3, msymbol(O) mcolor(mint)     ||
scatter heighte logG [w=sp_] if regionN==4, msymbol(O) mcolor(navy)     ||
scatter heighte logG [w=sp_] if regionN==5, msymbol(O) mcolor(magenta)  ||
scatter heighte logG [w=sp_] if regionN==6, msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa")) scheme(lean1)
yline(0, lcolor(red)) ytitle("Height Difference (cm)" "twin - non-twin")
xtitle("log(GDP per capita)");
graph export "$GRA/HeightGDPregionW.eps", as(eps) replace;


scatter educest logG [w=sp_] if regionN==1, msymbol(O) mcolor(lavender) ||
scatter educest logG [w=sp_] if regionN==2, msymbol(O) mcolor(sandb)    ||
scatter educest logG [w=sp_] if regionN==3, msymbol(O) mcolor(mint)     ||
scatter educest logG [w=sp_] if regionN==4, msymbol(O) mcolor(navy)     ||
scatter educest logG [w=sp_] if regionN==5, msymbol(O) mcolor(magenta)  ||
scatter educest logG [w=sp_] if regionN==6, msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa")) scheme(lean1)
yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Education Difference (years)" "twin - non-twin");
graph export "$GRA/EducGDPregionW.eps", as(eps) replace;
#delimit cr



**scatter heightest logGDP [w=sp_pop_totl], msymbol(circle_hollow)
**scheme(lean1) yline(0, lcolor(red))
**|| scatter heightest logGDP, ms(i) mlab(cc) mlabpos(c) mlabsize(vsmall)
**mlabcol(gs6) legend(off);
**graph export "$GRA/HeightGDPlabelled.eps", as(eps) replace;
**
