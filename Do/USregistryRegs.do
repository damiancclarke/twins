* USregistryRegs.do v0.00        damiancclarke             yyyy-mm-dd:2014-06-30
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* Import raw text files of US birth and fetal death data and run regressions of
twinning, fetal deaths and twin fetal deaths on characteristics. The location of
raw text files (zipped) is:
http://www.cdc.gov/nchs/data_access/Vitalstatsonline.htm#Tools

For optimal viewing of this file, set tab width=2.
*/

vers 11
set more off
cap log close
clear all

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/database/NVSS"
global OUT "~/investigacion/Activa/Twins/Results/NVSS_USA"
global LOG "~/investigacion/Activa/Twins/Log"

cap mkdir $OUT
log using "$LOG/USregistryRegs.txt", text replace

#delimit ;
local FetDeath VS82FETL.DETUSPUB VS83FETL.DETUSPUB VS84FETL.DETUSPUB
  VS85FETL.DETUSPUB VS86FETL.DETUSPUB VS87FETL.DETUSPUB VS88FETL.DETUSPUB
  VS89FETL.DETUSPUB VS90FETL.DETUSPUB VS91FETL.DETUSPUB VS92FETL.DETUSPUB
  VS93FETL.DETUSPUB VS94FETL.DETUSPUB VS95FETL.DETUSPUB VS96FETL.DETUSPUB
  VS97FETL.DETUSPUB VS98FETL.DETUSPUB VS99FETL.DETUSPUB VS00FETL.DETUSPUB
  VS01FETL.DETUSPUB VS02FETL.DETUSPUB VS03FETL.DETUSPUB VS04FETL.DETUSPUB
  vs05fetl.publicUS vs06fetal.DETUSPUB VS07Fetal.PublicUS
  VS09Fetal.Detailuspub.txt VS10Fetalupdated.Detailuspub.Detailuspub
  VS11Fetal.DetailUSpubfinalupdate.DetailUSpub VS12FetalDetailUSPub.txt;

#delimit cr
