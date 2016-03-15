/* worldTwins.do v0.00           damiancclarke             yyyy-mm-dd:2015-10-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Generate figures to present characteristics of twin and non-twin mothers across
 countries/regions.  It uses nationally representative surveys or administrative
 records of births.  Data comes from:
   Albania: DHS
   Armenia: DHS
   Kenya  : DHS
   USA    : Administrative data (NVSS)

 Pre-23/12/2015 included data on US fetal deaths.  Roll back to this date to use
 it.
*/

vers 11
clear all
set more off
cap log close
set maxvar 20000

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
use "$DAT/DHS_twins"

keep if _merge==3
keep if motherage>17&motherage<50
gen normalweight = bmi>=18.5&bmi<30

replace height = . if height>240
replace height = . if height<70
replace bmi    = . if bmi > 50
replace educf  = . if educf >27
exit
tab twind if height!=.&bmi!=.&educf!=.
levelsof country, local(cc)
/*



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

keep if height!=. & bmi!=.

replace twind100 = twind*100
bys v001 _year: egen prenateDoctorC = mean(prenate_doc)
bys v001 _year: egen prenateNurseC  = mean(prenate_nurse)
bys v001 _year: egen prenateNoneC   = mean(prenate_none)

local cs i.agemay 
local se abs(country) cluster(id)

tab twind100

lab var height  "Mother's Height (cm)"
lab var bmi     "Mother's BMI"
lab var educf   "Mother's Education"

local ovar height bmi educf prenateDoctorC prenateNurseC prenateNoneC
*areg twind100 `ovar' `cs' if Africa==1, `se'
*outreg2 `ovar' using "$REG/DHSGlobal.xls", excel label ctitle("Africa") replace
*areg twind100 `ovar' `cs' if LatAm ==1, `se'
*outreg2 `ovar' using "$REG/DHSGlobal.xls", excel label ctitle("Latin America")
*areg twind100 `ovar' `cs' if Europe==1|Asia==1, `se'
*outreg2 `ovar' using "$REG/DHSGlobal.xls", excel label ctitle("Europe/Asia")
areg twind100 `ovar' `cs', `se'
*outreg2 `ovar' using "$REG/DHSGlobal.xls", excel label ctitle("All")
local nobs = e(N)

local counter = 1
gen countryname  = ""
gen varname      = ""
gen observations = .
foreach newvar in beta se uCI lCI {
    gen `newvar'_sd =.
    gen `newvar'_u  =.
}

dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `ovar' {
    replace countryname = "DHS"   in `counter'
    replace varname     = "`var'" in `counter'
    replace observations= `nobs'  in `counter'
    qui sum `var'
    local betasd    = round((_b[`var']*r(sd))*1000)/1000
    replace beta_sd = `betasd' in `counter'
    
    local se_sd     = round((_se[`var']*r(sd))*1000)/1000
    replace se_sd   = `se_sd' in `counter'
    
    local uCIsd    = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace uCI_sd = `uCIsd' in `counter'
    
    local lCIsd    = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace lCI_sd = `lCIsd' in `counter'
    
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"    
    local ++counter
}

local counte2 = 1
foreach var of varlist `ovar' {
    areg twind100 `var' `cs', `se'
    local bU = round((_b[`var'])*1000)/1000 
    local sU = round((_se[`var'])*1000)/1000
    local uC = round((`bU'+invttail(`nobs',0.025)*`sU')*1000)/1000
    local lC = round((`bU'-invttail(`nobs',0.025)*`sU')*1000)/1000
    replace beta_u = `bU' in `counte2'
    replace se_u   = `sU' in `counte2'
    replace uCI_u  = `uC' in `counte2'
    replace lCI_u  = `lC' in `counte2'
    local ++counte2
}

outsheet countryname varname beta_sd se_sd uCI_sd lCI_sd beta_u se_u uCI_u lCI_u /*
*/ in 1/`counter' using "$REG/worldEstimatesDHS.csv", delimit(";") replace

exit
*/
gen countryName = ""
gen surveyYear  = .
foreach var in height underweight educf {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .

    gen `var'EstNoFE = .
    gen `var'LBNoFE  = .
    gen `var'UBNoFE  = .

    gen `var'Est_SD  = .
    gen `var'LB_SD   = .
    gen `var'UB_SD   = .
}
gen twinProp = .
destring _year, gen(yearint)

local iter = 1
foreach c of local cc {
    if `"`c'"'=="Indonesia"|`"`c'"'=="Pakistan"|`"`c'"'=="Paraguay"      exit
    if `"`c'"'=="Philippines"|`"`c'"'=="South-Africa"|`"`c'"'=="Ukraine" exit
    if `"`c'"'=="Vietnam"|`"`c'"'=="Yemen" exit

    qui replace countryName = "`c'" in `iter'
    sum twind [aw=sweight] if country == "`c'"
    replace twinProp = `r(mean)' if countryName == "`c'"
    sum yearint [aw=sweight] if country == "`c'"
    replace surveyYear = `r(mean)' if countryName == "`c'"
    
    foreach var in height underweight educf {
        qui areg `var' twindfamily i.fert if country=="`c'", abs(motherage)
        local estl `=_b[twindfamily]-1.96*_se[twindfamily]'
        local estu `=_b[twindfamily]+1.96*_se[twindfamily]'
        dis "country is `c', 95% CI for `var' is [`estl',`estu']"
        
        qui replace `var'Est   = _b[twindfamily] in `iter'
        qui replace `var'LB    = `estl' in `iter'
        qui replace `var'UB    = `estu' in `iter'

        qui sum `var'
        local betasd   = round((_b[twindfamily]/r(sd))*1000)/1000
        replace `var'Est_SD = `betasd' in `iter'
        local se_sd   = round((_se[twindfamily]/r(sd))*1000)/1000
        local uCIsd   = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
        replace `var'UB_SD = `betasd'+invttail(`nobs',0.025)*`se_sd' in `iter'
        local lCIsd   = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
        replace `var'LB_SD = `betasd'-invttail(`nobs',0.025)*`se_sd' in `iter'
    }
    local ++iter
}
dis "Number of countries: `iter'"

