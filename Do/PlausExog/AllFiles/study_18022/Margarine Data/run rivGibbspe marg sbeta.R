# run normal sampler on margarine data
#
source("c:\\userdata\\per\\res\\p exog vars\\Normal Sampler\\rivGibbspe_suff_sbeta.R")
marg=read.table("margarine.txt")
y=as.vector(marg[,1])
x=as.vector(marg[,2])
z=matrix(marg[,3],ncol=1)
w=as.matrix(marg[,5:ncol(marg)])
w=cbind(c(rep(1,length(y))),w)

nobs=nrow(marg)

nlags=6
z=matrix(marg[(nlags+1):nobs,3],ncol=1)
for(i in 1:nlags){
z=cbind(z,marg[(nlags+1-i):(nobs-i),3])
}

y=y[(nlags+1):nobs]
x=x[(nlags+1):nobs]
w=w[(nlags+1):nobs,]

#
# compute 2SLS for the model X=ZPI + v; Y=XB + E; 
#
if(0){
X=cbind(x,w)
Z=cbind(z,w)
Y=matrix(y,ncol=1)
tsls(X,Z,Y)
}


nlevel=10
prior_k=c(seq(from=.001,to=.15,length=nlevel))
alpha=.05
probs=c(alpha/2,1-alpha/2)
confint=matrix(0,ncol=2,nrow=nlevel)

fn="marg_gamma_beta_prior.txt"
for(i in 1:10){
   Mcmc=list(); Prior=list(nu=0,k=prior_k[i]); Data = list()
   Data$z = z; Data$w=w; Data$x=x; Data$y=y
   Mcmc$R =2000000;  keep=100; Mcmc$keep=keep
   out=rivGibbspe_suff_sbeta(Data=Data,Prior=Prior,Mcmc=Mcmc)
   begin=100000
   confint[i,]=quantile(out$betadraw[(begin/keep):(Mcmc$R/keep)],probs=probs)
   if(i==1){write(c(prior_k[i],confint[i,]),file=fn)}
   else
   {write(c(prior_k[i],confint[i,]),file=fn,append=TRUE)}
}

matplot(prior_k,confint,col=c(2,2),lty=c(1,1),type="l",ylab="",lwd=1.5)




