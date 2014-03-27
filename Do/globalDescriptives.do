* globalDescriptives.do v1.00    damiancclarke             yyyy-mm-dd:2014-02-03
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

version 11
clear all
set more off
cap log close

********************************************************************************
* (0) Globals, locals
********************************************************************************
global Data "~/investigacion/Activa/Twins/Data"
global Log  "~/investigacion/Activa/Twins/Log"
global Out  "~/investigacion/Activa/Twins/Results/Sum"
global Map  "~/computacion/StataPrograms/worldstat/Shapefiles/World"

********************************************************************************
* (1) Import ordered DHS data, all discretionary choices
********************************************************************************
log using "$Log/globalDescriptives.txt", text replace
use "$Data/DHS_twins", clear

keep if _merge==3
drop if bmi>50|height>240|height<80
gen split=1 if bmi<20
replace split=0 if bmi>=25
drop if split==.

********************************************************************************
* (2) Generate twin birth variables and ratios
********************************************************************************
replace bord=twin_bord if twin_bord!=.
foreach num of numlist 1(1)5 {
	gen twin`num'=1 if twind==1&bord==`num'
	replace twin`num'=0 if twind==0&bord==`num'
}

collapse twin1 twin2 twin3 twin4 twin5 [pw=sweight], by(_cou split)
reshape wide twin*, i(_cou) j(split)

foreach num of numlist 1(1)5 {
	gen twinratio`num'=twin`num'0/twin`num'1
}

egen twinratio=rowmean(twinratio*)

********************************************************************************
* (3) Summarise as map
********************************************************************************
decode _cou, gen(id)
replace id="Burkina Faso" if id=="Burkina-Faso"
replace id="Central African Republic" if id=="Central-African-Republic"
replace id="Congo" if id=="Congo-Brazzaville"
replace id="Democratic Republic of the Congo" if id=="Congo-Democratic-Republic"
replace id="Cote d'Ivoire" if id=="Cote-d-Ivoire"
replace id="Dominican Republic" if id=="Dominican-Republic"
replace id="Kyrgyzstan" if id=="Kyrgyz-Republic"
replace id="Republic of Moldova" if id=="Moldova"
replace id="Sao Tome and Principe" if id=="Sao-Tome-and-Principe"
replace id="Sierra Leone" if id=="Sierra-Leone"
replace id="United Republic of Tanzania" if id=="Tanzania"
rename id NAME

merge 1:1 NAME using $Map/world_data, gen(_worldmerge)

spmap twinratio using $Map/world_coordinates, id(_ID) fcolor(Greens)
graph export $Out/ratio.eps, as(eps) replace
