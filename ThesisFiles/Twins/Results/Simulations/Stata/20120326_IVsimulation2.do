/* IV_simulation 2.00                  UTF-8                       dh:2012-03-26
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/
cap program drop IVsim
program define IVsim, rclass

clear
set obs 100000

*y=quality of children
*x=number of children (1-5)
*z=twins (0,1)
*u includes unobserved parental preferences, correlated negatively with number
***of children

*y = 12 - x + u
*x = w + 0.8z - 0.5u
*z = 0,1 INCORPORATE COVARIANCE WITH u 

gen z = uniform() < 0.025
gen w = 1 + int(5*uniform())
drawnorm u

scalar b_x0=12
scalar b_x1=-1
scalar b_z1=0.8
scalar b_z2=-0.5

gen x = w + b_z1*z - b_z2*u
gen y = 12 - x + u

reg y x
return scalar OLS=_b[x]
return scalar OLSse=_se[x]

ivreg2 y (x=z)
return scalar IV=_b[x]
return scalar IVse=_se[x]

end

simulate IVsim OLS=r(OLS) OLSse=r(OLSse) IV=r(IV) IVse=r(IVse), reps(100)
twoway (kdensity IV) || (kdensity OLS)
