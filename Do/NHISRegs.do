/* NHISRegs.do v0.00             damiancclarke             yyyy-mm-dd:2014-10-25
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes processed data from the generating script NHISPrep.do and runs
OLS, IV and bounds analysis of the effect of fertility on child quality.  Speci-
fications are as similar as possible to DHS twin regressions. The twin 2sls reg-
ressions (the main regression of interest), take the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Running only with NHIS from 2004-2013 (2003 and earlier are diff)
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/NCIS"
global OUT "~/investigacion/Activa/Twins/Results/Outreg/NHIS"
global LOG "~/investigacion/Activa/Twins/Log"
global GRA "~/investigacion/Activa/Twins/Figures"

cap mkdir $OUT
log using "$LOG/NHISRegs.txt", text replace

local yvars EducationZscore excellentHealth  
local age   ageFirstBirth motherAge motherAge2
local base  B_* childSex
local H     H_* `age' smoke* heightMiss
local SH    S_* `H' 
local tcon  i.surveyYear i.motherRace i.region `age'

local wt    pw=sWeight
local se    cluster(motherID)

local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) /*
*/ stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)

local sum     0
local balance 0
local twin    0
local ols     0
local ivs     1
local conley  0
local gend    0
local trend   0

********************************************************************************
*** (2) Append cleaned files, generate indicators
********************************************************************************
append using "$DAT/NHIS2011" "$DAT/NHIS2012" "$DAT/NHIS2013" "$DAT/NHIS2014"
append using "$DAT/NHIS2007" "$DAT/NHIS2008" "$DAT/NHIS2009" "$DAT/NHIS2010" 
append using                 "$DAT/NHIS2004" "$DAT/NHIS2005" "$DAT/NHIS2006" 

gen childHealth=childHealthStatus if childHealthStatus<=5
gen excellentHealth=childHealthStatus==1

foreach zVar in Education Health {
    bys ageInterview: egen mE=mean(child`zVar')
    bys ageInterview: egen sd=sd(child`zVar')
    gen `zVar'Zscore=(child`zVar'-mE)/sd
    drop mE sd
}
*replace childHealthPrivate=0 if childHealthPrivate==2

tab surveyYear,   gen(B_Syear)
tab ageInterview, gen(B_Bdate)
tab region,       gen(B_region)
tab motherRace,   gen(B_mrace)
*tab childRace,    gen(B_crace)


tab motherHealthStatus, gen(H_mhealth)
drop H_mhealth6
drop H_mhealth7
drop H_mhealth8
*replace motherHeight=. if motherHeight==0

gen mGoodHealth   =motherHealthStatus==1|motherHealthStatus==2
gen mPoorHealth   =motherHealthStatus==4|motherHealthStatus==5
gen mMissingHealth=motherHealthStatus==6|motherHealthStatus==7
gen H_mheight=motherHeight
gen H_mheight2=motherHeight^2

*gen S_meduc=motherEducation
*gen S_meduc2=motherEducation^2

gen bmi2=bmi^2

gen mEduc=motherEducation
replace mEduc=12 if motherEducation==13
replace mEduc=12 if motherEducation==14
replace mEduc=14 if motherEducation>=15
gen fEduc = 6 if fatherEduc == 1
replace fEduc = 11 if fatherEduc == 2
replace fEduc = 12 if fatherEduc == 3
replace fEduc = 13 if fatherEduc == 4
replace fEduc = 14 if fatherEduc >= 6
tab mEduc, gen(S_Meduc)




gen BMI=bmi if bmi<99
gen BMI185=bmi<18.5
replace BMI185=. if bmi>99
gen motherExcellentHealth=motherHealthStatus==1

********************************************************************************
*** (3) Summary
********************************************************************************
if `sum'==1 {

    local motherStat fert motherAge mEduc BMI BMI185 motherExcellentHealth
    local childStat  excellentHealth childEducation EducationZscore

    preserve
    collapse `motherStat' twinfamily, by(surveyYear hhx fmx)
    replace twinfamily=round(twinfamily)
    estpost tabstat `motherStat', by(twinfamily) statistics(mean sd) listwise /*
    */ columns(statistics)
    esttab using "$OUT/Mother.txt", replace main(mean) aux(sd) nostar unstack /*
    */ noobs nonote nomtitle nonumber
    restore
    estpost tabstat `childStat', by(twin) statistics(mean sd) listwise /*
    */ columns(statistics)
    esttab using "$OUT/Child.txt", replace main(mean) aux(sd) nostar unstack /*
    */ noobs nonote nomtitle nonumber

    sum twin
    sum bord if twin==1
    count if fpx=="01"
    count if fpx=="01"&twinfamily==1
    count if fpx=="01"&twinfamily==0
    count
    count if twin==1
    count if twin==0    
}

