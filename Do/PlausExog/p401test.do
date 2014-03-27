/* 401(k) example file */

# delimit ;
clear;
set mem 500m;
set more off;

insheet using restatw.dat;

gen age2 = age^2;

/* N(0,5000^2) */
matrix omega_eta = J(19,19,0);
matrix omega_eta[1,1] = 5000^2;
matrix mu_eta = J(19,1,0);
/* The following two lines may be uncommented to approximate a U[0,10000] */
*matrix omega_eta[1,1] = (10000/sqrt(12))^2 ;
*matrix mu_eta[1,1] = 5000 ;

/* Obtain local to zero approximation estimates using prior specified above */

************************************************************************************	
*  To invoke this command type:                                        			
*	>>ltz var_matrix_for_gamma depvar mean_vector_for_gamma				
*			(endogenouslist covariatelist=instrumentlist covariatelist) 	
*			[if] [in], [level()] [cluster()] [robust]      			
************************************************************************************;

ltz omega_eta mu_eta net_tfa (p401 i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol
	col marr twoearn db pira hown = e401 i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol
	col marr twoearn db pira hown) , level(.95) robust;

/* Obtain bounds */

************************************************************************		
*  To invoke this command type:                                        *		
*	>>uci depvar (endogenouslist covariatelist=instrumentlist covariatelist) [if] [in],
*		g1min()	g1max()	g2min() g2max() ... grid() inst(instrumentlist) [level()]
*		[cluster()] [robust]				       *
************************************************************************;

uci net_tfa (p401 i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol
	col marr twoearn db pira hown = e401 i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol
	col marr twoearn db pira hown), inst(e401) g1min(-10000) g1max(10000) 
	grid(2) level(.95) robust; 	 

dis "DCC's versions";
plausexog uci net_tfa i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol col
  marr twoearn db pira hown (p401  = e401), gmin(-10000) gmax(10000) 
	grid(2) level(.95) robust;

plausexog ltz net_tfa i2 i3 i4 i5 i6 i7 age age2 fsize hs smcol col
  marr twoearn db pira hown (p401  = e401), omega(omega_eta) mu(mu_eta)
  grid(2) level(.95) robust;
