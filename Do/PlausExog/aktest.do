/* AK example file */

# delimit ;
clear;
set mem 800m;
set more off;

infile lwage educ yob sob qob using akdata.txt ;

xi i.yob i.sob i.qob;

/* N(0,.005^2 I_3) */
matrix omega_eta = J(63,63,0);
matrix omega_eta[1,1] = .005^2;
matrix omega_eta[2,2] = .005^2;
matrix omega_eta[3,3] = .005^2;
matrix mu_eta = J(63,1,0);

/* Obtain local to zero approximation estimates using prior specified above */

************************************************************************************	
*  To invoke this command type:                                        			
*	>>ltz var_matrix_for_gamma depvar mean_vector_for_gamma				
*			(endogenouslist covariatelist=instrumentlist covariatelist) 	
*			[if] [in], [level()] [cluster()] [robust]      			
************************************************************************************;

ltz omega_eta mu_eta lwage (educ _Iyob* _Isob* = _Iqob* _Iyob* _Isob*) , level(.95) robust;

/* Obtain bounds */

************************************************************************		
*  To invoke this command type:                                        *		
*	>>uci depvar (endogenouslist covariatelist=instrumentlist covariatelist) [if] [in],
*		g1min()	g1max()	g2min() g2max() ... grid() inst(instrumentlist) [level()]
*		[cluster()] [robust]				       *
************************************************************************;

uci lwage (educ _Iyob* _Isob* = _Iqob* _Iyob* _Isob*), inst(_Iqob*) 
	g1min(-.01) g1max(.01) g2min(-.01) g2max(.01) g3min(-.01) g3max(.01) 
	grid(2) level(.95) robust; 	 
