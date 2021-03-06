capt prog drop myttests

*! version 1.0.0  abril 3, 2014 @ 10:51:57
program myttests, eclass
	version 8
	syntax varlist [if] [in], by(varname) [ * ]
	marksample touse
	markout `touse' `by'
	tempname mu_1 mu_2 d d_se d_t d_p
	foreach var of local varlist {
		qui ttest `var' if `touse', by(`by') `options'
		mat `mu_1' = nullmat(`mu_1'), r(mu_1)
		mat `mu_2' = nullmat(`mu_2'), r(mu_2)
		mat `d'    = nullmat(`d'   ), r(mu_1)-r(mu_2)
		mat `d_se' = nullmat(`d_se'), r(se)
		mat `d_t'  = nullmat(`d_t' ), r(t)
		mat `d_p'  = nullmat(`d_p' ), r(p)
	}
	foreach mat in mu_1 mu_2 d d_se d_t d_p {
		mat coln ``mat'' = `varlist'
	}
	tempname b V
	mat `b' = `mu_1'*0
	mat `V' = `b''*`b'
	eret post `b' `V'
	eret local cmd "myttests"
	foreach mat in mu_1 mu_2 d d_se d_t d_p {
		eret mat `mat' = ``mat''
	}

end
