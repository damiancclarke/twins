/* twinLE.do                     damiancclarke             yyyy-mm-dd:2015-09-22
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Plots examining twin rates and life expectancy in DHS sample

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals
********************************************************************************
global DAT "~/investigacion/Activa/Twins/Data"
global OUT "~/investigacion/Activa/Twins/Results/Graphs"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/twinLE.txt", text replace


********************************************************************************
*** (2) Use data, country classes (SSA All income levels)
********************************************************************************
use "$DAT/FLEXP_WB"
keep if countryname=="Sub-Saharan Africa (all income levels)"
tempfile lexp
save `lexp'

*use "$DAT/DHS_twins10samp"
use "$DAT/DHS_twins"

decode _cou, gen(cc)
drop _cou
rename cc _cou
#delimit ;
keep if _cou=="Benin"|_cou=="Botswana"|_cou=="Burkina-Faso"|_cou=="Burundi"
|_cou=="Cameroon"|_cou=="Central-African-Republic"|_cou=="Chad"|_cou=="Comoros"
|_cou=="Congo-Democratic-Republic."|_cou=="Congo-Brazzaville"|_cou=="Ethiopia"
|_cou=="Cote-d-Ivoire"|_cou=="Gabon"|_cou=="Ghana"|_cou=="Guinea"|_cou=="Kenya"
|_cou=="Lesotho"|_cou=="Liberia"|_cou=="Madagascar"|_cou=="Malawi"
|_cou=="Mali"|_cou=="Mozambique"|_cou=="Namibia"|_cou=="Niger"|_cou=="Nigeria"
|_cou=="Rwanda"|_cou=="Sao-Tome-and-Principe"|_cou=="Senegal"
|_cou=="Sierra-Leone"|_cou=="South-Africa"|_cou=="Swaziland"|_cou=="Tanzania"
|_cou=="Togo"|_cou=="Uganda"|_cou=="Zambia"|_cou=="Zimbabwe";
keep if agemay < 35;
#delimit cr
count

collapse twind [pw=sweight], by(child_yob)
rename child_yob year

merge 1:1 year using `lexp'
tsset year
tssmooth ma twinsmooth = twind, window(2 1 2)

keep if year>1975&year<=2010
lab var sp_dyn_le00_fe_in "Female Life Expectancy"
#delimit ;
scatter twind year, yaxis(1) || line sp_dyn_le00_fe_in year, yaxis(2)
legend(label(1 "Proportion Twins") label(2 "Female Life Expectancy"))
ytitle("Proportion Twin") xtitle("Year") scheme(s1mono)
xlabel(1975 1980 1990 2000 2010);
#delimit cr
graph export "$OUT/TwinsSSA_AllIncome.eps", replace

#delimit ;
line twind year, yaxis(1)|| line sp_dyn_le00_fe_in year, yaxis(2)
lpattern(dash_dot) ytitle("Proportion Twin") xtitle("Year") scheme(s1mono)
legend(label(1 "Proportion Twins") label(2 "Female Life Expectancy"))
xlabel(1975 1980 1990 2000 2010);
#delimit cr
graph export "$OUT/TwinsSSA_AllIncome_alt.eps", replace

#delimit ;
line twinsmooth year, yaxis(1)|| line sp_dyn_le00_fe_in year, yaxis(2)
lpattern(dash_dot) ytitle("Proportion Twin") xtitle("Year") scheme(s1mono)
legend(label(1 "Proportion Twins") label(2 "Female Life Expectancy"))
xlabel(1975 1980 1990 2000 2010);
#delimit cr
graph export "$OUT/TwinsSSA_AllIncome_smooth.eps", replace

