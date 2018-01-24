/* analysisNHIS.do v0.00         damiancclarke             yyyy-mm-dd:2017-11-23
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
   v0.00: Running only with NHIS from 2004-2014 (2003 and earlier are diff)

NOTE TO DAMIAN: An earlier file was called NHIS_Regs which has been cleaned up
and turned into this permanent file. 

*/

vers 11
clear all
set more off
cap log close

foreach ado in ivreg2 plausexog {
    cap which `ado'
    if _rc!=0 ssc install `ado'
}

********************************************************************************
*** (0) Globals and locals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data/NCIS"
global LOG "~/investigacion/Activa/Twins/Log"
global OUT "~/investigacion/Activa/Twins/Results/"

cap mkdir "$OUT/tables"
cap mkdir "$OUT/figures"

log using "$LOG/analysisNHIS.txt", text replace

local yvars EducationZscore excellentHealth  
local age   ageFirstBirth motherAge motherAge2
local base  B_* childSex `age' 
local H     H_* smoke* heightMiss
local SH    S_* `H' 
local tcon  i.surveyYear i.motherRace i.region `age'

* ECONOMETRIC SPECIFICATION
local wt    pw=sWeight
local se    cluster(motherID)

local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) /*
*/ stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)

********************************************************************************
*** (1) Append cleaned files, generate indicators
********************************************************************************
append using "$DAT/NHIS2011" "$DAT/NHIS2012" "$DAT/NHIS2013" "$DAT/NHIS2014"
append using "$DAT/NHIS2007" "$DAT/NHIS2008" "$DAT/NHIS2009" "$DAT/NHIS2010" 
append using                 "$DAT/NHIS2004" "$DAT/NHIS2005" "$DAT/NHIS2006" 

gen childHealth=childHealthStatus if childHealthStatus<=5
gen excellentHealth=childHealthStatus==1

***CHECK THIS
*drop if childAge==18 
foreach zVar in Education Health {
    bys ageInterview: egen mE=mean(child`zVar')
    bys ageInterview: egen sd=sd(child`zVar')
    gen `zVar'Zscore=(child`zVar'-mE)/sd
    drop mE sd
}
tab surveyYear,   gen(B_Syear)
tab ageInterview, gen(B_Bdate)
tab region,       gen(B_region)
tab motherRace,   gen(B_mrace)


tab motherHealthStatus, gen(H_mhealth)
drop H_mhealth6
drop H_mhealth7
drop H_mhealth8

gen mGoodHealth   =motherHealthStatus==1|motherHealthStatus==2
gen mPoorHealth   =motherHealthStatus==4|motherHealthStatus==5
gen mMissingHealth=motherHealthStatus==6|motherHealthStatus==7
gen H_mheight=motherHeight
gen H_mheight2=motherHeight^2
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

foreach num of numlist 2(1)9 {
    gen _bord`num'=bord==`num'
    lab var _bord`num' "Birth Order `num'"
}
gen _bord10=bord>=10
lab var _bord10 "Birth Order $ \geq 10 $"
lab var fert "Fertility"

gen BMI=bmi if bmi<99
gen BMI185=bmi<18.5
replace BMI185=. if bmi>99
gen motherExcellentHealth=motherHealthStatus==1


lab var H_mhealth1 "Excellent Health"
lab var H_mhealth2 "Very good Health"
lab var H_mhealth3 "Good Health"
lab var H_mhealth4 "Fair Health"
lab var H_mhealth5 "Poor Health"
lab var H_mheight  "Mother's Height"
lab var H_mheight2 "Mother's Height Squared"
lab var smokePrePreg "Smoked Prior to Pregnancy"
lab var smokeMissing "No Response to Smoking"

