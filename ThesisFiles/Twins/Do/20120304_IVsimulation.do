/* IV_simul 1.00                  UTF-8                       dh:2012-03-01
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
cap program drop IVsim1
program define IVsim1, rclass

clear
set obs 1000
*y=quality of children
*x=number of children
*z=twins
*u includes unobserved parental preferences, correlated negatively with number
***of children

*y = 0 - 0.1x + u  
*x = 2 + 0.8z + v  
foreach bias of numlist 0(1)6{
scalar rho_ux = .5
scalar rho_zx = 0.5
scalar rho_zu`bias' = 0.`bias'
matrix cov_mat = (1, rho_ux, rho_zu`bias' \ rho_ux,  1, rho_zx \ rho_zu`bias', rho_zx, 1)
drawnorm u`bias' x`bias' z`bias', cov(cov_mat)

*scatter z`bias' u`bias'
*}

scalar bx = -0.1
gen y`bias' = bx*x`bias' + u`bias'

reg y`bias' x`bias'
return scalar OLS`bias'=_b[x`bias']
return scalar OLSse`bias'=_se[x`bias']

ivregress 2sls y`bias' (x`bias'=z`bias')
return scalar IV`bias'=_b[x`bias']
return scalar IVse`bias'=_se[x`bias']
}
end

simulate IVsim1 OLS1=r(OLS1) OLSse1=r(OLSse1) IV1=r(IV1) IVse1=r(IVse1) /*
*/ OLS2=r(OLS2) OLSse2=r(OLSse2) IV2=r(IV2) IVse2=r(IVse2)/*
*/ OLS3=r(OLS3) OLSse3=r(OLSse3) IV3=r(IV3) IVse3=r(IVse3)/*
*/ OLS4=r(OLS4) OLSse4=r(OLSse4) IV4=r(IV4) IVse4=r(IVse4)/*
*/ OLS5=r(OLS5) OLSse5=r(OLSse5) IV5=r(IV5) IVse5=r(IVse5)/*
*/ OLS6=r(OLS6) OLSse6=r(OLSse6) IV6=r(IV6) IVse6=r(IVse6)/*
*/ OLS0=r(OLS0) OLSse0=r(OLSse0) IV0=r(IV0) IVse0=r(IVse0), reps(100) 

sum OLS0 IV0 OLS1 IV1 OLS2 IV2 OLS3 IV3 OLS4 IV4  OLS5 IV5

twoway  (kdensity OLS1) (kdensity IV0) (kdensity IV1) (kdensity IV2) /*
*/ (kdensity IV3) (kdensity IV4) (kdensity IV5) (kdensity IV6), xline(-0.1)






*y=quality of children
*x1=number of children
*x2=health of mother
*z=twins
*u includes unobserved parental preferences, correlated negatively with number 
***of children.

scalar rho_ux1 = -0.5
scalar rho_ux2 = 0
scalar rho_x1x2 = 0.05
scalar rho_zx1 = 0.8
scalar rho_zx2 = 0.15
scalar rho_zu = 0
matrix cov_mata = (1, rho_ux1, rho_ux2, rho_zu \ rho_ux1,  1, rho_x1x2, rho_zx1 \/*
*/ rho_ux2, rho_x1x2, 1, rho_zx2 \ rho_zu, rho_zx1, rho_zx2, 1)
drawnorm ua x1a x2a za, cov(cov_mata)

scalar bx1 = -0.1
scalar bx2 = 0.2
gen ya = bx1*x1a + bx2*x2a + u
reg ya x1a x2a
test _cons=x1a+0.1=x2a+0.2=0

ivregress 2sls ya x2a (x1a=za)
test _cons=x1a+0.1=x2a+0.2=0


reg ya x1a
test _cons=x1a+0.1

ivregress 2sls ya (x1a=za)
test _cons=x1a+0.1













*y=quality of children
*x=number of children
*z=twins
*u includes unobserved parental preferences, correlated negatively with number 
***of children. Now u also includes maternal health, which IS correlated 
***(positively) with the instrument (twinning) 

*y = 0 - 0.1x + u 
*x = 2 + 0.8z + v  
scalar rho_ux2 = -0.4
scalar rho_zx2 = 0.8
scalar rho_zu2 = 0.1
matrix cov_mat2 = (1, rho_ux2, rho_zu2 \ rho_ux2,  1, rho_zx2 \ rho_zu2, rho_zx2, 1)
drawnorm u2 x2 z2, cov(cov_mat2)

scalar bx2 = -0.1
gen y2 = bx2*x2 + u
reg y2 x2
test _cons=x2+0.1=0

ivregress 2sls y2 (x2=z2)
test _cons=x2+0.1=0

end

simulate IV_simul, reps(1000)

gen x=runiform()
replace x=0 if x>0.015
replace x=1 if x!=0

** z takes value of 0 98.5% of the time, 1 1.5% of the time
** u and v are standard normals with 

