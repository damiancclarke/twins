# twinTabs.R v1.00               damiancclarke             yyyy-mm-dd:2014-03-29
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Formats csv files from outreg2 (Stata) to create tex files for twin paper.

rm(list=ls())


#******************************************************************************
#***(1) Libraries, directories
#******************************************************************************
require(gdata)

proj.dir <- "~/investigacion/Activa/Twins/"
IV.dir   <- paste(proj.dir, "Results/Outreg/IV/", sep="")
summ.dir <- paste(proj.dir, "Results/Outreg/Summary/", sep="")

#******************************************************************************
#***(2) Main functions
#******************************************************************************
fert.est <- function(file)