* Twin_Descriptives.do           damiancclarke             yyyy-mm-dd:2014-03-17
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
/*
Note: I have used the ssc command distplot and made some changes to the ado to
make distplot2...

*/

clear all
cap log close
set more off
vers 11

********************************************************************************
*** (1) globals, locals
********************************************************************************
global PATH "~/investigacion/Activa/Twins"
global DATA "$PATH/Data"
global RESL "$PATH/Results/Sum"
global LOGS "$PATH/Log"


local trend 0
local med 1
local final 0

cap ssc install distplot
********************************************************************************
*** (2) Initialise
********************************************************************************
log using "$LOGS/Twin_Descriptives.txt", text replace
use "$DATA/DHS_twins"

keep if _merge==3


********************************************************************************
*** (3) Trends over time by cohort
*** Note: check birth order to make sure twin birth order makes sense...
********************************************************************************
if `trend'==1 {
cap mkdir "$RESL/Trends"

preserve
collapse twind [pweight=sweight], by(child_yob)
tsset child_yob
egen twin_ma=ma(twind)
#delimit ;
twoway line twin_ma child_yob if child_yob>1960&child_yob<2012,
  xtitle("Year of Birth") ytitle("Frequency Twins") scheme(s1color)
  title("Frequency of All Twins over Time")
  note("Based on all DHS births.  3 Year moving average smoothed.");
#delimit cr
graph export "$RESL/Trends/AllAverage.eps", as(eps) replace
restore

preserve
gen indexage=agemay-age
gen agegroup=1 if indexage>=15&indexage<20
replace agegroup=2 if indexage>=20&indexage<25
replace agegroup=3 if indexage>=25&indexage<30
replace agegroup=4 if indexage>=30&indexage<35
replace agegroup=5 if indexage>=35&indexage<40
replace agegroup=6 if indexage>=40

collapse twind [pweight=sweight], by(child_yob agegroup)
xtset agegroup child_yob
egen twin_ma=ma(twind)
#delimit ;
twoway line twin_ma child_yob if agegroup==1&child_yob>1960&child_yob<2012, ||
  line twin_ma child_yob if agegroup==2 & child_yob>1960 & child_yob<2012,
  lpattern(dot)       ||
  line twin_ma child_yob if agegroup==3 & child_yob>1960 & child_yob<2012,
  lpattern(dash_dot)  ||
  line twin_ma child_yob if agegroup==4 & child_yob>1960 & child_yob<2012,
  lpattern(shortdash) ||
  line twin_ma child_yob if agegroup==5 & child_yob>1960 & child_yob<2012,
  lpattern(longdash)  ||
  line twin_ma child_yob if agegroup==6 & child_yob>1960 & child_yob<2012,
  lpattern(dash) xtitle("Year of Birth") ytitle("Frequency Twins")
  scheme(s1color) title("Frequency of Twins over Time by Mother's Age")
  note("Based on all DHS births.  3 Year moving average smoothed.")
  legend(label(1 "15-19") label(2 "20-24") label(3 "25-29") label(4 "30-34")
  label(5 "35-39") label(6 "40+"));
#delimit cr
graph export "$RESL/Trends/AgeAverage.eps", as(eps) replace
restore

preserve
replace bord=twin_bord if twind==1
gen bord_group=bord if bord<25
replace bord_group=5 if bord>4
collapse twind [pweight=sweight], by(child_yob bord_group)
xtset bord_group child_yob
egen twin_ma=ma(twind)

#delimit ;
twoway line twin_ma child_yob if bord_group==1&child_yob>1960&child_yob<2012, ||
  line twin_ma child_yob if bord_group==2 & child_yob>1960 & child_yob<2012,
  lpattern(dot)       ||
  line twin_ma child_yob if bord_group==3 & child_yob>1960 & child_yob<2012,
  lpattern(dash_dot)  ||
  line twin_ma child_yob if bord_group==4 & child_yob>1965 & child_yob<2012,
  lpattern(shortdash) ||
  line twin_ma child_yob if bord_group==5 & child_yob>1960 & child_yob<2012,
  lpattern(dash) xtitle("Year of Birth") ytitle("Frequency Twins")
  scheme(s1color) title("Frequency of Twins over Time by Birth Order")
  note("Based on all DHS births.  3 Year moving average smoothed.")
  legend(label(1 "First birth") label(2 "Second birth") label(3 "Third birth")
  label(4 "Fourth birth") label(5 "Higher-order birth"));
#delimit cr

graph export "$RESL/Trends/BordAverage.eps", as(eps) replace
restore
}

********************************************************************************
*** (4) Descriptives
***     (a) Birthweight
***     (b) Breastfeeding
********************************************************************************
if `med'==1 {
	cap mkdir "$RESL/Med/"
	lab var twind "Child is a twin"
	replace m19=. if m19>=5500|m19<=500
	gen breastfeed=m5 if m5<48
	replace breastfeed=0 if m5==94

	
	/*
	byhist m19, by(twind) frac tw(scheme(s1color))
	graph export "$RESL/Med/Birthweight.eps", as(eps) replace

	bihist m19, by(twind) frac tw(scheme(s1color))
	graph export "$RESL/Med/Birthweight_op.eps", as(eps) replace
	
	bihist breastfeed, by(twind) frac tw(scheme(s1color))
	graph export "$RESL/Med/Breastfeed.eps", as(eps) replace

	replace childageatdeath=100 if child_alive==1
	distplot2 line childageatdeath, by(twind)
	graph export "$RESL/Med/Survival.eps", as(eps) replace	
	*/

	replace m16=. if m16>1
	replace m14=. if m14>20
	replace m17=. if m17>1
	
	estpost tabstat m19 m16 m14 m17 breastfeed infantmort childmort educ /*
	*/ school_zscore noeduc highschool malec, by(twind) statistics(mean sd) /*
	*/ columns(statistics) listwise

	esttab, main(mean) aux(sd) nostar unstack /*
	*/ noobs nonote nomtitle nonumber replace
}
********************************************************************************
*** (X) Finalising
********************************************************************************
if `final'==1 {
	log close
	clear all
}
