********************************************************************************
global IncData "~/investigacion/Activa/Twins/Data"

local oldway 0
local file incomestatus.dta
local incomes 480 545 580 610 635 675 695 725 765 785 785 760 755 755 745 735 /*
*/ 765 825 875 905 935 975 995 1005 1025 1035


if `oldway'==0 {
	gen WBcountry=subinstr(country, "-", " ", .)
	replace WBcountry="Congo, Dem. Rep." if WBcountry=="Congo Democratic Republic"
	replace WBcountry="Cote d'Ivoire" if WBcountry=="Cote d Ivoire"
	replace WBcountry="Egypt, Arab Rep." if WBcountry=="Egypt"
	replace WBcountry="Yemen, Rep." if WBcountry=="Yemen"
	destring _year, replace
	
	merge m:1 WBcountry _year using "$IncData/`file'", gen(_incmerge)
	replace inc_status="LM" if WBcountry=="Brazil" & _year==1986
	replace inc_status="LM" if WBcountry=="Colombia" & _year==1986
	replace inc_status="LM" if WBcountry=="Congo Brazzaville"
	replace inc_status="LM" if WBcountry=="Dominican Republic" & _year==1986	
	replace inc_status="LM" if WBcountry=="El Salvador" & _year==1985
	replace inc_status="L" if WBcountry=="Liberia" & _year==1986
	replace inc_status="L" if WBcountry=="Senegal" & _year==1986
	replace inc_status="LM" if WBcountry=="Peru" & _year==1986
	tostring _year, replace
	keep if _incmerge!=2
}

