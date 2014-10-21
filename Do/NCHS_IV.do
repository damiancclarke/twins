/* NCHS_IV.do v0.00              damiancclarke             yyyy-mm-dd:2014-10-21
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NCHS, and converts it into one line per child
with measures of child quality, sibling twin status, and maternal health.  This
can then be used for twin 2sls regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Running only with 2013 NCHS

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/NCHS/Data/dta/2013"
global OUT "~/investigacion/Activa/Twins/Results/Outreg/NCHS"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir $OUT
log using "$LOG/NCHS_IV.txt", text replace

********************************************************************************
*** (2) Open data
********************************************************************************
use "$DAT/familyxx.dta"
