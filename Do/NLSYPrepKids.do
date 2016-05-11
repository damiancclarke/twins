/* NLSYPrepKids.do v0.00         damiancclarke             yyyy-mm-dd:2016-05-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NLSY child file, with measures of child qualit
y, sibling twin status, and maternal health.  This can then be used for twin 2sl
s regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Import from NLSY

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/NLSY/NLSYChildSet"
global OUT "~/investigacion/Activa/Twins/Data/NLSY79"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir "$OUT"
log using "$LOG/NLSYPrep.txt", text replace

********************************************************************************
*** (2) Import NLSY79 data
********************************************************************************
infile using "$DAT/NLSYChildSet.dct"
do "$DAT/NLSYChildSet-value-labels.do"


********************************************************************************
*** (3) Generate child variables
********************************************************************************
rename CYRB_XRND yob
rename CMOB_XRND mob
bys MPUBID_XRND (yob mob): gen yearBefore = yob[_n]-yob[_n-1]
bys MPUBID_XRND (yob mob): gen monthBefore= mob[_n]-mob[_n-1]
bys MPUBID_XRND (yob mob): gen yearAfter  = yob[_n+1]-yob[_n]
bys MPUBID_XRND (yob mob): gen monthAfter = mob[_n+1]-mob[_n]
gen birthSpaceP = yearBefore+(monthBefore/12)
gen birthSpaceN = yearAfter +(monthAfter /12)
gen twin=birthSpaceP==0|birthSpaceN==0
bys MPUBID_XRND: egen twinFamily = max(twin)

