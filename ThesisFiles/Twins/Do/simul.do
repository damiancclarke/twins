
capture program drop kls
program define kls, rclass

clear
set obs 1000
scalar rho_ux = 0.3
scalar rho_zx = 0.2
scalar rho_zu = 0
matrix COV1 = (1, rho_ux, rho_zu \ rho_ux,  1, rho_zx \ rho_zu, rho_zx, 1)
drawnorm u x z, cov(COV1)
*replace x = x>0
su x
scalar sig_x = sqrt(r(Var))
*scalar rho_ux = normalden(0)/normal(0)*rho_ux

scalar bx = 0.2
scalar b_z = 0.05
scalar b0 = 0.3

gen y = b0 + bx*x + b_z*z + u
gen i = 1

regress y x z
return scalar b_ls = _b[x]
return scalar bz_ls = _b[z]
matrix b = e(b)'
scalar rss = e(rss)

regress y z
scalar r2 = e(r2)

mkmat x z i, mat(X)
mkmat z i, mat(Z)

scalar rho_kls2 = 0.4
scalar rho_kls1 = 0.1

scalar sig_u = sqrt(1/(1 - rho_ux^2*(1-r2))*rss/e(N))
scalar sig_u1 = sqrt(1/(1 - rho_kls1^2*(1-r2))*rss/e(N))
scalar sig_u2 = sqrt(1/(1 - rho_kls2^2*(1-r2))*rss/e(N))



matrix correct = e(N)*inv(X'*X)*(rho_ux*sig_x*sig_u, 0, 0)'
matrix b_ = b - correct
return scalar b_kls = b_[1,1]
return scalar bz_kls = b_[2,1]
gen Eu2 = (y - b0 - b_[1,1]*x - b_[2,1]*z)^2
su Eu2, meanonly
return scalar sig2 = r(mean) 

matrix correct1 = e(N)*inv(X'*X)*(rho_kls1*sig_x*sig_u1, 0, 0)'
matrix b1 = b - correct1
return scalar b_kls1 = b1[1,1]
return scalar bz_kls1 = b1[2,1]

matrix correct2 = e(N)*inv(X'*X)*(rho_kls2*sig_x*sig_u2, 0, 0)'
matrix b2 = b - correct2
return scalar b_kls2 = b2[1,1]
return scalar bz_kls2 = b2[2,1]


ivregress 2sls y (x = z)
return scalar b_iv = _b[x]

end

simulate kls b = r(b) b_z = r(b_z) b_ls = r(b_ls) b_iv = r(b_iv) b_kls = r(b_kls) b_kls1 = r(b_kls1) b_kls2 = r(b_kls2) bz_ls = r(bz_ls) bz_kls = r(bz_kls) bz_kls1 = r(bz_kls1) bz_kls2 = r(bz_kls2) sig2 = r(sig2), reps(100) 

gen mse_ls = (b_ls - bx)^2
gen mse_iv = (b_iv - bx)^2
gen mse_kls = (b_kls - bx)^2
gen mse_kls1 = (b_kls1 - bx)^2
gen mse_kls2 = (b_kls2 - bx)^2
gen mse_lsz = (bz_ls - b_z)^2
gen mse_klsz = (bz_kls - b_z)^2
gen mse_klsz1 = (bz_kls1 - b_z)^2
gen mse_klsz2 = (bz_kls2 - b_z)^2
sum

twoway (kdensity b_kls) (kdensity b_kls2) (kdensity b_kls1) (kdensity b_iv) (kdensity b_ls)

/*
twoway (kdensity bz_kls) (kdensity bz_kls2) (kdensity bz_kls1) (kdensity bz_ls)
*/