********************************************************************************
*** (4a) Balance table
********************************************************************************
if `balance'==1 {
    preserve
    local bal mEduc fEduc BMI BMI185 smokePrePreg motherHeight
    #delimit ;
    local names `" "Mother Education" "Father Education" "Mother BMI"
                   "Mother is underweight" "Mother Smokes (pre-pregnancy)"
                   "Mother Height" "';    
    #delimit cr
    tokenize `bal'
    replace motherAge = motherAge - childAge
    collapse `bal' twinfamily motherAge fert B_mrace* [`wt'], by(surveyYear hhx fmx)
    replace twinfamily   =round(twinfamily)
    replace motherAge    =round(motherAge)
    replace fert         =round(fert)
    gen     white        = B_mrace1>0
    gen     black        = B_mrace2>0
    gen     hispanic     = B_mrace4>0
    gen     other        = hispanic==0&black==0&white==0
    
    gen T=twinfamily
    keep if motherAge>17&motherAge<50

    gen varname    = ""
    gen twinAve    = .
    gen notwinAve  = .
    gen difference = .
    gen diffSe     = .
    gen star       = ""
    local iter = 1
    foreach var of local names {
        reg ``iter'' T i.fert i.motherAge white hispanic other
        replace varname      = "`var'" in `iter'
        replace twinAve      = _b[T]+_b[_cons] in `iter'
        replace notwinAve    = _b[_cons] in `iter'
        replace difference   = _b[T] in `iter'
        replace diffSe       = _se[T] in `iter'
        replace star = "*"   in `iter' if abs(_b[T]/_se[T])>1.646 
        replace star = "**"  in `iter' if abs(_b[T]/_se[T])>1.962 
        replace star = "***" in `iter' if abs(_b[T]/_se[T])>2.581 
        local ++iter
    }
       
    keep in 1/6
    foreach var of varlist twinAve notwinAve difference diffSe {
        gen str5 tvar = string(`var', "%05.3f")
        drop `var'
        gen `var' = tvar
        drop tvar
    }

    keep varname twinAve notwinAve difference diffSe star
    order varname twinAve notwinAve difference star diffSe

    outsheet using "$OUT/BalanceAll.txt", delimiter("&") replace noquote        
    restore    
    
    foreach num in two three four {        
        preserve
        replace motherAge = motherAge - childAge
        keep if `num'_plus

        gen Treated = twin_`num'_fam>0

        gen varname    = ""
        gen twinAve    = .
        gen notwinAve  = .
        gen difference = .
        gen diffSe     = .
        gen star       = ""


        local iter = 1
        foreach var of local names {
            reg ``iter'' Treated i.fert i.motherAge
            replace varname      = "`var'" in `iter'
            replace twinAve      = _b[Treated]+_b[_cons] in `iter'
            replace notwinAve    = _b[_cons] in `iter'
            replace difference   = _b[Treated] in `iter'
            replace diffSe       = _se[Treated] in `iter'
            replace star = "*"   in `iter' if abs(_b[Treated]/_se[Treated])>1.646 
            replace star = "**"  in `iter' if abs(_b[Treated]/_se[Treated])>1.962 
            replace star = "***" in `iter' if abs(_b[Treated]/_se[Treated])>2.581 
            local ++iter
        }
       
        keep in 1/6
        foreach var of varlist twinAve notwinAve difference diffSe {
            gen str5 tvar = string(`var', "%05.3f")
            drop `var'
            gen `var' = tvar
            drop tvar
        }

        keep varname twinAve notwinAve difference diffSe star
        order varname twinAve notwinAve difference star diffSe

        outsheet using "$OUT/Balance`num'.txt", delimiter("&") replace noquote        
        restore
    }
}


