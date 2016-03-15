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

/*
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

tab twind if height!=.&bmi!=.&educf!=.
levelsof country, local(cc)




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


gen countryName = ""
gen surveyYear  = .
foreach var in height educf {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .

    bys country: egen Mean = mean(`var')
    bys country: egen SDev = sd(`var')
    gen `var'_std = (`var'-Mean)/SDev
    drop Mean SDev
}
foreach var in height_std educf_std {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .
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
    
    foreach var in height educf height_std educf_std {
        qui areg `var' twindfamily i.fert if country=="`c'", abs(motherage)
        local nobs  = e(N)
        local estl `=_b[twindfamily]-invttail(`nobs',0.025)*_se[twindfamily]'
        local estu `=_b[twindfamily]+invttail(`nobs',0.025)*_se[twindfamily]'
        dis "country is `c', 95% CI for `var' is [`estl',`estu']"
        
        qui replace `var'Est   = _b[twindfamily] in `iter'
        qui replace `var'LB    = `estl' in `iter'
        qui replace `var'UB    = `estu' in `iter'
    }
    local ++iter
}
dis "Number of countries: `iter'"

keep in 1/`iter'
keep countryName heightEst heightLB heightUB educfEst educfLB educfUB         /*
*/ height_stdEst height_stdLB height_stdUB educf_stdEst educf_stdLB           /*
*/ educf_stdUB twinProp surveyYear
outsheet using "$OUT/countryEstimates.csv", comma replace


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

keep if infert == 0

gen countryName = "USA"
gen surveyYear  = 2011
rename heightcm height
rename meduc    educf

