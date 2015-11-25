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
set maxvar 10000

********************************************************************************
*** (1) globals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data"
global USA "~/database/NVSS/Births/dta"
global GRA "~/investigacion/Activa/Twins/Figures"
global LOG "~/investigacion/Activa/Twins/Log"
global OUT "~/investigacion/Activa/Twins/Results/Sum"
global REG "~/investigacion/Activa/Twins/Results/World"

log using "$LOG/worldTwins.txt", text replace
cap mkdir "$REG"

********************************************************************************
*** (2) DHS Regressions
********************************************************************************
#delimit ;
local countries Albania Armenia Armenia Armenia Azerbaijan Bangladesh Bangladesh
Bangladesh Bangladesh Bangladesh Bangladesh Benin Benin Benin Benin Bolivia
Bolivia Bolivia Bolivia Bolivia Brazil Brazil Brazil Burkina-Faso Burkina-Faso
Burkina-Faso Burkina-Faso Burundi Burundi Cambodia Cambodia Cambodia Cameroon
Cameroon Cameroon Cameroon Central-African-Republic Chad Chad Colombia Colombia
Colombia Colombia Colombia Colombia Comoros Congo-Brazzaville Congo-Brazzaville
Congo-Brazzaville Congo-Democratic-Republic Cote-d-Ivoire Cote-d-Ivoire
Cote-d-Ivoire Cote-d-Ivoire Dominican-Republic Dominican-Republic
Dominican-Republic Dominican-Republic Dominican-Republic Dominican-Republic
Ecuador Egypt Egypt Egypt Egypt Egypt Egypt El-Salvador Ethiopia Ethiopia
Ethiopia Gabon Gabon Ghana Ghana Ghana Ghana Ghana Guatemala Guatemala Guinea
Guinea Guinea Guyana Guyana Haiti Haiti Haiti Haiti
Honduras Honduras;

local cunique Albania Armenia Azerbaijan Bangladesh Benin Bolivia Brazil
Burkina-Faso Burundi Cambodia Cameroon Central-African-Republic Chad Colombia
Comoros Congo-Brazzaville Congo-Democratic-Republic Cote-d-Ivoire
Dominican-Republic Ecuador Egypt El-Salvador Ethiopia Gabon Ghana Guatemala
Guinea Guyana Haiti Honduras;

local year 2008 2000 2005 2010 2006 1994 1997 2000 2004 2007 2011 1996 2001 2006
 2012 1989 1994 1998 2003 2008 1986 1991 1996 1993 1999 2003 2010 1987 2010 2000
 2005 2010 1991 1998 2004 2011 1994 1997 2004 1986 1990 1995 2000 2005 2010 1996
 2005 2009 2011 2007 1994 1998 2005 2012 1986 1991 1996 1999 2002 2007 1987 1988
 1992 1995 2000 2005 2008 1985 2000 2005 2011 2000 2012 1988 1993 1998 2003 2008
 1987 1995 1999 2005 2012 2005 2009 1994 2000 2006 2012 2005 2011;

local surveys     ALIR50DT AMIR42DT AMIR54DT AMIR61DT AZIR52DT BDIR31DT BDIR3ADT
BDIR41DT BDIR4JDT BDIR51DT BDIR61DT BJIR31DT BJIR41DT BJIR51DT BJIR61DT BOIR01DT
BOIR31DT BOIR3BDT BOIR41DT BOIR51DT BRIR01DT BRIR21DT BRIR31DT BFIR21DT BFIR31DT
BFIR43DT BFIR61DT BUIR01DT BUIR61DT KHIR42DT KHIR51DT KHIR61DT CMIR22DT CMIR31DT
CMIR44DT CMIR60DT CFIR31DT TDIR31DT TDIR41DT COIR01DT COIR22DT COIR31DT COIR41DT
COIR53DT COIR61DT KMIR32DT CGIR51DT CGIR5HDT CGIR60DT CDIR50DT CIIR35DT CIIR3ADT
CIIR50DT CIIR61DT DRIR01DT DRIR21DT DRIR32DT DRIR41DT DRIR4ADT DRIR52DT ECIR01DT
EGIR01DT EGIR21DT EGIR33DT EGIR42DT EGIR51DT EGIR5ADT ESIR00DT ETIR41DT ETIR51DT
ETIR61DT GAIR41DT GAIR60DT GHIR02DT GHIR31DT GHIR41DT GHIR4BDT GHIR5ADT GUIR01DT
GUIR34DT GNIR41DT GNIR52DT GNIR61DT GYIR51DT GYIR51DT HTIR31DT HTIR42DT HTIR52DT
HTIR61DT HNIR52DT HNIR62DT;