keep in 1/`iter'
keep countryName heightEst heightLB heightUB educfEst educfLB educfUB         /*
*/ underweightEst underweightLB underweightUB heightEst_SD heightLB_SD        /*
*/ heightUB_SD educfEst_SD educfLB_SD educfUB_SD underweightEst_SD            /*
*/ underweightLB_SD underweightUB_SD twinProp surveyYear
outsheet using "$OUT/countryEstimates.csv", comma replace
exit

********************************************************************************
*** (3a) USA regressions with IVF
********************************************************************************
set seed 543
foreach year of numlist 2009(1)2013 {
    use "$USA/natl`year'", clear
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
    gen gestation=estgest if estgest>19 & estgest<46
    gen birthweight = dbwt if dbwt<6500&dbwt>500
    gen year = `year'
    
    tempfile t`year'
    gen bin=runiform()
    tab twin if ART==0
    keep if bin>0.90
    save `t`year''
}

clear
append using `t2009' `t2010' `t2011' `t2012' `t2013'
count
#delimit ;
local usvars heightcm meduc smoke0 smoke1 smoke2 smoke3 diabetes gestDiab
             eclampsia hypertens pregHyper married;
#delimit cr

tab twin
tab twin if ART==0


lab var heightcm "Mother's height (cm)"
lab var meduc    "Mother's education (years)"
lab var smoke0   "Mother Smoked Before Pregnancy"
lab var smoke1   "Mother Smoked in 1st Trimester" 
lab var smoke2   "Mother Smoked in 2nd Trimester" 
lab var smoke3   "Mother Smoked in 3rd Trimester" 
lab var diabet   "Mother had pre-pregnancy diabetes"
lab var gestDia  "Mother had gestational diabetes"
lab var eclampsi "Mother had eclampsia"
lab var hyperten "Mother had pre-pregnancy hypertension"
lab var pregHyp  "Mother had pregnancy-associated hypertension"
lab var married  "Mother is married"

