# run normal sampler on margarine data
#
source("c:\\userdata\\per\\res\\p exog vars\\Normal Sampler\\rivGibbspe_suff.R")
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

#
# undertake a series of runs with different prior settings
#
nlevel=10
priorstd_gamma=c(seq(from=.001,to=1,length=nlevel))
alpha=.05
probs=c(alpha/2,1-alpha/2)
confint=matrix(0,ncol=2,nrow=nlevel)
for(i in 1:nlevel){
   Abg=diag(c(.01,rep(.01,ncol(w)),c(rep(1/(priorstd_gamma[i]**2),ncol(z)))))
   Mcmc=list(); Prior=list(nu=0,Abg=Abg); Data = list()
   Data$z = z; Data$w=w; Data$x=x; Data$y=y
   Mcmc$R=100000;  
   out=rivGibbspe_suff(Data=Data,Prior=Prior,Mcmc=Mcmc)
   begin=1000
   confint[i,]=quantile(out$betadraw[begin:Mcmc$R],probs=probs)
}

matplot(priorstd_gamma,confint,col=c(2,2),lty=c(1,1),type="l",ylab="",lwd=1.5)

write(t(cbind(priorstd_gamma,confint)),file="marg_gammaprior.txt")


