* betaTest.do 0.0.0             damiancclarke              yyyy-mm-dd:2014-04-08
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
*/ Code to beta test the updated Conley et al code prior to sending to the SSC.
*/

vers 8.0
set more off
cap log close
clear all
set mem 100m

********************************************************************************
*** (0) Globals and locals
********************************************************************************
global DEV "~/investigacion/Activa/Twins/Do/PlausExog/plausexog1.0.0"
global LOG "~/investigacion/Activa/Twins/Do/PlausExog"
global GRA "~/investigacion/Activa/Twins/Do/PlausExog/Graphs"
local x i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol col marr twoearn db pira hown

local uciwork  0
local ltzwork  0
local various  1
local ucibreak 0
local ltzbreak 1

use "$DEV/Conleyetal2012.dta"
cd "$DEV"
do plausexog.ado
log using "$LOG/betaTest.txt", text replace

********************************************************************************
*** (1) UCI Tests that should run
***     (a) Typical UCI
***     (b) Typical UCI with n>2 grid points rather than 2
***     (c) Change level
***     (d) Typical UCI robust ses
***     (e) Typical UCI cluster ses
***     (f) combining above
***     (g) graphing
***     (h) graphing special
********************************************************************************
if `uciwork'==1 {
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000)
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) grid(10)
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) level(0.90)
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) vce(robust)

qui gen cvar=runiform()
foreach num of numlist 1(1)100 {
	qui replace cvar=`num' if cvar>=(`num'-1)/100&cvar<`num'/100
}

plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) vce(cluster cvar)
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) grid(10) /*
*/ level(0.9) vce(cluster cvar)

plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) graph(p401)
graph export "$GRA/UCIbase.eps", as(eps) replace
plausexog uci net_tfa `x' (p401=e401), gmin(-10000) gmax(10000) graph(p401) /*
*/ graphopts(yline(0) xtitle("{stSymbol: d}") ytitle("{stSymbol: b}"))
graph export "$GRA/UCIzeroline.eps", as(eps) replace

plausexog uci net_tfa `x' i.cvar (p401=e401), gmin(-10000) gmax(10000)
}

********************************************************************************
*** (2) LTZ Tests that should run
***     (a) Typical LTZ
***     (b) Change level
***     (c) graphing
***     (g) graphing special
********************************************************************************
if `ltzwork'==1 {
matrix omega_eta = J(19,19,0)
matrix omega_eta[1,1] = 5000^2
matrix mu_eta = J(19,1,0)
plausexog ltz net_tfa `x' (p401 = e401), omega(omega_eta) mu(mu_eta)
plausexog ltz net_tfa `x' (p401 = e401), omega(omega_eta) mu(mu_eta) level(0.9)
	
foreach num of numlist 1(1)5 {
	matrix om`num' = J(19,19,0)
	matrix om`num'[1,1] = ((`num'/5)*10000/sqrt(12))^2
	matrix mu`num' = J(19,1,0)
	matrix mu`num'[1,1] = (`num'/5)*10000/2
	local d`num' = (`num'/5)*10000
}
plausexog ltz net_tfa `x' (p401 = e401), omega(omega_eta) mu(mu_eta) /*
*/ graph(p401) graphomega(om1 om2 om3 om4 om5) graphmu(mu1 mu2 mu3 mu4 mu5) /*
*/ graphdelta(`d1' `d2' `d3' `d4' `d5')
graph export "$GRA/LTZbase.eps", as(eps) replace

plausexog ltz net_tfa `x' (p401 = e401), omega(omega_eta) mu(mu_eta) /*
*/ graph(p401) graphomega(om1 om2 om3 om4 om5) graphmu(mu1 mu2 mu3 mu4 mu5) /*
*/ graphdelta(`d1' `d2' `d3' `d4' `d5') graphopts(yline(0) /*
*/ xtitle("{stSymbol: d}") ytitle("{stSymbol: b}"))
graph export "$GRA/LTZzeroline.eps", as(eps) replace

}


********************************************************************************
*** (3) UCI LTZ various instruments
********************************************************************************
if `various'==1 {
gen p401a=p401+rnormal()
gen e401a=e401+rnormal()
matrix omega_eta = J(20,20,0)
matrix omega_eta[1,1] = 5000^2
matrix mu_eta = J(20,1,0)

plausexog uci net_tfa `x' (p401*=e401*), gmin(-10000 0) gmax(10000 0)
plausexog uci net_tfa `x' (p401=e401*), gmin(-10000 0) gmax(10000 0)
plausexog ltz net_tfa `x' (p401*=e401*), omega(omega_eta) mu(mu_eta)
plausexog ltz net_tfa `x' (p401=e401*), omega(omega_eta) mu(mu_eta)
	
foreach num of numlist 1(1)5 {
	matrix om`num' = J(20,20,0)
	matrix om`num'[1,1] = ((`num'/5)*10000/sqrt(12))^2
	matrix mu`num' = J(20,1,0)
	matrix mu`num'[1,1] = (`num'/5)*10000/2
	local d`num' = (`num'/5)*10000
}
plausexog ltz net_tfa `x' (p401* = e401*), omega(omega_eta) mu(mu_eta) /*
*/ graph(p401) graphomega(om1 om2 om3 om4 om5) graphmu(mu1 mu2 mu3 mu4 mu5) /*
*/ graphdelta(`d1' `d2' `d3' `d4' `d5')
graph export "$GRA/LTZvariousinst.eps", as(eps) replace
}

********************************************************************************
*** (4) Break UCI, LTZ
********************************************************************************
if `ucibreak'==1 {
	plausexog uci net_tfa `x' (p401=e401), gmin(-10000 0) gmax(10000 0)
}

if `ltzbreak'==1 {
	matrix omega_eta = J(20,20,0)
	matrix omega_eta[1,1] = 5000^2
	matrix mu_eta = J(20,1,0)

	plausexog ltz net_tfa `x' (p401 = e401), omega(omega_eta) mu(mu_eta)
}

log close
