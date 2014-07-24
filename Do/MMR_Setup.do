* MMR_Setup.do v0.00             damiancclarke             yyyy-mm-dd:2014-07-22
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* File to generate one line per woman with sister's survival status.  Generates
variable to indicate whether or not any of a woman's sisters has died during or
related to childbirth, along with total number of sisters.  This file can be me-
rged to the main data file to run tests of how a woman's characteristics relate
to family survival.

*/

vers 11.2
clear all
set more off
cap log close
set maxvar 10000

********************************************************************************
*** (0) Globals and locals
********************************************************************************
global DAT "~/database/DHS/XDHS_Data"
global DIR "~/investigacion/Activa/Twins"
global OUT "~/investigacion/Activa/Twins/Data"
global LOG "~/investigacion/Activa/Twins/Log"

log using "$LOG/MMR_Setup.txt", text replace

********************************************************************************
*** (1) Conserve sister MMR along with mother ID
********************************************************************************
foreach ff of numlist 1 2 4(1)7 {
	use "$DAT/World_IR_p`ff'", clear
	keep _cou _year caseid v001 v002 v150 mm*
	gen mid="a"
	egen id=concat(_cou mid _year mid v001 mid v002 mid v150 mid caseid)

	bys _cou _year: egen maxMM=max(mmidx_01)
	keep if maxMM==1
	drop mid _cou _year caseid v001 v002 v150 maxMM
	
	foreach num in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
		replace mm3_`num'=45 if mm3_`num'==98|mm3_`num'==99
		foreach mm in mmidx_ mm2_ mm3_ mm6_ mm7_ mm9_ {
			replace `mm'`num'=. if mm1_`num'!=2
		}
	}
	egen numSisters        = rownonmiss(mmidx_*)
	egen numDeaths         = anycount(mm2_*), values(0)
	egen numMaternalDeaths = anycount(mm9_*), values(2(1)6)
	egen SiblingMeanAge    = rowmean(mm3_*)

	keep id numSisters numDeaths numMaternalDeaths SiblingMeanAge
	tempfile mfile`ff'
	save `mfile`ff''
}

clear
append using `mfile1' `mfile2' `mfile4' `mfile5' `mfile6' `mfile7'

********************************************************************************
*** (3) Save maternal mortality file
********************************************************************************
save "$OUT/TwinsMMR", replace
log close
