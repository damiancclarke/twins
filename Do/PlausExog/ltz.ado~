

************************************************************************/
* ltz.ado                                                            */
*
*		Local to Zero Approximation				*/
************************************************************************/
************************************************************************/
*  To invoke this command type:                                        */
*	>>ltz var_matrix_for_gamma mean_vector_for_gamma depvar
*			(endogenouslist covariatelist=instrumentlist covariatelist) 
*			[if] [in], [level()] [cluster()] [robust]*/
************************************************************************/
program define ltz
#delimit ;




syntax [anything(name=0)] [if] [in], [level(real .95) Robust CLuster(varname)]; 

gettoken omega 0 : 0;
gettoken mu 0 : 0;
gettoken Y 0 : 0;


quietly ivreg `Y' `0' `if' `in',`robust' cl(`cluster');
local instlist `e(insts)';



local indeplist `e(instd)';

local inst : word count of `instlist';
local xreg : word count of `indeplist';
local xreg=`xreg'-1;
local inst=`inst'-1;
tempvar const;
gen `const' = 1;



local a=1;

while `a'<=`inst'{;
	
	gettoken Z`a' instlist: instlist;
	
	local a=`a'+1;
};			

local a=1;

while `a'<=`xreg'{;
	
	gettoken ind`a' indeplist: indeplist;
	
	local a=`a'+1;
};

local instlist `e(insts)';
local indeplist `e(instd)';


mat vecaccum a = `Z1' `indeplist' `if' `in';   /*create moment matrix MZX*/
mat MZX = a;
local i=2;
while `i'<=`inst'{;
mat vecaccum a = `Z`i'' `indeplist' `if' `in';
mat MZX = MZX\a;
local i=`i'+1;
};
mat vecaccum a = `const' `indeplist' `if' `in';
mat MZX = MZX\a;

mat vecaccum a = `Z1' `instlist' `if' `in';    /*create moment matrix MZZ*/
mat MZZ = a;
local i=2;
while `i'<=`inst'{;
mat vecaccum a = `Z`i'' `instlist' `if' `in';
mat MZZ = MZZ\a;
local i=`i'+1;
};
mat vecaccum a = `const' `instlist' `if' `in';
mat MZZ = MZZ\a;

mat V = e(V)+inv(MZX'*inv(MZZ)*MZX)*MZX'*`omega'*MZX*inv(MZX'*inv(MZZ)*MZX);

mat b = e(b)-(inv(MZX'*inv(MZZ)*MZX)*MZX'*`mu')';

	mat cv=-invnormal((1-`level')/2);
	mat ltemp=b-vecdiag(cholesky(diag(vecdiag(V))))*cv;
	mat utemp=b+vecdiag(cholesky(diag(vecdiag(V))))*cv;

				/*vectors giving confidence interval*/

/*Output in display window*/

di in ye _newline(2)
"Results For Local To Zero Approximation";



di _newline	_col(20)	" number of observations=  "  _N;

di _newline "Dependent variable= `Y'";
di _newline
"Variable" _col(13) "Point Estimate" _col(29) "Confidence Interval";
di 
"--------" _col(13) "-----------" _col(29) "-----------------------------";

local z=1;

while `z'<=`xreg'{;
	
	di "`ind`z''" _col(13)  b[1,`z'] _col(29) "[" ltemp[1,`z']  _col(43)   utemp[1,`z'] "]";
local z=`z'+1;
};
local aa=`xreg'+1;
di "const" _col(13) b[1,`xreg'+1] _col(29) "[" ltemp[1,`xreg'+1]  _col(43)   utemp[1,`xreg'+1] "]";

end;
exit;