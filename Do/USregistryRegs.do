* USregistryRegs.do v0.00        damiancclarke             yyyy-mm-dd:2014-06-30
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* Import raw text files of US birth and fetal death data and run regressions of
twinning, fetal deaths and twin fetal deaths on characteristics. The location of
raw fixed width text files (zipped) is:
http://www.cdc.gov/nchs/data_access/Vitalstatsonline.htm#Tools

Processed files along with dictionary files are located on NBER's data reposit-
ory: http://www.nber.org/data/vital-statistics-natality-data.html

For optimal viewing of this file, set tab width=2.

NOTES: 1969 has no plurality variable
       1970 has no plurality variable 
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


********************************************************************************
*** (2) Import and process birth data
********************************************************************************
	
1968  datayear stateres frace mrace birmon dmage birattnd dlegit dplural dbirwt dgestat

1969  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb
1970  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb

1971  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural

1972  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural
1973  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural
1974  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural
1975  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural
1976  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural
1977  datayear stateres frace mrace birmon dmage birattnd dlegit dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural

1978  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1979  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1980  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1981  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1982  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1983  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1984  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1985  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1986  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1987  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps
1988  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbd dtotord dmeduc llbyr disllb dplural omaps fmaps

1989  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1990  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1991  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1992  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1993  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1994  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc llbyr disllb dplural omaps fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain

1995  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1996  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1997  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1998  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
1999  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
2000  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
2001  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain
2002  datayear stateres frace mrace birmon dmage birattnd dmar dbirwt dgestat nlbnd dtotord dmeduc dplural fmaps anemia cardiac lung diabetes chyper phyper eclamp pre4000 preterm renal tobacco cigar alcohol drink wtgain

2003 dob_yy dob_mm ostate ubfacil umagerpt mrace mar meduc fagerpt priordead lbo precare wtgain cig_0 cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest combgest dbwt

2004 dob_yy dob_mm ostate ubfacil mager mrace mar meduc fagerpt priordead lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest combgest dbwt

2005 dob_yy dob_mm xostate ubfacil mager mrace mar meduc fagerpt priordead lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest combgest dbwt

2006 dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs alcohol drinks urf_anemia urf_card urf_lung urf_diab urf_chyper urf_phyper urf_eclam urf_pre4000 urf_preterm apgar5 dplural estgest combgest dbwt

2007 dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt
2008  dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_1 cig_2 cig_3 tobuse cigs rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt

2009  dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi
2010  dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi
2011  dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi
2012  dob_yy dob_mm ubfacil mager mrace mar meduc fagerpt lbo precare wtgain cig_0 cig_1 cig_2 cig_3 cig_rec rf_diab rf_ghyp rf_phyp rf_eclam rf_ppterm apgar5 dplural estgest combgest dbwt rf_inftr rf_fedrg cig_rec bmi