if `oldway'==1 {
	gen income_status=	"LOWERMIDDLE"	if country=="Albania"
	replace income_status=	"LOWERMIDDLE"	if country=="Armenia"
	replace income_status=	"UPPERMIDDLE"	if country=="Azerbaijan"
	replace income_status=	"LOWINCOME"	if country=="Bangladesh"
	replace income_status=	"LOWINCOME"	if country=="Benin"
	replace income_status=	"LOWERMIDDLE"	if country=="Bolivia"
	replace income_status=	"UPPERMIDDLE"	if country=="Brazil"
	replace income_status=	"LOWINCOME"	if country=="Burkina-Faso"
	replace income_status=	"LOWINCOME"	if country=="Burundi"
	replace income_status=	"LOWINCOME"	if country=="Cambodia"
	replace income_status=	"LOWERMIDDLE"	if country=="Cameroon"
	replace income_status=	"LOWERMIDDLE"	if country=="Cape-Verde"
	replace income_status=	"LOWINCOME"	if country=="CAR"
	replace income_status=	"LOWINCOME"	if country=="Chad"
	replace income_status=	"UPPERMIDDLE"	if country=="Colombia"
	replace income_status=	"LOWINCOME"	if country=="Comoros"
	replace income_status=	"LOWERMIDDLE"	if country=="Congo-Brazzaville"
	replace income_status=	"LOWINCOME"	if country=="Congo-Democratic-Republic"
	replace income_status=	"LOWERMIDDLE"	if country=="Cote-d-Ivoire"
	replace income_status=	"UPPERMIDDLE"	if country=="Dominican-Republic"
	replace income_status=	"LOWERMIDDLE"	if country=="Egypt"
	replace income_status=	"LOWINCOME"	if country=="Eritrea"
	replace income_status=	"LOWINCOME"	if country=="Ethiopia"
	replace income_status=	"UPPERMIDDLE"	if country=="Gabon"
	replace income_status=	"LOWERMIDDLE"	if country=="Ghana"
	replace income_status=	"LOWERMIDDLE"	if country=="Guatemala"
	replace income_status=	"LOWINCOME"	if country=="Guinea"
	replace income_status=	"LOWERMIDDLE"	if country=="Guyana"
	replace income_status=	"LOWINCOME"	if country=="Haiti"
	replace income_status=	"LOWERMIDDLE"	if country=="Honduras"
	replace income_status=	"LOWERMIDDLE"	if country=="India"
	replace income_status=	"LOWERMIDDLE"	if country=="Indonesia"
	replace income_status=	"UPPERMIDDLE"	if country=="Jordan"
	replace income_status=	"UPPERMIDDLE"	if country=="Kazakhstan"
	replace income_status=	"LOWINCOME"	if country=="Kenya"
	replace income_status=	"LOWINCOME"	if country=="Kyrgyz-Republic"
	replace income_status=	"LOWERMIDDLE"	if country=="Lesotho"
	replace income_status=	"LOWINCOME"	if country=="Liberia"
	replace income_status=	"LOWINCOME"	if country=="Madagascar"
	replace income_status=	"LOWINCOME"	if country=="Malawi"
	replace income_status=	"UPPERMIDDLE"	if country=="Maldives"
	replace income_status=	"LOWINCOME"	if country=="Mali"
	replace income_status=	"LOWINCOME"	if country=="Mauritania"
	replace income_status=	"LOWERMIDDLE"	if country=="Moldova"
	replace income_status=	"LOWERMIDDLE"	if country=="Morocco"
	replace income_status=	"LOWINCOME"	if country=="Mozambique"
	replace income_status=	"UPPERMIDDLE"	if country=="Namibia"
	replace income_status=	"LOWINCOME"	if country=="Nepal"
	replace income_status=	"LOWERMIDDLE"	if country=="Nicaragua"
	replace income_status=	"LOWINCOME"	if country=="Niger"
	replace income_status=	"LOWERMIDDLE"	if country=="Nigeria"
	replace income_status=	"LOWERMIDDLE"	if country=="Pakistan"
	replace income_status=	"LOWERMIDDLE"	if country=="Paraguay"
	replace income_status=	"UPPERMIDDLE"	if country=="Peru"
	replace income_status=	"LOWERMIDDLE"	if country=="Philippines"
	replace income_status=	"LOWINCOME"	if country=="Rwanda"
	replace income_status=	"LOWERMIDDLE"	if country=="Samoa"
	replace income_status=	"LOWERMIDDLE"	if country=="Sao-Tome-and-Principe"
	replace income_status=	"LOWERMIDDLE"	if country=="Senegal"
	replace income_status=	"LOWINCOME"	if country=="Sierra-Leone"
	replace income_status=	"UPPERMIDDLE"	if country=="South-Africa"
	replace income_status=	"LOWERMIDDLE"	if country=="Sri-Lanka"
	replace income_status=	"LOWERMIDDLE"	if country=="Sudan"
	replace income_status=	"LOWERMIDDLE"	if country=="Swaziland"
	replace income_status=	"LOWINCOME"	if country=="Tanzania"
	replace income_status=	"LOWERMIDDLE"	if country=="Timor-Leste"
	replace income_status=	"LOWINCOME"	if country=="Togo"
	replace income_status=	"UPPERMIDDLE"	if country=="Turkey"
	replace income_status=	"UPPERMIDDLE"	if country=="Turkmenistan"
	replace income_status=	"LOWINCOME"	if country=="Uganda"
	replace income_status=	"LOWERMIDDLE"	if country=="Ukraine"
	replace income_status=	"LOWERMIDDLE"	if country=="Uzbekistan"
	replace income_status=	"LOWERMIDDLE"	if country=="Vietnam"
	replace income_status=	"LOWERMIDDLE"	if country=="Yemen"
	replace income_status=	"LOWERMIDDLE"	if country=="Zambia"
	replace income_status=	"LOWINCOME"	if country=="Zimbabwe"
}
*THIS COMES FROM WORLD BANK ATLAS METHOD (http://data.worldbank.org/about/country-classifications)
*ACTUAL CLASSIFICATION IS HERE: (http://data.worldbank.org/about/country-classifications/country-and-lending-groups#Low_income)