sum two_plus three_plus four_plus
gen n234 = two_plus==0&three_plus==0&four_plus==0
sum n234
/*
exit

********************************************************************************
*** (2) Make Figure 2 panel B: Twins shift fertility distribution outward
********************************************************************************

#delimit ;
twoway kdensity fert if twinfamily==1, bw(1.4) lpattern(dash) 
|| kdensity fert if twinfamily==0, bw(1.4) scheme(s1color) ytitle("Density")
xtitle("total children ever born")
legend(lab(1 "Twin Family") lab(2 "Singleton Family"));
graph export "$OUT/figures/famsizeUS.eps", as(eps) replace;
#delimit cr


********************************************************************************
*** (3) OLS estimates for Table 7 panel B
***     Appendix Table A18
********************************************************************************
gen bound = _n in 1/20
foreach var of varlist EducationZscore excellentHealth {
    gen LB`var'    = .
    gen UB`var'    = .
    gen point`var' = .
}

foreach y of varlist EducationZscore excellentHealth {
    local i = 1
    eststo: reg `y' `base' `SH'  fert        [`wt']             , `se'
    eststo: reg `y' `base' `H'   fert        [`wt'] if e(sample), `se'
    eststo: reg `y' `base'       fert        [`wt'] if e(sample), `se'
    eststo: reg `y' `base' `SH'  fert _bord* [`wt']             , `se'
    eststo: reg `y' `base' `H'   fert _bord* [`wt'] if e(sample), `se'
    eststo: reg `y' `base'       fert _bord* [`wt'] if e(sample), `se'
    eststo: reg `y' `base'            _bord* [`wt'] if e(sample), `se'
    local bd _bord2 _bord3 _bord4 _bord5 _bord6 _bord7 _bord8 _bord9 _bord10
        
    #delimit;
    esttab est3 est2 est1 est7 est6 est5 est4 using
    "$OUT/tables/NHISOLSBord`y'.tex", replace keep(fert `bd') style(tex)
    stats(N, fmt(%9.0gc) label("Observations")) nonotes
    starlevel ("*" 0.10 "**" 0.05 "***" 0.01) b(%-9.3f) se(%-9.3f)
    mgroups("No Birth Order FEs" "Birth Order FEs", pattern(1 0 0 1 0 0 0)
    prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
    mlabels("Base" "+S" "+S+H" "No Fertility" "Base" "+S" "+S+H") booktabs label
    title("OLS Estimates with and without Birth Order Controls (USA)"\label{USb`y'});
    #delimit cr
    estimates clear
    
    local j = 1
    foreach f in two three four {
        preserve
        keep if `f'_plus==1
        eststo: reg `y' fert `base' `SH' [`wt']
        keep if e(sample)==1
        local b3   =  _b[fert]
        local stde = _se[fert] 
        
        eststo: reg `y' fert `base' `H'  [`wt'] 
        eststo: reg `y' fert `base'      [`wt']
        
        local b1 = _b[fert]
        local AltonjiR = `b3'/(`b1'-`b3')
        estadd scalar Altonji = `AltonjiR': est`j'
        restore
        local j = `j'+3
        
        replace point`y' = `b3' if bound == `i'
        replace LB`y'    = `b3'-invnormal(0.975)*`stde' if bound == `i'
        replace UB`y'    = `b3'+invnormal(0.975)*`stde' if bound == `i'
        local i = `i'+7
    }
    #delimit ;
    esttab est3 est2 est1 est6 est5 est4 est9 est8 est7 using
    "$OUT/tables/NHISOLS`y'.tex", keep(fert) noline
    b(%-9.3f) se(%-9.3f) starlevel("*" 0.10 "**" 0.05 "***" 0.01)
    stats(N r2 Altonji, fmt(%9.0gc %5.3f %5.3f)
          label("Observations" "R-Squared" "Altonji et al.\ Ratio"))
    label nonotes mlabels(, none) nonumbers style(tex) fragment replace;
    #delimit cr
    estimates clear
}
exit

********************************************************************************
*** (4) IV estimates for Table 9
********************************************************************************
local c1 `base'
local c2 `base' `H'
local c3 `base' `SH'
local x   fert

foreach y of varlist EducationZscore excellentHealth {
    local ests1
    local ests2
    local ecnt = 1

    local i = 2
    foreach f in two three four {
        preserve
        keep if `f'_plus==1
        egen keeper = rowmiss(`y' `base' `SH' fert twin_`f'_fam)
        keep if keeper==0
        gen Twins = twin_`f'_fam

        local p partial(`base') savefirst
        local z Twins

        foreach e of numlist 1(1)3 {
            eststo: ivreg2 `y' `c`e'' (`x'=`z') [`wt'], `se' `p' savefp(f`ecnt')
            local beta`e' =  _b[`x']
            local stde`e' = _se[`x']
            local ests2 `ests2' est`ecnt'
            local ests1 `ests1' f`ecnt'fert
            mat first=e(first)
            estadd scalar KPF=first[8,1]: f`ecnt'fert
            estadd scalar KPp=first[7,1]: f`ecnt'fert

            **Generate residuals for equality of coefficient tests
            foreach var in x y z {
                reg ``var'' `c`e'' [`wt']
                predict `var'res`e', resid
            }
            if `e'!=1 {
                #delimit ;
                gmm (eq1: yres1-{b1}*xres1-{b0}) (eq2: yres`e'-{c1}*xres`e'-{c0})
                [`wt'], instruments(eq1: zres1) instruments(eq2: zres`e')
                onestep winitial(unadjusted, indep) vce(cluster motherID);
                #delimit cr
                test ([b1]_cons = [c1]_cons)
                estadd scalar c = r(p): est`ecnt'
            }
            local ++ecnt    
        }
        restore
        foreach e of numlist 1(1)3 {
            replace point`y' = `beta`e'' if bound == `i'
            replace LB`y'    = `beta`e''-invnormal(0.975)*`stde`e'' if bound == `i'
            replace UB`y'    = `beta`e''+invnormal(0.975)*`stde`e'' if bound == `i'
            local ++i
        }
        local i = `i'+4
    }
    #delimit ;
    esttab `ests2' using "$OUT/tables/NHISIV`y'.tex", keep(fert)
    b(%-9.3f) se(%-9.3f) starlevel("*" 0.10 "**" 0.05 "***" 0.01)
    stats(N c, fmt(%9.0gc %5.3f) label("Observations" "Coefficient Difference"))
    label nonotes mlabels(, none) nonumbers style(tex) fragment replace noline;

    gen Twins = .;
    esttab `ests1' using "$OUT/tables/NHISIV`y'_first.tex", b(%-9.3f) se(%-9.3f)
    keep(Twins) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)
    stats(KPF KPp, fmt(%9.2f %9.3f)
          label("Kleibergen-Paap rk statistic" "p-value of rk statistic"))
    label nonotes mlabels(, none) nonumbers style(tex) fragment replace noline;
    drop Twins;
    
    esttab est2 est3 est5 est6 est8 est9 using "$OUT/tables/NHISIV_full`y'.tex",
    keep(fert H_* smoke*) b(%-9.3f) se(%-9.3f) label mlabels(, none) style(tex)
    nonumbers starlevel("*" 0.10 "**" 0.05 "***" 0.01) nonotes fragment noline
    stats(N r2, fmt(%9.0gc %5.3f) label("\\ Observations" "R-Squared")) replace;
    #delimit cr
    estimates clear
}
exit


*******************************************************************************
*** (5) Nevo Rosen bounds
*******************************************************************************
local vname "School Z-Score"
foreach y of varlist EducationZscore excellentHealth {
    local i = 5
    foreach n in two three four {
        preserve
        keep if `n'_plus==1
        replace twin_`n'_fam = - twin_`n'_fam
        
        local z twin_`n'_fam
        local c cluster motherID
        
        imperfectiv_dc `y' `base' `SH' (fert=`z') [`wt'], ncorr vce(`c') vverbose
        matrix LRbounds = e(LRbounds)
        local LB = LRbounds[1,1]
        local UB = LRbounds[1,4]
        local LBshort = string(`LB', "%5.4f")
        local UBshort = string(`UB', "%5.4f")
        local p`n' "[`LBshort', `UBshort']"
        local N`n' = string(e(N),"%9.0gc")
        restore

        replace LB`y' = `LB' if bound == `i'
        replace UB`y' = `UB' if bound == `i'
        local i = `i'+7
    }
    file open NRfile using "$OUT/tables/NevoRosenNHIS`y'.tex", write replace
    file write NRfile "`vname'&`ptwo'&`pthree'&`pfour'\\"   _n
    file write NRfile "95\% CI End Points&&&\\"   _n
    file write NRfile "Observations&`Ntwo'&`Nthree'&`Nfour'\\"   _n
    file close NRfile
    local vname "Excellent Health"
}
exit

********************************************************************************
*** (6) Plausibly Exogenous bounds
********************************************************************************
foreach y of varlist EducationZscore excellentHealth {
    local i = 6
    foreach f in two three four {
        preserve
        keep if `f'_plus==1
        gen j=_n
        merge 1:1 j using "$DAT/../gammas.dta"

        #delimit ;
        plausexog uci `y' `base' `SH' (fert = twin_`f'_fam) [`wt'], vce(robust)
        gmin(0) gmax(0.0124) grid(2) level(.9);
        #delimit cr
        local c1 = e(lb_fert)
        local c2 = e(ub_fert)
        local LB1= string(`c1',"%5.4f")
        local UB1= string(`c2',"%5.4f")
        local bounds`f'`y' "`bounds`f'`y'' `LB1' & `UB1' &"
        
        **Apply Frisch-Waugh-Lovell
        foreach var in `y' fert twin_`f'_fam {
            qui reg `var' `base' `SH' [`wt']
            predict `var'res, resid
        }
        #delimit ;
        plausexog ltz `y'res (fertres = twin_`f'_famres) [`wt'],
        distribution(special, gamma) seed(1201) level(.9) vce(robust);
        #delimit cr
        local LB = e(lb_fertres)
        local UB = e(ub_fertres)
        local LB1= string(`LB',"%5.4f")
        local UB1= string(`UB',"%5.4f")
        local bounds`f'`y' "`bounds`f'`y'' `LB1' & `UB1' \\"
        
        local vmax 0.05
        foreach num of numlist 0(1)10 {
            local om`num' = ((`num'/10)*`vmax'/sqrt(12))^2
            local mu`num' =  (`num'/10)*`vmax'/2
            local d`num'  =  (`num'/10)*`vmax'
        }
        
        *old omega 0.0016456^2        
        #delimit ;
        qui plausexog ltz `y'res (fertres = twin_`f'_famres) [`wt'],
        mu(0.0062792) omega(0.004) graph(fertres) ytitle({&beta}) xtitle({&delta})
        graphomega(`om0' `om1' `om2' `om3' `om4' `om5' `om6' `om7' `om8' `om9' `om10')
        graphmu(`mu0' `mu1' `mu2' `mu3' `mu4' `mu5' `mu6' `mu7' `mu8' `mu9' `mu10')
        graphdelta(`d0' `d1' `d2' `d3' `d4' `d5' `d6' `d7' `d8' `d9' `d10')
        note("Methodology described in Conley et al. (2012)")
        xline(0.0124, lcolor(red) lpattern(longdash))
        legend(order(1 "Point Estimate (LTZ)" 2 "95% CI")) scheme(s1mono);
        graph export "$OUT/figures/ConleyUSA_`y'_`f'.eps", as(eps) replace;
        #delimit cr
        restore

        replace LB`y' = `LB' if bound == `i'
        replace UB`y' = `UB' if bound == `i'
        local i = `i'+7
    }
}

********************************************************************************
*** (7) Bounds Figure
********************************************************************************
local j = 1
local ylab ylabel(-0.60(0.20)0.40)
local v1 0.375
foreach y of varlist EducationZscore excellentHealth {
    if `j'==2 local v1 0.175
    if `j'==2 local ylab ylabel(-0.20(0.10)0.20)
    local 
    
    #delimit ;
    twoway rcap LB`y' UB`y' bound in 1/20, scheme(sj)
    ||     scatter point`y' bound in 1/20, legend(off)
    xlabel(1  "OLS" 2  "Base IV"  3 "+H IV" 4  "+S&H IV" 5  "Nevo Rosen" 6  "Conley et al"
           8  "OLS" 9  "Base IV" 10 "+H IV" 11 "+S&H IV" 12 "Nevo Rosen" 13 "Conley et al"
           15 "OLS" 16 "Base IV" 17 "+H IV" 18 "+S&H IV" 19 "Nevo Rosen" 20 "Conley et al",
           angle(45)) yline(0, lcolor(red) lpattern(dash) lwidth(thin))
    xtitle("") ytitle("Estimated Q-Q 95% Bounds") `ylab'
    text(`v1' 4 "Two-Plus") text(`v1' 11 "Three-Plus") text(`v1' 18 "Four-Plus");
    graph export "$OUT/figures/boundsNHIS_`y'.eps", replace;
    #delimit cr
    local ++j
}
exit



********************************************************************************
*** ALL BELOW IS APPENDICES ONLY
********************************************************************************


********************************************************************************
*** (8) QQ regressions by gender
********************************************************************************
tab H_mheight, gen(HH_)
foreach gend of numlist 1 2 {
    foreach y of varlist  `yvars' {
        foreach f in two three four {
            local F`f'
            preserve
            keep if childSex==`gend'&`f'_plus==1
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
        #delimit ;
        local ests est3 est2 est1 est6 est5 est4 est9 est8 est7
        local fs  twobfert twohfert twosfert threebfert threehfert
                  threesfert fourbfert fourhfert foursfert;
        estout `ests' using "$OUT/Gender/IVFert`y'_`gend'.txt", replace
        `estopt' keep(fert `SH');
        estout `fs' using "$OUT/Gender/IVFert`y'_`gend'_first.txt", replace
        keep(twin* `SH') cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par))
        stats (N KPF KPp, fmt(%9.0g %9.2f %9.3f))
        starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
        #delimit cr
        estimates clear

        local j = 1
        foreach f in two three four {
            preserve
            keep if childSex==`gend'&`f'_plus==1
            eststo: reg `y' fert `base' `SH' [`wt']
            keep if e(sample)==1
            local ++j
            
            eststo: reg `y' fert `base' `H'  [`wt'] 
            local ++j
            eststo: reg `y' fert `base'      [`wt']
            local ++j
            restore
        }
        local estimates est3 est2 est1 est6 est5 est4 est9 est8 est7
        #delimit ;
        estout `estimates' using "$OUT/Gender/OLSFert`y'`gend'.txt", replace
        cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) stats
        (r2 N Ost, fmt(%9.2f %9.0g %9.3f)) keep(fert `SH') 
        starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
        #delimit cr
        estimates clear
    }
}



********************************************************************************
*** (9) Summary
********************************************************************************
local motherStat fert motherAge mEduc BMI BMI185 motherExcellentHealth
local childStat  childAge childEducation EducationZscore excellentHealth 

preserve
collapse `motherStat' fEduc twinfamily, by(surveyYear hhx fmx)
replace twinfamily=round(twinfamily)
#delimit ;
estpost tabstat `motherStat', by(twinfamily) statistics(mean sd) listwise
 columns(statistics);
esttab using "$OUT/tables/MotherNHIS.txt", replace main(mean) aux(sd) nostar
 unstack noobs nonote nomtitle nonumber;
#delimit cr
foreach var of varlist mEduc fEduc BMI BMI185 motherExcellentHealth {
    qui reg `var' twinfamily
    local singleAve = string(_b[_cons]       , "%5.3f")
    local twinAve   = string(_b[_cons]+_b[twinfamily], "%5.3f")
    local diff      = string(_b[twinfamily] , "%5.3f")
    local sediff    = string(_se[twinfamily], "%5.3f")
    local tdiff     = string(`diff'/`sediff' , "%5.3f")
    dis "`var'& `singleAve'&`twinAve'& `diff'&`tdiff' \\"
    dis "&&&(`sediff')&\\"
}

restore
#delimit ;
estpost tabstat `childStat', by(twin) statistics(mean sd) listwise 
 columns(statistics);
esttab using "$OUT/tables/ChildNHIS.txt", replace main(mean) aux(sd) nostar
 unstack noobs nonote nomtitle nonumber;
#delimit cr

sum twin
sum bord if twin==1
count if fpx=="01"
count if fpx=="01"&twinfamily==1
count if fpx=="01"&twinfamily==0
count
count if twin==1
count if twin==0    


********************************************************************************
*** (10) Twin Regression
********************************************************************************
gen twin100=twin*100
#delimit ;
local tvars mEduc motherHeight bmi heightMiss smokePrePreg smokeMissing;
local FEs i.motherAge i.motherRac i.surveyYear i.region;
#delimit cr

eststo: reg twin100 `tvars' `FEs' [pw=mWeight], robust
eststo: reg twin100 `tvars' `FEs' [pw=mWeight] if childYearB<=1990, robust
eststo: reg twin100 `tvars' `FEs' [pw=mWeight] if childYearB> 1990, robust

lab var mEduc "Mother's Education (Years)"
lab var motherHeight "Mother's Height (Inches)"
lab var bmi "Mother's BMI"
lab var smokePrePreg "Smoked Prior to Birth"

#delimit ;
esttab est1 est2 est3 using "$OUT/tables/NHIStwin.tex", noline
b(%-9.3f) se(%-9.3f) starlevel("*" 0.10 "**" 0.05 "***" 0.01)
stats(N r2, fmt(%9.0gc %5.3f) label("Observations" "R-Squared"))
label nonotes mlabels(, none) nonumbers style(tex) fragment replace
keep(mEduc motherHeight bmi smokePrePreg);
#delimit cr
estimates clear
*/
********************************************************************************
*** (6b) IV regressions only with same sex twins
********************************************************************************
*gen sextest = childSex if twin==1
*bys motherID childYearBirth: egen varsex = sd(sextest)
*bys motherID childYearBirth: egen twingend = max(sextest)
*gen samesextwins = varsex == 0 if varsex!=.
*
*local bb = 2
*foreach n in two three four {
*    gen sst = 1 if bordtwin == `bb'&samesextwins==1&twin_`n'_fam==1
*    local ++bb
*    bys motherID: egen twin_`n'_fam_samesex = max(sst)
*    replace twin_`n'_fam_samesex=0 if twin_`n'_fam_samesex==.
*    drop sst
*}

