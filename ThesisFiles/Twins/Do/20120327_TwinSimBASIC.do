clear
set obs 10000
*y=quality of children
*x=number of children
*z=twins
*u includes unobserved parental preferences, correlated negatively with number
***of children

*y = 0 - 0.1x + u  
*x = 2 + 0.8z + v  
scalar rho_ux = .5
scalar rho_zx = 0.5
scalar rho_zu = 0
matrix cov_mat = (1, rho_ux, rho_zu \ rho_ux,  1, rho_zx \ rho_zu, rho_zx, 1)
set seed 1001
drawnorm u x z, cov(cov_mat)

scalar bx = -0.1
gen y = bx*x + u

reg y x
return scalar OLS`bias'=_b[x`bias']
return scalar OLSse`bias'=_se[x`bias']

ivregress 2sls y`bias' (x`bias'=z`bias')
return scalar IV`bias'=_b[x`bias']
return scalar IVse`bias'=_se[x`bias']