local FEs i.mbrace i.lbo_rec i.year i.gestation
dis "Twin Regressions: Pooled"
areg twin100 `usvars' `FEs', abs(mager) robust
outreg2 `usvars' using "$REG/USregsGestFE.xls", label excel replace
gen tsample = 1 if e(sample)==1
local nobs = e(N)

dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `usvars' {
    qui sum `var'
    local betasd = round((_b[`var']*r(sd))*1000)/1000
    local se_sd  = round((_se[`var']*r(sd))*1000)/1000
    local uCIsd  = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    local lCIsd  = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"
}


tab twin100 if infert==0
areg twin100 `usvars' `FEs' if infert==0, abs(mager) robust
gen Esample = e(sample)
outreg2 `usvars' using "$REG/USregsGestFE.xls", label excel append
local nobs = e(N)

local counter = 1
gen countryname  = ""
gen varname      = ""
gen observations = `nobs'
foreach newvar in beta se uCI lCI  {
    gen `newvar'_sd = .
    gen `newvar'_u  = .
}

dis "Non-Infertility Users"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `usvars' {
    replace countryname = "USA"   in `counter'
    replace varname     = "`var'" in `counter'
    qui sum `var'
    local betasd    = round((_b[`var']*r(sd))*1000)/1000
    replace beta_sd = `betasd' in `counter'
    
    local se_sd     = round((_se[`var']*r(sd))*1000)/1000
    replace se_sd   = `se_sd' in `counter'
    
    local uCIsd = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace uCI_sd  = `uCIsd' in `counter'
    
    local lCIsd = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace lCI_sd  = `lCIsd' in `counter'
    
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"
    local ++counter
}

local counte2 = 1
foreach var of varlist `usvars' {
    areg twin100 `var' `FEs' if Esample == 1, abs(mager) robust
    local bU = round((_b[`var'])*1000)/1000 
    local sU = round((_se[`var'])*1000)/1000
    local uC = round((`bU'+invttail(`nobs',0.025)*`sU')*1000)/1000
    local lC = round((`bU'-invttail(`nobs',0.025)*`sU')*1000)/1000
    replace beta_u = `bU' in `counte2'
    replace se_u   = `sU' in `counte2'
    replace uCI_u  = `uC' in `counte2'
    replace lCI_u  = `lC' in `counte2'
    local ++counte2
}

outsheet countryname varname beta_sd se_sd uCI_sd lCI_sd beta_u se_u uCI_u lCI_u /*
*/ in 1/`counter' using "$REG/worldEstimates.csv", delimit(";") replace

exit

areg twin100 `usvars' `FEs' if infert==1, abs(mager) robust
outreg2 `usvars' using "$REG/USregsGestFE.xls", label excel append
local nobs = e(N)
dis "Infertility Users"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `usvars' {
    qui sum `var'
    local betasd = round((_b[`var']*r(sd))*1000)/1000
    local se_sd  = round((_se[`var']*r(sd))*1000)/1000
    local uCIsd  = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    local lCIsd  = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"
}

dis "Conditional T-tests"
dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `usvars' {
    qui areg twin100 `var' i.lbo_rec i.gestation if tsample==1, abs(mager) robust
    qui outreg2 `var' using "$REG/USttestFE.xls", label excel
    qui sum `var'
    local betasd = round((_b[`var']*r(sd))*1000)/1000
    local se_sd  = round((_se[`var']*r(sd))*1000)/1000
    local uCIsd  = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    local lCIsd  = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"
    
    qui reg twin100 `var' if tsample==1, robust
    qui outreg2 `var' using "$REG/USttest.xls", label excel
}
*/
********************************************************************************
*** (4) Chile Regressions
********************************************************************************
use "$DAT/Chile_twins"
#delimit ;
local base    indigenous;
local region  i.region i.age rural i.m_age_birth i.birthorder;
local cond    a16==13&m_age_birth<=45;
local wt      [pw=fexp_enc];
local prePreg obesePre lowWeightPre;
local preg    pregDiab pregDepr pregSmoked pregDrugsModerate pregDrugsHigh
              pregAlcoholModerate pregAlcoholHigh pregHosp;
#delimit cr

gen twind = twin*100

eststo: reg twind `region' `prePreg' `preg' `base' `wt' if `cond' 
keep if e(sample)==1
local nobs = e(N)

tab twind
exit

local counter = 1
gen countryname  = ""
gen varname      = ""
gen observations = .
foreach newvar in beta se uCI lCI {
    gen `newvar'_sd =.
    gen `newvar'_u  =.
}

dis "varname;beta;sd;lower-bound;upper-bound;N"
foreach var of varlist `prePreg' `preg' {
    replace countryname = "Chile"   in `counter'
    replace varname     = "`var'" in `counter'
    replace observations= `nobs'  in `counter'
    qui sum `var'
    local betasd    = round((_b[`var']*r(sd))*1000)/1000
    replace beta_sd = `betasd' in `counter'
    
    local se_sd     = round((_se[`var']*r(sd))*1000)/1000
    replace se_sd   = `se_sd' in `counter'
    
    local uCIsd    = round((`betasd'+invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace uCI_sd = `uCIsd' in `counter'
    
    local lCIsd    = round((`betasd'-invttail(`nobs',0.025)*`se_sd')*1000)/1000
    replace lCI_sd = `lCIsd' in `counter'
    
    dis "`var';`betasd';`se_sd';`lCIsd';`uCIsd';`nobs'"    
    local ++counter
}

local counte2 = 1
foreach var of varlist `prePreg' `preg' {
    reg twind `var' `region' `base' `wt'
    local bU = round((_b[`var'])*1000)/1000 
    local sU = round((_se[`var'])*1000)/1000
    local uC = round((`bU'+invttail(`nobs',0.025)*`sU')*1000)/1000
    local lC = round((`bU'-invttail(`nobs',0.025)*`sU')*1000)/1000
    replace beta_u = `bU' in `counte2'
    replace se_u   = `sU' in `counte2'
    replace uCI_u  = `uC' in `counte2'
    replace lCI_u  = `lC' in `counte2'
    local ++counte2
}

outsheet countryname varname beta_sd se_sd uCI_sd lCI_sd beta_u se_u uCI_u lCI_u /*
*/ in 1/`counter' using "$REG/worldEstimatesChile.csv", delimit(";") replace



exit
********************************************************************************
*** (5) Figures
********************************************************************************
use "$DAT/GDPpc_WorldBank", clear
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
encode regioncode, gen(rc)
gen rcode = rc
rename heightest heightEst
rename educfest educfEst
rename underweightest underweightEst
rename twinprop twinProp
local outvars heightEst educfEst underweightEst twinProp logGDP rcode
outsheet `outvars' using "$OUT/countryEstimatesGDP.csv", comma replace

format heightEst      %9.2f
format heightlb       %9.2f
format heightub       %9.2f
format educfEst       %9.2f
format educflb        %9.2f
format educfub        %9.2f
format underweightEst %9.2f
format underweightlb  %9.2f
format underweightub  %9.2f
format logGDP         %9.2f


#delimit ;
eclplot heightEst heightlb heightub numb, scheme(s1mono) estopts(mcolor(black))
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
gsort -educfEst
gen numb = _n
#delimit ;
eclplot educfEst educflb educfub numb, scheme(s1mono) estopts(mcolor(black))
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

drop numb
gsort underweightEst
gen numb = _n
#delimit ;
eclplot underweightEst underweightlb underweightub numb, scheme(s1mono)
estopts(mcolor(black))ciopts(lcolor(black)) yline(0, lcolor(red))
xtitle(" ") ytitle("Difference in Proportion Underweight" "twin - non-twin")
xlabel(1 "Chad" 2 "Bangladesh" 3 "Cambodia" 4 "India" 5 "Brazil" 6 "Ghana"
       7 "Nepal" 8 "Uzbekistan" 9 "Nigeria" 10 "Comoros" 11 "Liberia" 12
       "Kenya" 13 "Madagascar" 14 "Tanzania" 15 "Zimbabwe" 16 "Niger" 17
       "Cameroon" 18 "Benin" 19 "Uganda" 20 "Mali" 21 "Azerbaijan" 22 "Guatemala" 
       23 "Morocco" 24 "Burundi" 25 "Haiti" 26 "DRC" 27 "Nicaragua" 28 "Togo"
       29 "Namibia" 30 "Dominican Republic" 31 "Zambia" 32 "Jordan" 33 "Guinea"
       34 "Bolivia" 35 "Colombia" 36 "Peru" 37 "Turkey" 38 "Egypt" 39 "Armenia"
       40 "Mozambique" 41 "Senegal" 42 "Lesotho" 43 "Rwanda" 44 "Malawi" 45
       "Congo Brazzaville" 46 "CAR" 47 "Cote D'Ivoire" 48 "Gabon" 49 "Albania"
       50 "Burkina Faso" 51 "Moldova" 52 "Honduras" 53 "Kazakhstan" 54 "Swaziland"
       55 "Guyana" 56 "Sao Tome and Principe" 57 "Ethiopia" 58 "Maldives" 59
       "Kyrgyz Republic" 60 "Sierra Leone"
       ,angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/UnderweightDif.eps", as(eps) replace



#delimit ;
scatter heightEst logGDP  [w=twinProp], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Height Difference (cm)" "twin - non-twin");
graph export "$GRA/HeightGDP.eps", as(eps) replace;

scatter educfEst logGDP  [w=twinProp], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Education Difference (years)" "twin - non-twin");
graph export "$GRA/EducGDP.eps", as(eps) replace;

scatter underweightEst logGDP  [w=twinProp], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Difference in Pr(underweight)" "twin - non-twin");
graph export "$GRA/UnderweightGDP.eps", as(eps) replace;


scatter heightE logG [w=twinP] if regionc=="EAS", msymbol(O) mcolor(lavender) ||
scatter heightE logG [w=twinP] if regionc=="ECS", msymbol(O) mcolor(sandb)    ||
scatter heightE logG [w=twinP] if regionc=="LCN", msymbol(O) mcolor(mint)     ||
scatter heightE logG [w=twinP] if regionc=="MEA", msymbol(O) mcolor(navy)     ||
scatter heightE logG [w=twinP] if regionc=="SAS", msymbol(O) mcolor(magenta)  ||
scatter heightE logG [w=twinP] if regionc=="SSF", msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa"))
ytitle("Height Difference (cm)" "twin - non-twin")
xtitle("log(GDP per capita)");
graph export "$GRA/HeightGDPregion.eps", as(eps) replace;
#delimit cr

corr educfEst   logGDP
corr heightEst logGDP
corr educfEst   ny_gdp
corr heightEst ny_gdp

expand 6
sort countryname region
replace heightEst=. if mod(_n,6) > 0
replace educfEst=.   if mod(_n,6) > 0
replace underweightEst=. if mod(_n,6) > 0

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
scatter heightE logG [w=twinP] if regionN==1, msymbol(O) mcolor(lavender) ||
scatter heightE logG [w=twinP] if regionN==2, msymbol(O) mcolor(sandb)    ||
scatter heightE logG [w=twinP] if regionN==3, msymbol(O) mcolor(mint)     ||
scatter heightE logG [w=twinP] if regionN==4, msymbol(O) mcolor(navy)     ||
scatter heightE logG [w=twinP] if regionN==5, msymbol(O) mcolor(magenta)  ||
scatter heightE logG [w=twinP] if regionN==6, msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa")) scheme(lean1)
yline(0, lcolor(red)) ytitle("Height Difference (cm)" "twin - non-twin")
xtitle("log(GDP per capita)");
graph export "$GRA/HeightGDPregionW.eps", as(eps) replace;


scatter educfEst logG [w=twinP] if regionN==1, msymbol(O) mcolor(lavender) ||
scatter educfEst logG [w=twinP] if regionN==2, msymbol(O) mcolor(sandb)    ||
scatter educfEst logG [w=twinP] if regionN==3, msymbol(O) mcolor(mint)     ||
scatter educfEst logG [w=twinP] if regionN==4, msymbol(O) mcolor(navy)     ||
scatter educfEst logG [w=twinP] if regionN==5, msymbol(O) mcolor(magenta)  ||
scatter educfEst logG [w=twinP] if regionN==6, msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa")) scheme(lean1)
yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Education Difference (years)" "twin - non-twin");
graph export "$GRA/EducGDPregionW.eps", as(eps) replace;


scatter underweightEst logG [w=twinP] if regionN==1, msymbol(O) mcolor(lavender) ||
scatter underweightEst logG [w=twinP] if regionN==2, msymbol(O) mcolor(sandb)    ||
scatter underweightEst logG [w=twinP] if regionN==3, msymbol(O) mcolor(mint)     ||
scatter underweightEst logG [w=twinP] if regionN==4, msymbol(O) mcolor(navy)     ||
scatter underweightEst logG [w=twinP] if regionN==5, msymbol(O) mcolor(magenta)  ||
scatter underweightEst logG [w=twinP] if regionN==6, msymbol(O) mcolor(ebblue)
legend(lab(1 "East Asia") lab(2 "Europe") lab(3 "Lat Am") lab(4 "MENA")
       lab(5 "South Asia") lab(6 "Sub Saharan Africa")) scheme(lean1)
yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Difference in Pr(underweight)" "twin - non-twin");
graph export "$GRA/UnderweightGDPregionW.eps", as(eps) replace;
#delimit cr
*/

********************************************************************************
*** (6) Coverage
********************************************************************************
use "$DAT/world/world"
#delimit ;
drop if NAME=="Aruba"|NAME=="Aland"|NAME=="American Samoa"|NAME=="Antarctica";
drop if NAME=="Ashmore and Cartier Is."|NAME=="Fr. S. Antarctic Lands";
drop if NAME=="Bajo Nuevo Bank (Petrel Is.)"|NAME=="Clipperton I.";
drop if NAME=="Cyprus U.N. Buffer Zone"|NAME=="Cook Is."|NAME=="Coral Sea Is.";
drop if NAME=="Cayman Is."|NAME=="N. Cyprus"|NAME=="Dhekelia"|NAME=="Falkland Is.";
drop if NAME=="Faeroe Is."|NAME=="Micronesia"|NAME=="Guernsey";
drop if NAME=="Heard I. and McDonald Is."|NAME=="Isle of Man"|NAME=="Indian Ocean Ter.";
drop if NAME=="Br. Indian Ocean Ter."|NAME=="Baikonur"|NAME=="Siachen Glacier";
drop if NAME=="St. Kitts and Nevis"|NAME=="Saint Lucia"|NAME=="St-Martin";
drop if NAME=="Marshall Is."|NAME=="N. Mariana Is."|NAME=="New Caledonia";
drop if NAME=="Norfolk Island"|NAME=="Niue"|NAME=="Nauru"|NAME=="Pitcairn Is.";
drop if NAME=="Spratly Is."|NAME=="Fr. Polynesia"|NAME=="Scarborough Reef";
drop if NAME=="Serranilla Bank"|NAME=="S. Geo. and S. Sandw. Is."|NAME=="San Marino";
drop if NAME=="St. Pierre and Miquelon"|NAME=="Sint Maarten"|NAME=="Seychelles";
drop if NAME=="Turks and Caicos Is."|NAME=="U.S. Minor Outlying Is.";
drop if NAME=="St. Vin. and Gren."|NAME=="British Virgin Is.";
drop if NAME=="USNB Guantanamo Bay"|NAME=="Wallis and Futuna Is."|NAME=="Akrotiri";
drop if NAME=="Antigua and Barb."|NAME=="Bermuda"|NAME=="Kiribati"|NAME=="St-Barthélemy";
drop if NAME=="Curaçao"|NAME=="Dominica"|NAME=="Guam";
drop if NAME=="Malta"|NAME=="Montserrat"|NAME=="Palau"|NAME=="Mauritius";
drop if NAME=="Tonga"|NAME=="Trinidad and Tobago";
drop if NAME=="Tuvalu"|NAME=="U.S. Virgin Is."|NAME=="Vanuatu";

generat coverage=3 if NAME=="Albania"|NAME=="Azerbaijan"|NAME=="Armenia";
replace coverage=3 if NAME=="Brazil"|NAME=="Bolivia"|NAME=="Burundi";
replace coverage=3 if NAME=="Burkina Faso"|NAME=="Benin"|NAME=="Bangladesh";
replace coverage=3 if NAME=="Central African Rep."|NAME=="Colombia"|NAME=="Chad";
replace coverage=3 if NAME=="Comoros"|NAME=="Cambodia"|NAME=="Côte d'Ivoire";
replace coverage=3 if NAME=="Cameroon"|NAME=="Congo"|NAME=="Dem. Rep. Congo";
replace coverage=3 if NAME=="Dominican Rep."|NAME=="Egypt"|NAME=="Ethiopia";
replace coverage=3 if NAME=="Kyrgyzstan"|NAME=="Kazakhstan"|NAME=="Jordan";
replace coverage=3 if NAME=="Guatemala"|NAME=="Ghana"|NAME=="Gabon"|NAME=="Guinea";
replace coverage=3 if NAME=="Honduras"|NAME=="Haiti"|NAME=="Guyana"|NAME=="India";
replace coverage=3 if NAME=="Lesotho"|NAME=="Liberia"|NAME=="Mali"|NAME=="Malawi";
replace coverage=3 if NAME=="Maldives"|NAME=="Mozambique"|NAME=="Moldova";
replace coverage=3 if NAME=="Morocco"|NAME=="Madagascar"|NAME=="Nicaragua";
replace coverage=3 if NAME=="Namibia"|NAME=="Nepal"|NAME=="Nigeria"|NAME=="Niger";
replace coverage=3 if NAME=="Peru"|NAME=="Rwanda"|NAME=="Sierra Leone";
replace coverage=3 if NAME=="São Tomé and Principe"|NAME=="Swaziland";
replace coverage=3 if NAME=="Senegal"|NAME=="Togo"|NAME=="Turkey"|NAME=="Tanzania"; 
replace coverage=3 if NAME=="Uganda"|NAME=="Uzbekistan"|NAME=="Zambia";
replace coverage=3 if NAME=="Zimbabwe"|NAME=="Kenya";

replace coverage=1 if NAME=="United States"|NAME=="Sweden";
replace coverage=2 if NAME=="United Kingdom";
replace coverage=4 if NAME=="Chile";
replace coverage=5 if NAME=="Spain"|NAME=="Mexico"|NAME=="Ireland";
replace coverage=6 if NAME=="Romania";

spmap coverage using "$DAT/world/world_coords" , id(_ID) osize(vvthin)
fcolor(Rainbow) clmethod(unique) clbreaks(0 1 2 3 4 5 6)
legend(title("Twin Coverage", size(*0.5) bexpand justification(left)))
legend(label(1 "No Surveys")) legend(label(2 "Full Birth Records"))
legend(label(3 "Surveys (Regional)")) legend(label(4 "Surveys (Demographic)"))
legend(label(5 "Surveys (Early Life)"))
legend(label(6 "Birth Records (No Health Information)"))
legend(label(7 "Survey Data (No Health Information)"));

graph export "$GRA/coverage.eps", as(eps) replace;


#delimit cr