local c1 `base'
local c2 `base' `H'
local c3 `base' `SH'
local x   fert
foreach y of varlist EducationZscore excellentHealth {
    local ests1
    local ests2
    local ecnt = 1

    foreach f in two three four {
        preserve
        keep if `f'_plus==1
        egen keeper = rowmiss(`y' `base' `SH' fert twin_`f'_fam)
        keep if keeper==0
        gen Twins = twin_`f'_fam_samesex

        local p partial(`base') savefirst
        local z Twins

        foreach e of numlist 1(1)3 {
            eststo: ivreg2 `y' `c`e'' (`x'=`z') [`wt'], `se' `p' savefp(f`ecnt')
            local beta`e' =  _b[`x']
            local stde`e' = _se[`x']
            local ests2 `ests2' est`ecnt'
            local ests1 `ests1' f`ecnt'fert
            mat first=e(first)
            estadd scalar KPF=first[8,1]: f`ecnt'fert
            estadd scalar KPp=first[7,1]: f`ecnt'fert

            **Generate residuals for equality of coefficient tests
            foreach var in x y z {
                reg ``var'' `c`e'' [`wt']
                predict `var'res`e', resid
            }
            if `e'!=1 {
                #delimit ;
                gmm (eq1: yres1-{b1}*xres1-{b0}) (eq2: yres`e'-{c1}*xres`e'-{c0})
                [`wt'], instruments(eq1: zres1) instruments(eq2: zres`e')
                onestep winitial(unadjusted, indep) vce(cluster motherID);
                #delimit cr
                test ([b1]_cons = [c1]_cons)
                estadd scalar c = r(p): est`ecnt'
            }
            local ++ecnt    
        }
        restore
    }
    #delimit ;
    esttab `ests2' using "$OUT/tables/NHISIV`y'_samesex.tex", keep(fert)
    b(%-9.3f) se(%-9.3f) starlevel("*" 0.10 "**" 0.05 "***" 0.01)
    stats(N c, fmt(%9.0gc %5.3f) label("Observations" "Coefficient Difference"))
    label nonotes mlabels(, none) nonumbers style(tex) fragment replace noline;

    gen Twins = .;
    lab var Twins "Same Sex Twins";
    esttab `ests1' using "$OUT/tables/NHISIV`y'_samesex_first.tex", b(%-9.3f)
    se(%-9.3f) keep(Twins) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)
    stats(KPF KPp, fmt(%9.2f %9.3f)
          label("Kleibergen-Paap rk statistic" "p-value of rk statistic"))
    label nonotes mlabels(, none) nonumbers style(tex) fragment replace noline;
    drop Twins;
    #delimit cr
    estimates clear
}
exit

********************************************************************************
*** (12) Global trends from various data sources (USA)
********************************************************************************
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

*wbopendata, country(USA) indicator(SP.DYN.TFRT.IN) long clear
use "$DAT/WBfertility_USA_TFRT", clear

merge 1:1 year using `censusEduc'

rename sp_dyn_tfrt_in Fertility
lab var Fertility "Fertility per Woman (World Bank)"
lab var educyrs   "Average Years of Education (ACS)"
keep if year>=1960&year<2014

#delimit ;
twoway line educyrs year, yaxis(1) lpattern(longdash) lwidth(medthick)
lcolor(black) ytitle("Average Years of Education (ACS)" " ", axis(1)) ||
       line Fertility year, yaxis(2) lcolor(black)
legend(label(1 "Average Years of Education") label(2 "Fertility per Woman"))
scheme(s1mono);
graph export "$OUT/figures/USTrends.eps", as(eps) replace;
#delimit cr





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