********************************************************************************
*** (4b) Twin Regression
********************************************************************************
if `twin'==1 {
gen twin100=twin*100

reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) replace
reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss if childYearBirth<=1989
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) append
reg twin100 H_mheight S_meduc* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss if childYearBirth>1989
outreg2 `age' H_* S_* bmi using "$OUT/NHIStwin.tex", tex(pr) append
reg twin100 H_mheight S_meduc* smoke* i.motherRac i.region motherAge* /*
*/ ageFirstBirth i.surveyYear bmi heightMiss
outreg2 `age' H_* S_* bmi smoke* using "$OUT/NHIStwin.tex", tex(pr) append

exit

*reg twin100 H_mheight S_meduc smoke* i.motherRac i.region motherAge* /*
**/ ageFirstBirth i.surveyYear bmi heightMiss mGood mPoor mMissing
*outreg2 `age' H_* S_* smoke* bmi m*  using "$OUT/NHIStwin.xls", excel append
}

********************************************************************************
*** (5) OLS regressions
********************************************************************************
if `ols'==1 {
    foreach y of varlist `yvars' {

*        eststo: reg `y' `base' `SH'  fert [`wt']             , `se'
*        eststo: reg `y' `base' `H'   fert [`wt'] if e(sample), `se'
*        eststo: reg `y' `base'       fert [`wt'] if e(sample), `se'
        
*        estout est3 est2 est1 using "$OUT/OLSAll`y'.xls", replace `estopt' /*
*        */ keep(fert `SH')
*        estimates clear

        local j = 1
        foreach f in two three four {
            preserve
            keep if `f'_plus==1
            eststo: reg `y' fert `base' `SH' [`wt']
            keep if e(sample)==1
            local maxR = e(r2)*1.5
            psacalc fert delta, mcontrol(`base') rmax(`maxR')
            estadd scalar Ost = `r(output)': est`j'
            local ++j
            
            eststo: reg `y' fert `base' `H'  [`wt'] 
            local maxR = e(r2)*1.5
            psacalc fert delta, mcontrol(`base') rmax(`maxR')
            estadd scalar Ost = `r(output)': est`j'
            local ++j
            eststo: reg `y' fert `base'      [`wt']
            local ++j
            restore
        }
        local estimates est3 est2 est1 est6 est5 est4 est9 est8 est7
        #delimit ;
        estout `estimates' using "$OUT/OLSFert`y'.txt", replace
        cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) stats
        (r2 N Ost, fmt(%9.2f %9.0g %9.3f)) keep(fert `SH') 
        starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
        #delimit cr
        estimates clear
    }
}

********************************************************************************
*** (6a) IV regressions
********************************************************************************
if `ivs'==1 {
    foreach y of varlist `yvars' {
        foreach f in two three four {
            local F`f'
            preserve
            keep if `f'_plus==1
            #delimit ;
            eststo: ivreg2 `y' `base' `SH' (fert=twin_`f'_fam) [`wt'],
            `se' first ffirst savefirst savefp(`f's) partial(`base');
            keep if e(sample);
            mat first=e(first);
            estadd scalar KPF=first[8,1]: `f'sfert;
            estadd scalar KPp=first[7,1]: `f'sfert;
            
            eststo: ivreg2 `y' `base' `H' (fert=twin_`f'_fam) [`wt'],
            `se' first ffirst savefirst savefp(`f'h) partial(`base');
            mat first=e(first);
            estadd scalar KPF=first[8,1]: `f'hfert;
            estadd scalar KPp=first[7,1]: `f'hfert;
            
            eststo: ivreg2 `y' `base' (fert=twin_`f'_fam) [`wt'],
            `se' first ffirst savefirst savefp(`f'b) partial(`base');
            mat first=e(first);
            estadd scalar KPF=first[8,1]: `f'bfert;
            estadd scalar KPp=first[7,1]: `f'bfert;
            restore;
            #delimit cr
        }
        local ests est3 est2 est1 est6 est5 est4 est9 est8 est7
        local fs  twobfert twohfert twosfert threebfert threehfert  /*
        */ threesfert fourbfert fourhfert foursfert
        estout `ests' using "$OUT/IVFert`y'.txt", replace `estopt' keep(fert `SH')
        #delimit ;
        estout `fs' using "$OUT/IVFert`y'_first.txt", replace keep(twin* `SH')
        cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par))
        stats (N KPF KPp, fmt(%9.0g %9.2f %9.3f))
        starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
        #delimit cr
        estimates clear
    }
}
exit
********************************************************************************
*** (6b) Plausibly exogenous bounds
********************************************************************************
if `conley'==1 {
    gen j=_n
    merge 1:1 j using $OUT/../../gamma/gammas.dta
    mat ConleyBounds = J(6,4,.)
    local i = 1
        foreach y of varlist `yvars' {
        foreach f in two three four {
            preserve
            keep if `f'_plus==1

            qui reg `y' `base'
            predict Ey, resid
            qui reg fert `base'
            predict Ex, resid
            qui reg twin_`f'_fam `base'
            predict Ez, resid
            local ESH
            foreach var of varlist `SH' {
                qui reg `var' `base'
                predict E`var', resid
                local ESH `ESH' E`var'
            }
            
            plausexog uci `y' `base' `SH' (fert=twin_`f'_fam) [`wt'], /*
            */ vce(robust) gmin(0) gmax(0.0124) grid(2) level(0.90)
            mat ConleyBounds[`i',1]=e(lb_fert)
            mat ConleyBounds[`i',2]=e(ub_fert)

            local items 17
            matrix omega_eta = J(`items',`items',0)
            matrix omega_eta[1,1] = 0.0016456^2
            matrix mu_eta = J(`items',1,0)
            matrix mu_eta[1,1] = 0.0062792

            
            plausexog ltz Ey `ESH' (Ex=Ez), distribution(special, gamma) seed(45)
            cap mat ConleyBounds[`i',3]=_b[Ex]-1.65*_se[Ex]
            cap mat ConleyBounds[`i',4]=_b[Ex]+1.65*_se[Ex]

            foreach num of numlist 0(1)5 {
                matrix om`num' = J(`items',`items',0)
                matrix om`num'[1,1] = ((`num'/5)*0.06/sqrt(12))^2
                matrix mu`num' = J(`items',1,0)
                matrix mu`num'[1,1] = (`num'/5)*0.06/2
                local d`num' = (`num'/5)*0.06
            }
            plausexog ltz Ey `ESH' (Ex=Ez), mu(mu_eta) omega(omega_eta)   /*
            */ graphomega(om0 om1 om2 om3 om4 om5)                        /*
            */ graphmu(mu0 mu1 mu2 mu3 mu4 mu5) graph(Ex)                 /*
            */ graphdelta(`d0' `d1' `d2' `d3' `d4' `d5')
            graph export "$OUT/ConleyUSA_`y'_`f'.eps", as(eps) replace
            
            mat list ConleyBounds
            restore
            local ++i
        }
    }
    mat rownames ConleyBounds = TwoE ThreeE FourE TwoH ThreeH FourH 
    mat colnames ConleyBounds = LowerBound UpperBound LowerBound UpperBound
    mat2txt, matrix(ConleyBounds) saving("$OUT/ConleyGammaNHIS.txt")      /*
    */ format(%6.4f) replace
}


********************************************************************************
*** (7) IV regressions by gender
********************************************************************************
if `gend'==1 {
    cap mkdir "$OUT/Gender"
    tab H_mheight, gen(HH_)
    foreach gend of numlist 1 2 {
	foreach y of varlist  `yvars' {
            foreach f in two three four {
                preserve
                keep if childSex==`gend'&`f'_plus==1
                #delimit ;
                eststo: ivreg29 `y' `base' `age' smoke* heightMiss HH_* S_*
                (fert=twin_`f'_fam) [`wt'], `se' first ffirst savefirst
                savefp(`f'a) partial(`base');

                eststo: ivreg29 `y' `base' `SH' (fert=twin_`f'_fam) [`wt'],
                `se' first ffirst savefirst savefp(`f's) partial(`base');
                
                dis "`f' base";
                dis _b[fert];
                dis _b[fert]/_se[fert];
                
                eststo: ivreg29 `y' `base' `H' (fert=twin_`f'_fam) if e(sample)
                [`wt'], `se' first ffirst savefirst savefp(`f'h) partial(`base');
                dis "`f' H";
                dis _b[fert];
                dis _b[fert]/_se[fert];

                eststo: ivreg29 `y' `base' (fert=twin_`f'_fam) if e(sample)
                [`wt'], `se' first ffirst savefirst savefp(`f'b) partial(`base');
                dis "`f' SH";
                dis _b[fert];
                dis _b[fert]/_se[fert];
                restore;
                #delimit cr
            }
            #delimit ;
            local estimates est4 est3 est2 est1 est8 est7 est6 est5 est12 est11 est10 est9;
            local fstage twobfert twohfert twosfert twoafert threebfert threehfert
            threesfert threeafert fourbfert fourhfert foursfert fourafert;
            estout `estimates' using "$OUT/Gender/IVFert`y'G`gend'.xls", replace
            `estopt' keep(fert `SH');
            estout `fstage'    using "$OUT/Gender/IVFert`y'1G`gend'.xls", replace
            `estopt' keep(twin* `SH');
            estimates clear;
            #delimit cr
	}
    }
}


********************************************************************************
*** (8) Global trends from various data sources (USA)
********************************************************************************
if `trend'==1 {
    use "$DAT/../IPUMS/IPUMS20012013", clear
    keep if age>25&sex==2
    gen educyrs     = 0  if educ==0
    replace educyrs = 2  if educ==1
    replace educyrs = 6  if educ==2
    replace educyrs = 9  if educ==3
    replace educyrs = 10 if educ==4
    replace educyrs = 11 if educ==5
    replace educyrs = 12 if educ==6
    replace educyrs = 13 if educ==7
    replace educyrs = 14 if educ==8
    replace educyrs = 16 if educ==10
    replace educyrs = 17 if educ==11

    collapse educyrs [pw=perwt], by(birthyr)
    replace birthyr = birthyr + 25
    rename birthyr year
    tempfile censusEduc
    save `censusEduc'

    wbopendata, country(USA) indicator(SP.DYN.TFRT.IN) long clear
    merge 1:1 year using `censusEduc'

    rename sp_dyn_tfrt_in Fertility
    lab var Fertility "Fertility per Woman (World Bank)"
    lab var educyrs   "Average Years of Education (ACS)"
    keep if year>=1960&year<2014

    #delimit ; twoway line educyrs year, yaxis(1) lpattern(longdash)
    lwidth(medthick) lcolor(black) ytitle("Average Years of Education
    (ACS)" " ", axis(1)) || line Fertility year, yaxis(2)
    lcolor(black) lpattern(style) legend(label(1 "Average Years of
    Education") label(2 "Fertility per Woman")) scheme(s1mono); graph
    export "$GRA/USTrends.eps", as(eps) replace; #delimit cr
}