foreach var in height educf {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .

    egen Mean = mean(`var')
    egen SDev = sd(`var')
    gen `var'_std = (`var'-Mean)/SDev
    drop Mean SDev
}
foreach var in height_std educf_std {
    gen `var'Est     = .
    gen `var'LB      = .
    gen `var'UB      = .
}
gen twinProp = .
gen twind = twin100/100

gen yearint = 2011

sum twind 
replace twinProp = `r(mean)' 
gen fert = lbo_rec
foreach var in height educf height_std educf_std {
    qui areg `var' twind i.fert, abs(mager)
    local nobs  = e(N)
    local estl `=_b[twind]-invttail(`nobs',0.025)*_se[twind]'
    local estu `=_b[twind]+invttail(`nobs',0.025)*_se[twind]'
    dis "95% CI for `var' is [`estl',`estu']"
        
    qui replace `var'Est   = _b[twind] in 1
    qui replace `var'LB    = `estl'    in 1
    qui replace `var'UB    = `estu'    in 1
}

keep in 1
keep countryName heightEst heightLB heightUB educfEst educfLB educfUB         /*
*/ height_stdEst height_stdLB height_stdUB educf_stdEst educf_stdLB           /*
*/ educf_stdUB twinProp surveyYear
outsheet using "$OUT/countryEstimates2.csv", comma replace


********************************************************************************
*** (4) Chile Regressions
********************************************************************************
use "$DAT/Chile_twins", clear
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



*/
********************************************************************************
*** (5) Figures
********************************************************************************
use "$DAT/GDPpc_WorldBank", clear
keep if year==2013
tempfile GDP
save `GDP', replace

insheet using "$OUT/countryEstimates2.csv", comma names clear
tempfile USA
save `USA', replace

insheet using "$OUT/countryEstimates.csv", comma names clear
append  using  `USA'

gsort -heightest
gen numb = _n
encode countryname, gen(cc)
drop if cc==.

replace countryname=subinstr(countryname, "-", " ", .)
replace countryname= "Congo, Dem. Rep." if countryname == "Congo Democratic Republic"
replace countryname= "United States"    if countryname == "USA"
replace countryname= "Congo, Rep."      if countryname == "Congo Brazzaville"
replace countryname= "Cote d'Ivoire"    if countryname == "Cote d Ivoire"
replace countryname= "Egypt, Arab Rep." if countryname == "Egypt"
merge 1:1 countryname using `GDP'
keep if _merge==3
gen logGDP = log(ny_gdp_pcap_cd)
encode regioncode, gen(rc)
gen rcode = rc
rename heightest heightEst
rename educfest educfEst
rename height_stdest height_stdEst
rename educf_stdest  educf_stdEst
rename twinprop twinProp
local outvars heightEst educfEst height_stdEst educf_stdEst twinProp logGDP rcode
outsheet `outvars' using "$OUT/countryEstimatesGDP.csv", comma replace

format heightEst      %9.2f
format heightlb       %9.2f
format heightub       %9.2f
format educfEst       %9.2f
format educflb        %9.2f
format educfub        %9.2f
format logGDP         %9.2f

#delimit ;
eclplot heightEst heightlb heightub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Height Difference (cm)" "twin - non-twin")
xlabel(1 "Guyana" 2 "Brazil" 3 "Maldives" 4 "Sao Tome" 5 "Azerbaijan" 6 "CAR"
       7 "Albania" 8 "Guatemala" 9 "Dom. Rep." 10 "Ghana" 11 "USA" 12 "Mozambique"
       13 "Kyrgyz Rep." 14 "Colombia" 15 "Honduras" 16 "Burundi" 17 "Sierra Leone"
       18 "DRC" 19 "Gabon" 20 "Ethiopia" 21 "Namibia" 22 "Jordan" 23 "Nepal" 24
       "Lesotho" 25 "Peru" 26 "Bolivia" 27 "Malawi" 28 "Togo" 29 "Turkey" 30
       "Uganda" 31 "Moldova" 32 "Congo Brazzaville" 33 "Kazakhstan" 34 "Rwanda"
       35 "Senegal" 36 "Swaziland" 37 "Cameroon" 38 "Kenya" 39 "Morocco" 40
       "Egypt" 41 "Armenia" 42 "Nicaragua" 43 "Burkina Faso" 44 "India" 45
       "Nigeria" 46 "Haiti" 47 "Mali" 48 "Tanzania" 49 "Niger" 50 "Madagascar"
       51 "Cote D'Ivoire" 52 "Bangladesh" 53 "Comoros" 54 "Zambia" 55 "Chad"
       56 "Liberia" 57 "Guinea" 58 "Zimbabwe" 59 "Benin" 60 "Cambodia" 61
       "Uzbekistan",angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/HeightDif.eps", as(eps) replace

drop numb
gsort -height_stdEst
gen numb = _n
#delimit ;
eclplot height_stdEst height_stdlb height_stdub numb, scheme(s1mono)
estopts(mcolor(black)) ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Standardised Height Difference (cm)" "twin - non-twin")
xlabel(1  "Brazil"       2  "Guyana"         3  "Maldives"     4  "Azerbaijan"
       5  "Guatemala"    6  "CAR"            7  "Kyrgyz Rep."  8  "Albania"   
       9  "Dom. Rep."    10 "Mozambique"     11 "Sao Tome"     12 "Ghana"  
       13 "Colombia"     14 "Honduras"       15 "USA"          16 "Burundi" 
       17 "Nepal"        18 "Gabon"          19 "Peru"         20 "Ethiopia"
       21 "Jordan"       22 "Bolivia"        23 "DRC"          24 "Turkey"    
       25 "Malawi"       26 "Lesotho"        27 "Togo"         28 "Namibia"
       29 "Moldova"      30 "Kazakhstan"     31 "Uganda"       32 "Rwanda"
       33 "Swaziland"    34 "Congo Rep."     35 "Armenia"      36 "Egypt"    
       37 "Morocco"      38 "Cameroon"       39 "Sierra Leone" 40 "India"
       41 "Nicaragua"    42 "Burkina Faso"   43 "Haiti"        44 "Kenya"  
       45 "Senegal"      46 "Mali"           47 "Niger"        48 "Tanzania"
       49 "Madagascar"   50 "Bangladesh"    51 "Cote D'Ivoire" 52 "Nigeria"
       53 "Comoros"      54 "Zambia"         55 "Chad"         56 "Liberia"
       57 "Guinea"       58 "Zimbabwe"       59 "Benin" 
       60 "Cambodia"     61 "Uzbekistan"
       ,angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/HeightStdDif.eps", as(eps) replace


drop numb
gsort -educfEst
gen numb = _n
#delimit ;
eclplot educfEst educflb educfub numb, scheme(s1mono) estopts(mcolor(black))
ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Education Difference (years)" "twin - non-twin")
xlabel(1 "Cameroon" 2 "Nigeria" 3 "India" 4 "Ghana" 5 "Peru" 6 "Bolivia"
       7 "Burundi" 8 "Egypt" 9 "Guyana" 10 "Jordan" 11 "Kenya" 12 "Colombia"
       13 "Dom. Rep." 14 "Malawi" 15 "Gabon" 16 "Tanzania" 17 "Maldives" 18
       "Honduras" 19 "Bangladesh" 20 "Turkey" 21 "Nepal" 22 "Zimbabwe" 23
       "Azerbaijan" 24 "Moldova" 25 "Albania" 26 "Armenia" 27 "Uganda" 28
       "Nicaragua" 29 "CAR" 30 "Madagascar" 31 "Mozambique" 32 "Haiti" 33
       "Uzbekistan" 34 "Brazil" 35 "Sao Tome" 36 "Togo" 37 "Cambodia" 38
       "Zambia" 39 "Congo Brazzaville" 40 "USA" 41 "Guatemala" 42 "Ethiopia"
       43 "Benin" 44 "Comoros" 45 "DRC" 46 "Rwanda" 47 "Namibia" 48
       "Cote D'Ivoire" 49 "Senegal" 50 "Niger" 51 "Mali" 52 "Kazakhstan" 53
       "Burkina Faso" 54 "Liberia" 55 "Chad" 56 "Morocco" 57 "Swaziland" 58
       "Lesotho" 59 "Guinea" 60 "Sierra Leone" 61 "Kyrgyz Rep."    
       ,angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/EducDif.eps", as(eps) replace

drop numb
gsort -educf_stdEst
gen numb = _n
#delimit ;
eclplot educf_stdEst educf_stdlb educf_stdub numb, scheme(s1mono)
estopts(mcolor(black)) ciopts(lcolor(black)) yline(0, lcolor(red)) xtitle(" ")
ytitle("Standardised Education Difference (years)" "twin - non-twin")
xlabel(1  "Cameroon"     2  "Burundi"        3  "Nigeria"    4  "Guyana"
       5  "Peru"         6  "India"          7  "Moldova"    8  "Azerbaijan"
       9  "Ghana"        10 "Albania"        11 "Kenya"      12 "Bolivia"
       13 "Uzbekistan"   14 "Armenia"        15 "Malawi"     16 "Gabon"
       17 "Colombia"     18  "Nepal"         19 "USA"        20 "Tanzania"
       21 "Jordan"       22 "Turkey"         23 "Bangladesh" 24 "Dom. Rep."
       25 "Honduras"     26 "Zimbabwe"       27 "Maldives"   28 "Egypt"
       29 "CAR"          30 "Sao Tome"       31 "Mozambique" 32 "Togo"
       33 "Uganda"       34 "Cambodia"       35 "Madagascar" 36 "Nicaragua"
       37 "Ethiopia"     38 "Benin"          39 "Haiti"      40 "Zambia"
       41 "Guatemala"    42 "Congo Republic" 43 "Comoros"    44 "Brazil"
       45 "Rwanda"       46 "Kazakhstan"     47 "Mali"       48 "Niger"
       49 "DRC"          50 "Cote D'Ivoire"  51 "Senegal"    52 "Namibia"
       53 "Burkina Faso" 54 "Chad"           55 "Liberia"    56 "Morocco"
       57 "Swaziland"    58 "Lesotho"        59 "Guinea"
       60 "Sierra Leone" 61 "Kyrgyz Rep."     
       ,angle(65) labsize(vsmall));
#delimit cr
graph export "$GRA/EducStdDif.eps", as(eps) replace


#delimit ;
scatter heightEst logGDP  [w=twinProp], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Height Difference (cm)" "twin - non-twin");
graph export "$GRA/HeightGDP.eps", as(eps) replace;

scatter educfEst logGDP  [w=twinProp], msymbol(circle_hollow)
scheme(lean1) yline(0, lcolor(red)) xtitle("log(GDP per capita)")
ytitle("Education Difference (years)" "twin - non-twin");
graph export "$GRA/EducGDP.eps", as(eps) replace;

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

reg educfEst      ny_gdp_pcap_cd
reg educf_stdEst  ny_gdp_pcap_cd
reg heightEst     ny_gdp_pcap_cd
reg height_stdEst ny_gdp_pcap_cd

exit
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




