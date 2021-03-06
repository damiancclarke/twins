log using ChowTest.txt, text replace

clear
set obs 1000

foreach var in y x1 x2 x3 x4 z4 {
	gen `var'=rnormal()
}
gen group=0 in 1/500
replace group=1 in 501/1000

gen x4group1=x4*group
gen z4group1=z4*group

dis "Chow test for OLS (works)"
reg y x1 x2 x3 x4 if group==0
reg y x1 x2 x3 x4 if group==1
reg y i.group#c.(x1 x2 x3 x4) group


dis "Chow test for IV (doesn't work)"
ivregress 2sls y x1 x2 x3 (x4 = z4) if group==0
ivregress 2sls y x1 x2 x3 (x4 = z4) if group==1

ivregress 2sls y i.group#c.(x1 x2 x3) (x4 x4group1 = z4 z4group1) group
log close
