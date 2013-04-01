/* TwinSetup 2.00                damiancclarke                     dh:2012-09-12
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 2000m

*******************************************************************************
****(1) Globals
*******************************************************************************
global Base "~/investigacion/Activa/Twins"
global Data "~/database/DHS"

log using $Base/Log/TwinSetup2.log, text replace

*******************************************************************************
****(2) Maternal variables from IR
*******************************************************************************
gen maternal_weight = v437 / 10
gen maternal_height = v438 / 1000
gen maternal_bmi = maternal_height / (maternal_weight^2)
gen maternal_educ = v133


label var maternal_weight "Maternal weight in kilograms"
label var maternal_height "Maternal height in metres"
label var maternal_bmi "Maternal BMI (at date of survey)"
label var maternal_educ "Maternal education in years"
