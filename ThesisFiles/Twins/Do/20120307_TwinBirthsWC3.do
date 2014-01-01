/* TwinBirthsWC3 1.00                  UTF-8                       dh:2012-03-07
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base H:\ExtendedEssay\Twins
cd $Base\Log
log using $Base\Log\20120307_TwinBirthsWC3.txt, text replace

use $Base\..\DHS\world_child3

