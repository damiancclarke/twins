rivGibbspe_suff=
function(Data,Prior,Mcmc) 
{
#
# revision history:
#    R. McCulloch original version 2/05 
#    p. rossi 3/05 
#    p. rossi 1/06 -- fixed error in nins
#    p. rossi 1/06 -- fixed def Prior settings for nu,V
#    p. rossi 2/07 -- changes for plausibly exogeneous
#
# purpose: 
#   draw from posterior for linear I.V. model
#   with "plausibily exogenous" instruments.  
#
# Arguments:
#   Data -- list of z,w,x,y
#        y is vector of obs on lhs var in structural equation
#        x is "endogenous" var in structural eqn
#        w is matrix of obs on "exogenous" vars in the structural eqn
#        z is matrix of obs on instruments
#   Prior -- list of md,Ad,mbg,Abg,nu,V
#        md is prior mean of delta
#        Ad is prior prec
#        mbg is prior mean vector for beta,gamma
#        Abg is prior prec of same
#        nu,V parms for IW on Sigma
#
#   Mcmc -- list of R,keep 
#        R is number of draws
#        keep is thinning parameter
#
#   Output: 
#      list of draws of delta,beta,gamma and Sigma
# 
#   Model:
#
#    x=(w,z)'delta + e1
#    y=beta*x + w'gamma1 + z'gamma2 + e2
#      or 
#    y=beta*x +(w',z')gamma + e2    here z are "excluded" vars or ins
#        e1,e2 ~ N(0,Sigma)
#
#   Priors
#   delta ~ N(md,Ad^-1)
#   vec(beta,gamma1,gamma2) ~ N(mbg,Abg^-1)
#   Sigma ~ IW(nu,V)
#
#   check arguments
#
 breg_suff= function(XpX,Xpy,betabar,A) 
{
    k = length(betabar)
    IR=backsolve(chol(XpX+A),diag(k))
    return(crossprod(t(IR)) %*% (Xpy+A%*%betabar) + IR %*% rnorm(k))
}

pandterm=function(message) {stop(message,call.=FALSE)}
if(missing(Data)) {pandterm("Requires Data argument -- list of z,w,x,y")}
    if(is.null(Data$z)) {pandterm("Requires Data element z")}
    z=Data$z
    if(is.null(Data$w)) {pandterm("Requires Data element w")}
    w=Data$w
    if(is.null(Data$x)) {pandterm("Requires Data element x")}
    x=Data$x
    if(is.null(Data$y)) {pandterm("Requires Data element y")}
    y=Data$y

#
# check data for validity
#
if(!is.vector(x)) {pandterm("x must be a vector")}
if(!is.vector(y)) {pandterm("y must be a vector")}
n=length(y)
if(!is.matrix(w)) {pandterm("w is not a matrix")}
if(!is.matrix(z)) {pandterm("z is not a matrix")}
nz=ncol(z)
nw=ncol(w)
dimd=nz+nw
dimg=dimd
if(n != length(x) ) {pandterm("length(y) ne length(x)")}
if(n != nrow(w) ) {pandterm("length(y) ne nrow(w)")}
if(n != nrow(z) ) {pandterm("length(y) ne nrow(z)")}
#
# check for Prior
#
if(missing(Prior))
   { md=c(rep(0,dimd));Ad=.01*diag(dimd); 
     mbg=c(rep(0,(1+dimg))); Abg=.01*diag((1+dimg));
     nu=3; V=diag(2)}
else
   {
    if(is.null(Prior$md)) {md=c(rep(0,dimd))} 
       else {md=Prior$md}
    if(is.null(Prior$Ad)) {Ad=.01*diag(dimd)} 
       else {Ad=Prior$Ad}
    if(is.null(Prior$mbg)) {mbg=c(rep(0,(1+dimg)))} 
       else {mbg=Prior$mbg}
    if(is.null(Prior$Abg)) {Abg=.01*diag((1+dimg))} 
       else {Abg=Prior$Abg}
    if(is.null(Prior$nu)) {nu=3}
       else {nu=Prior$nu}
    if(is.null(Prior$V)) {V=nu*diag(2)}
       else {V=Prior$V}
   }
#
# check dimensions of Priors
#
if(ncol(Ad) != nrow(Ad) || ncol(Ad) != dimd || nrow(Ad) != dimd) 
   {pandterm(paste("bad dimensions for Ad",dim(Ad)))}
if(length(md) != dimd)
   {pandterm(paste("md wrong length, length= ",length(md)))}
if(ncol(Abg) != nrow(Abg) || ncol(Abg) != (1+dimg) || nrow(Abg) != (1+dimg)) 
   {pandterm(paste("bad dimensions for Abg",dim(Abg)))}
if(length(mbg) != (1+dimg))
   {pandterm(paste("mbg wrong length, length= ",length(mbg)))}
#
# check MCMC argument
#
if(missing(Mcmc)) {pandterm("requires Mcmc argument")}
else
   {
    if(is.null(Mcmc$R)) 
       {pandterm("requires Mcmc element R")} else {R=Mcmc$R}
    if(is.null(Mcmc$keep)) {keep=1} else {keep=Mcmc$keep}
   }

#
# print out model
#
cat(" ",fill=TRUE)
cat("Starting Gibbs Sampler for Linear IV Model",fill=TRUE)
cat(" ",fill=TRUE)
cat(" nobs= ",n,"; ",ncol(z)," instruments; ",ncol(w)," included exog vars",fill=TRUE)
cat("     Note: the numbers above include intercepts if in z or w",fill=TRUE)
cat(" ",fill=TRUE)
cat("Prior Parms: ",fill=TRUE)
cat("mean of delta ",fill=TRUE)
print(md)
cat("Adelta",fill=TRUE)
print(Ad)
cat("mean of beta/gamma",fill=TRUE)
print(mbg)
cat("Abeta/gamma",fill=TRUE)
print(Abg)
cat("Sigma Prior Parms",fill=TRUE)
cat("nu= ",nu," V=",fill=TRUE)
print(V)
cat(" ",fill=TRUE)
cat("MCMC parms: R= ",R," keep= ",keep,fill=TRUE)
cat(" ",fill=TRUE)

deltadraw = matrix(double(floor(R/keep)*dimd),ncol=dimd)
betadraw = rep(0.0,floor(R/keep))
gammadraw = matrix(double(floor(R/keep)*dimg),ncol=dimg)
Sigmadraw = matrix(double(floor(R/keep)*4),ncol=4)

#set initial values
Sigma=diag(2)
delta=c(rep(.1,dimd))

#
# start main iteration loop
#
cat("MCMC Iteration (est time to end -min) ",fill=TRUE)
fsh()
M=crossprod(cbind(x,w,z,y))
nx=1
ny=1
nz=ncol(z)
nw=ncol(w)
XWZpXWZ=M[1:(nx+nw+nz),1:(nx+nw+nz),drop=FALSE]
XWZpy=M[1:(nx+nw+nz),(nx+nw+nz+1):(nx+nw+nz+ny),drop=FALSE]
XWZpx=M[1:(nx+nw+nz),1:nx,drop=FALSE]
WZpWZ=M[(nx+1):(nx+nw+nz),(nx+1):(nx+nw+nz),drop=FALSE]
WZpy=M[(nx+1):(nx+nw+nz),(nx+nw+nz+1):(nx+nw+nz+ny),drop=FALSE]
WZpx=M[(nx+1):(nx+nw+nz),1:nx,drop=FALSE]
XWZpWZ=M[1:(nx+nw+nz),(nx+1):(nx+nw+nz),drop=FALSE]
xpx=M[1:nx,1:nx,drop=FALSE]
ypy=M[(nx+nw+nz+1):(nx+nw+nz+ny),(nx+nw+nz+1):(nx+nw+nz+ny),drop=FALSE]
ypx=M[(nx+nw+nz+1):(nx+nw+nz+ny),1:nx,drop=FALSE]

itime=proc.time()[3]
for(rep in 1:R) {

    # draw beta,gamma| delta, Sigma
      sig = sqrt(Sigma[2,2]-(Sigma[1,2]^2/Sigma[1,1]))
    # compute sufficient stats xtpxt and xtpyt based on original data
      xtpxt=XWZpXWZ/(sig**2)
      xtpyt=(XWZpy-(Sigma[1,2]/Sigma[1,1])*(XWZpx-XWZpWZ%*%delta))/(sig**2)
      bg=breg_suff(xtpxt,xtpyt,mbg,Abg)
      beta = bg[1]
      gamma=bg[2:length(bg)]

    # draw delta| beta gamma
      C = matrix(c(1,beta,0,1),nrow=2)
      B = C%*%Sigma%*%t(C)
      L = t(chol(B))
      Li=backsolve(L,diag(2),upper.tri=FALSE)
    # compute suff stats xtdpxt and xtpyt based on original data
      i2=matrix(c(rep(1,2)),ncol=1)
      lambda=matrix(c(1,0,0,beta),ncol=2)
      quadf=t(i2)%*%lambda%*%crossprod(Li)%*%lambda%*%i2
      xtpxt=as.vector(quadf)*WZpWZ
      xtpyt=cbind(WZpx,(WZpy-WZpWZ%*%gamma))%*%crossprod(Li)%*%lambda%*%i2
      delta=breg_suff(xtpxt,xtpyt,md,Ad)

    # draw Sigma
      S=matrix(0,ncol=2,nrow=2)
      S[1,1]=xpx - 2*crossprod(delta,WZpx) + t(delta)%*%WZpWZ%*%delta
      S[1,2]=ypx - crossprod(delta,WZpy) - beta*xpx + beta*crossprod(delta,WZpx) -
                   t(gamma)%*%WZpx + t(gamma)%*%WZpWZ%*%delta
      S[2,1]=S[1,2]
      S[2,2]=ypy - 2*beta*ypx-2*t(gamma)%*%WZpy + 2*beta*t(gamma)%*%WZpx +
                 + beta**2*xpx + t(gamma)%*%WZpWZ%*%gamma
      Sigma = rwishart(nu+n,chol2inv(chol(V+S)))$IW
  
   if(rep%%100==0)
     {
      ctime=proc.time()[3]
      timetoend=((ctime-itime)/rep)*(R-rep)
      cat(" ",rep," (",round(timetoend/60,1),")",fill=TRUE)
      fsh()
      }
   if(rep%%keep ==0)
     {
      mkeep=rep/keep
      deltadraw[mkeep,]=delta
      betadraw[mkeep]=beta
      gammadraw[mkeep,]=gamma
      Sigmadraw[mkeep,]=Sigma
      }
}
    ctime = proc.time()[3]
    cat("  Total Time Elapsed: ", round((ctime - itime)/60, 2), 
        "\n")


return(list(deltadraw=deltadraw,betadraw=betadraw,gammadraw=gammadraw,Sigmadraw=Sigmadraw))
}
