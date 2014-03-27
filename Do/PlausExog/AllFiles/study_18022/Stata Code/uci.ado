************************************************************************
* uci.ado                                                            *
*
*	Does a union of confidence intervals							*
************************************************************************
************************************************************************
*  To invoke this command type:                                        *
*	>>uci depvar (endogenouslist covariatelist=instrumentlist covariatelist) [if] [in], 
*		g1min()	g1max()	g2min() g2max() ... grid() inst(instrumentlist) [level()]
*		[cluster()] [robust]				       *
************************************************************************


program define uci
#delimit ;

syntax [anything(name=0)] [if] [in], [Robust CLuster(varname) inst(varlist) g1min(real -.1) g1max(real .1) g2min(real -.1) g2max(real .1) g3min(real -.1) g3max(real .1) g4min(real -.1) g4max(real .1) g5min(real -.1) g5max(real .1) g6min(real -.1) g6max(real .1) level(real .95) grid(real 2)]; 



gettoken Y 0 : 0;

quietly ivreg `Y' `0', `robust' cl(`cluster');


local instlist `inst';
local indeplist `e(instd)';
local indeplist2 `e(insts)';

local inst : word count of `instlist';
local xreg : word count of `indeplist';
local xreg2: word count of `indeplist2';
local xreg =`xreg'-1;
local xreg2=`xreg2'-1;
local inst=`inst'-1;

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


local w=1;
while `w'<`inst'+1{;
local gamma`w'=.;
local w=`w'+1;
};

local w=1;
while `w'<`xreg2'+2{;
local l`w'=.;
local u`w'=.;
local w=`w'+1;
};

local k=`grid';
local l=.;
local u=.;
local a=1;
local v=1;

while `v'<(`grid'^`inst')+1{;
local w=`inst';
local R=`v'-1;

while `w'>0{;
local a`w'= floor(`R'/(`k'^((`w'-1))));
local R=`R'-(`k'^(`w'-1))*`a`w'';
local gamma`w'=`g`w'min'+((`g`w'max'-`g`w'min')/(`k'-1))*`a`w'';

local w = `w'-1;

}; 

display `gamma1';
display `gamma2';
display `gamma3';

quietly{;
tempvar Y_G cumsum;
       	
	local r=1;
	
	while `r'<`inst'+1{;
	if `r'==1{;
	gen `cumsum'=`Z1'*`gamma1';
	};
	else{;
	replace `cumsum'=`cumsum'+`Z`r''*`gamma`r'';
	};
	local r=`r'+1;
	};

	gen `Y_G'=`Y'-`cumsum';

};


quietly{;
/*IV REGRESSION STEP*/

	ivreg `Y_G' `0' `if' `in' , `robust' cl(`cluster');
	
	mat b2SLS=e(b);
	mat cov2SLS=e(V);

	mat V=diag(vecdiag(cov2SLS));

	mat cv=-invnormal((1-`level')/2);
	mat ltemp=vec(b2SLS)-cv*vec(vecdiag(cholesky(V)));
	mat utemp=vec(b2SLS)+cv*vec(vecdiag(cholesky(V)));

				/*vectors giving confidence interval*/

};					/*end quietly command*/

local z=1;
while `z'<`xreg'+2{;
local l`z'=min(`l`z'',ltemp[`z',1]);
local u`z'=max(`u`z'',utemp[`z',1]);

		
local z=`z'+1;
};






local v=`v'+1;
};

/*Output in display window*/

di in ye _newline(2)
"Results for Union of 2SLS Confidence Intervals";



di _newline	_col(20)	" number of observations=  "  _N;

di _newline "Dependent variable= `Y'";
di _newline
"Variable" _col(13) "Lower Bound" _col(29) "Upper Bound";
di 
"--------" _col(13) "-----------" _col(29) "-----------";

local z=1;

while `z'<=`xreg'{;
	
	di "`ind`z''" _col(13)  `l`z''  _col(29)   `u`z'';
local z=`z'+1;
};
local aa=`xreg'+1;
di "const" _col(13)  `l`aa''  _col(29)   `u`aa'';

end;
exit;

