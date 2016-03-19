/* fetalDeathGraphs v0.00        damiancclarke             yyyy-mm-dd:2016-03-19
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8


*/

vers 11
clear all
set more off
cap log close

*-------------------------------------------------------------------------------
*--- (1) globals
*-------------------------------------------------------------------------------
global DAT "~/database/NVSS/"
global OUT "~/investigacion/Activa/Twins/Figures"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/fetalDeathGraphs.txt", text replace


*-------------------------------------------------------------------------------
*--- (2) Import
*-------------------------------------------------------------------------------
foreach yr of numlist 1999(1)2002 {

    use "$DAT/FetalDeaths/dta/fetl`yr'", clear
    keep if dgestat>=20&dgestat<99
    gen twin = dplural == 2
    drop if dplural>2
    rename dmage motherAge
    rename dtotord birthOrder
    gen smokes = 1 if tobacco == 1 & cigar!=99
    replace smokes = 0 if tobacco == 2
    gen drinks = 1 if alcohol == 1 & drink !=99
    replace drinks = 0 if alcohol == 2
    gen death = 1
    gen yrsEduc = dmeduc if dmeduc!=99
    gen cigarettes = cigar if cigar!=99
    gen numdrinks  = drink if drink!=99
    gen anemic     = anemia==1 if anemia != .
    
    keep smokes drinks twin birthOrder motherAge stateres death yrsEduc /*
    */ numdrinks cigarettes anemic
    gen year = `yr'
    tempfile deaths`yr'
    save `deaths`yr''
    
    use "$DAT/Births/dta/natl`yr'"
    gen twin = dplural == 2
    drop if dplural>2
    rename dmage motherAge
    rename dtotord birthOrder
    gen smokes = 1 if tobacco == 1 & cigar!=99
    replace smokes = 0 if tobacco == 2
    gen drinks = 1 if alcohol == 1 & drink !=99
    replace drinks = 0 if alcohol == 2
    gen death = 0
    gen year = `yr'
    gen yrsEduc = dmeduc if dmeduc!=99
    gen cigarettes = cigar if cigar!=99
    gen numdrinks  = drink if drink!=99
    gen anemic     = anemia==1 if anemia != .
    
    keep smokes drinks twin birthOrder motherAge stateres death year /*
    */ yrsEduc numdrinks cigarettes anemic
    append using `deaths`yr'', force
    tempfile f`yr'
    save `f`yr''
}
clear
append using `f1999' `f2000' `f2001' `f2002'

*-------------------------------------------------------------------------------
*--- (3) Graphs
*-------------------------------------------------------------------------------
replace death = death*1000
gen noCollege = yrsEduc <13 if yrsEduc!=.
gen     birthType = "Singleton" in 1/2
replace birthType = "Twin"      in 3/4
gen     behaviour = 0 in 1
replace behaviour = 1 in 2
replace behaviour = 0 in 3
replace behaviour = 1 in 4
gen     outcome   = .
gen     barposition = cond(birthType=="Singleton", _n, _n+1)

local j = 1
foreach var of varlist smokes drinks noCollege anemic cigarettes numdrinks yrsEduc {
    if `j'==1 local l1 "Smoked"
    if `j'==1 local l2 "Did Not Smoke"
    if `j'==2 local l1 "Consumed Alcohol"
    if `j'==2 local l2 "Did Not Consume Alcohol"
    if `j'==3 local l1 "No College"
    if `j'==3 local l2 "At Least Some College"
    if `j'==4 local l1 "Anemic"
    if `j'==4 local l2 "Not Anemic"
        
    gen twin`var' = twin*`var'
    areg death twin `var' twin`var' i.birthOrder i.year, abs(motherAge)

    replace outcome = _b[_cons] in 1
    replace outcome = _b[_cons]+_b[`var'] in 2
    replace outcome = _b[_cons]          +_b[twin] in 3
    replace outcome = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var'] in 4
    local   min = _b[_cons]-1
    local   max = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var']+1
    local   twinDif  = string(_b[`var']+_b[twin`var'], "%5.3f")
    local   singDif  = string(_b[`var']              , "%5.3f")
    local   twinNote = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var']+1
    local   singNote = _b[_cons]+_b[`var']+1
    
    if `j'<5 {
        #delimit ;
        twoway bar  outcome barposition  if behaviour==0, color(red)  
            || bar  outcome barposition  if behaviour==1, color(blue)
        xscale(range(0 6)) yscale(range(0 `max'))
        xlabel( 1.5 "Singleton" 4.5 "Twins") scheme(s1mono)
        legend(lab(1 "`l2'") lab(2 "`l1'"))
        xtitle(" ") ytitle("Fetal Deaths Per 1,000 Births")
        text(`twinNote' 4.5 "{&beta}{subscript:twin}=`twinDif'")
        text(`singNote' 1.5 "{&beta}{subscript:single}=`singDif'");
        graph export "$OUT/Deaths`var'_cond.eps", as(eps) replace;
        #delimit cr
    }
        
    reg death twin `var' twin`var'
    replace outcome = _b[_cons] in 1
    replace outcome = _b[_cons]+_b[`var'] in 2
    replace outcome = _b[_cons]          +_b[twin] in 3
    replace outcome = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var'] in 4
    local   min = _b[_cons]-1
    local   max = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var']+1
    local   twinDif  = string(_b[`var']+_b[twin`var'], "%5.3f")
    local   singDif  = string(_b[`var']              , "%5.3f")
    local   twinNote = _b[_cons]+_b[`var']+_b[twin]+_b[twin`var']+1
    local   singNote = _b[_cons]+_b[`var']+1        
    if `j'<5 {
        #delimit ;
        twoway bar  outcome barposition  if behaviour==0, color(red)  
            || bar  outcome barposition  if behaviour==1, color(blue)
        xscale(range(0 6)) yscale(range(0 `max'))
        xlabel( 1.5 "Singleton" 4.5 "Twins") scheme(s1mono)
        legend(lab(1 "`l2'") lab(2 "`l1'"))
        xtitle(" ") ytitle("Fetal Deaths Per 1,000 Births")
        text(`twinNote' 4.5 "{&beta}{subscript:twin}=`twinDif'")
        text(`singNote' 1.5 "{&beta}{subscript:single}=`singDif'");
        graph export "$OUT/Deaths`var'_Uncond.eps", as(eps) replace;
        #delimit cr
    }
    local ++j
}



