/* NLSYPrep.do v0.00             damiancclarke             yyyy-mm-dd:2016-05-05
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the NLSY, and converts it into one line per child
with measures of child quality, sibling twin status, and maternal health.  This
can then be used for twin 2sls regressions of the following form:

quality = a + b*fert + S'C + H'D + u
fert    = e + f*twin + S'G + H'I + v

where the quality regression is the second stage.

    Contact: mailto:damian.clarke@ecnomics.ox.ac.uk

Version history
   v0.00: Merging mother and child file

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global OUT "~/investigacion/Activa/Twins/Data/NLSY"
global LOG "~/investigacion/Activa/Twins/Log"
global DAT "~/database/NLSY"

cap mkdir "$OUT"
log using "$LOG/NLSYPrep.txt", text replace

