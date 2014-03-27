# run normal sampler with prior on gamma| beta on 401K data
#
source("c:\\userdata\\per\\res\\p exog vars\\Normal Sampler\\rivGibbspe_suff_sbeta.R")
ex_401k=read.table("ex_401k.txt")
y=as.vector(ex_401k[,1])
x=as.vector(ex_401k[,2])
z=matrix(ex_401k[,3],ncol=1)
w=as.matrix(ex_401k[,4:ncol(ex_401k)])
w=cbind(c(rep(1,length(y))),w)

#
# undertake a series of runs with different prior settings
#
sy=sqrt(var(y))
y=y/sy
nlevel=10
prior_k=c(seq(from=.001,to=.25,length=nlevel))
alpha=.05
probs=c(alpha/2,1-alpha/2)
confint=matrix(0,ncol=2,nrow=nlevel)
for(i in 1:10){
   Mcmc=list(); Prior=list(nu=0,k=prior_k[i]); Data = list()
   Data$z = z; Data$w=w; Data$x=x; Data$y=y
   Mcmc$R =51000;  
   out=rivGibbspe_suff_sbeta(Data=Data,Prior=Prior,Mcmc=Mcmc)
   begin=1000
   confint[i,]=quantile(sy*out$betadraw[begin:Mcmc$R],probs=probs)
}

matplot(prior_k,confint,col=c(2,2),lty=c(1,1),type="l",ylab="",lwd=1.5)

write(t(cbind(prior_k,confint)),file="ex_401k_gamma_beta_prior.txt")