#delimit cr

local oldcountry 
local w : word count `countries'
foreach i of numlist 1(1)`w' {
    local cou : word `i' of `countries'
    local yrs : word `i' of `year'
    local sur : word `i' of `surveys'
    local fname subinstr("`cou'", "-","",.)
    local fname `=`fname''
    dis "Fname is `fname'"

    dis "Country:    `cou', old country: `oldcountry'"
    dis "Year/Survey `yrs'/`sur'"
    if `"`cou'"'!=`"`oldcountry'"' {
        use "~/database/DHS/DHS_Data/`cou'/`yrs'/`sur'", clear
        count
        tempfile `fname'
        gen twin  =.
        gen anemia=.
    }
    else {
        append using "~/database/DHS/DHS_Data/`cou'/`yrs'/`sur'", force
    }
    

    foreach num in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
        qui cap replace twin=0 if b0_`num'==0
        qui cap replace twin=1 if b0_`num'==1|b0_`num'==2 
    }
    local se
    qui cap {
        replace anemia=0 if v457==4
        replace anemia=1 if v457==3
        replace anemia=2 if v457==2|v457==1
    }
    save ``fname'', replace
    local oldcountry `cou'
}

foreach c of local cunique {
    dis "`c'"
    local fname subinstr(`c', "-","",.)
    use ``fname''
    reg twin anemia
    
}

exit
/*
********************************************************************************
*** (2) DHS Regressions
********************************************************************************
use "$DAT/DHS_twins"
keep if _merge==3
keep if motherage>17&motherage<50

replace height = . if height>240
replace height = . if height<70
replace bmi    = . if bmi > 50

levelsof country, local(cc)
exit

#delimit ;
gen Africa = country=="Benin"|country=="Burkina-Faso"|country=="Burundi"     |
             country=="Cameroon"|country=="Central-African-Republic"         |
             country=="Chad"|country=="Comoros"|country=="Congo-Brazzaville" |
             country=="Congo-Democratic-Republic"|country=="Cote-d-Ivoire"   |
             country=="Egypt"|country=="Ethiopia"|country=="Gabon"           |
             country=="Ghana"|country=="Guinea"|country=="Kenya"             |
             country=="Lesotho"|country=="Liberia"|country=="Madagascar"     |
             country=="Malawi"|country=="Mali"|country=="Maldives"           |
             country=="Morocco"|country=="Mozambique"|country=="Namibia"     |
             country=="Niger"|country=="Nigeria"|country=="Rwanda"           |
             country=="Sao-Tome-and-Principe"|country=="Senegal"             |
             country=="Sierra-Leone"|country=="South-Africa"                 |
             country=="Swaziland"|country=="Tanzania"|country=="Togo"        |
             country=="Uganda"|country=="Zambia"|country=="Zimbabwe"         ;
gen LatAm  = country=="Bolivia"|country=="Brazil"|country=="Colombia"        |
             country=="Dominican-Republic"|country=="Guyana"|country=="Haiti"|
             country=="Honduras"|country=="Nicaragua"|country=="Peru"        |
             country=="Guatemala"                                            ;
gen Europe = country=="Albania"|country=="Armenia"|country=="Azerbaijan"     |
             country=="Kazakhstan"|country=="Kyrgyz-Republic"                |
             country=="Turkey"|country=="Ukraine"|country=="Uzbekistan"      |
             country=="Jordan"|country=="Yemen"                              ;
gen Asia   = country=="Bangladesh"|country=="Cambodia"|country=="India"      |
             country=="Indonesia"|country=="Pakistan"|country=="Philippines" |
             country=="Vietnam"                                              ;
#delimit cr

replace twind100 = twind*100
local cs i.agemay i.child_yob
local se abs(country) cluster(id)

eststo: areg twind100 height bmi educf `cs' if Africa==1, `se'
eststo: areg twind100 height bmi educf `cs' if LatAm ==1, `se'
eststo: areg twind100 height bmi educf `cs' if Europe==1, `se'
eststo: areg twind100 height bmi educf `cs' if Asia  ==1, `se'

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
*** (3) USA regressions
********************************************************************************
foreach year of numlist 2009(1)2013 {
    use "$USA/natl`year'"
    keep if mager>18&mager<=45
    gen twin     = dplural == 2 if dplural < 3
    gen twin100  = twin*100
    gen heightcm = m_ht_in*2.54 if m_ht_in!=99
    gen smoke0   = cig_0>0 if cig_0<=98
    gen smoke1   = cig_1>0 if cig_1<=98
    gen smoke2   = cig_2>0 if cig_2<=98
    gen smoke3   = cig_3>0 if cig_3<=98
    gen infert   = rf_inftr=="Y" if rf_inftr!="U" & rf_inftr!=""
    gen ART      = rf_artec=="Y" if rf_artec!="U" & rf_artec!=""
    gen fertDrug = rf_fedrg=="Y" if rf_fedrg!="U" & rf_fedrg!=""
    gen diabetes = rf_diab =="Y" if rf_diab !="U" & rf_diab !=""
    gen gestDiab = rf_gest =="Y" if rf_gest !="U" & rf_gest !=""
    gen eclampsia= rf_eclam=="Y" if rf_eclam!="U" & rf_eclam!=""
    gen hypertens= rf_phyp =="Y" if rf_phyp !="U" & rf_phyp !=""
    gen pregHyper= rf_ghyp =="Y" if rf_ghyp !="U" & rf_ghyp !=""
    gen married  = mar==1 if mar!=.
    gen year = `year'
    #delimit ;
    dis "Twin Regressions: `year' (Non-Infertility Users)";
    areg twin100 heightcm meduc smoke* diab gestD eclamp hypertens pregHyp
                 i.mbrace i.lbo_rec if infert==0, abs(mager);
    dis "Twin Regressions: `year' (Infertility Treatment Users)";
    areg twin100 heightcm meduc smoke* diab gestD eclamp hypertens pregHyp
                 i.mbrace i.lbo_rec if infert==1, abs(mager);
    #delimit cr
    tempfile t`year'
    save `t`year''
}

clear
append using `t2009' `t2010' `t2011' `t2012' `t2013'
gen bin=rnormal()
keep if bin>0.7

#delimit ;
local usvars heightcm meduc smoke0 smoke1 smoke2 smoke3 diabetes gestDiab
             eclampsia hypertens pregHyper married;

lab var heightcm "Mother's height (cm)";
lab var meduc    "Mother's education (years)";
lab var smoke0   "Mother Smoked Before Pregnancy";
lab var smoke1   "Mother Smoked in 1st Trimester";
lab var smoke2   "Mother Smoked in 2nd Trimester";
lab var smoke3   "Mother Smoked in 3rd Trimester";
lab var diabet   "Mother had pre-pregnancy diabetes";
lab var gestDia  "Mother had gestational diabetes";
lab var eclampsi "Mother had eclampsia";
lab var hyperten "Mother had pre-pregnancy hypertension";
lab var pregHyp  "Mother had pregnancy-associated hypertension";
lab var married  "Mother is married";

dis "Twin Regressions: Pooled";
areg twin100 `usvars' i.mbrace i.lbo_rec i.year, abs(mager) robust;
outreg2 `usvars' using "$REG/USregs.xls", label excel replace;
gen tsample = 1 if e(sample)==1;

areg twin100 `usvars' i.mbrace i.lbo_rec i.year if infert==0, abs(mager) robust;
outreg2 `usvars' using "$REG/USregs.xls", label excel append;
areg twin100 `usvars' i.mbrace i.lbo_rec i.year if infert==1, abs(mager) robust;
outreg2 `usvars' using "$REG/USregs.xls", label excel append;
#delimit cr

qui areg twin100 `usvars' i.mbrace i.lbo_rec i.year, abs(mager) robust
foreach var of varlist `usvars' {
    areg twin100 `var' i.lbo_rec if tsample==1, abs(mager) robust
    outreg2 `var' using "$REG/USttestFE.xls", label excel
    
    reg twin100 `var' if tsample==1, robust
    outreg2 `var' using "$REG/USttest.xls", label excel
}

exit
********************************************************************************
*** (4) Figures
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
exit
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
