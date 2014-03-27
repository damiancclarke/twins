# run normal sampler on ak data
#
source("c:\\userdata\\per\\res\\p exog vars\\Normal Sampler\\rivGibbspe_suff.R")
ak=read.table("akdata.txt")
y=as.vector(ak[,1])
x=as.vector(ak[,2])
qtr1=ifelse(ak[,5]==1,1,0)
qtr2=ifelse(ak[,5]==2,1,0)
qtr3=ifelse(ak[,5]==3,1,0)
#
# put state and year dummies in w
#
w=matrix(0,nrow=length(y),ncol=(50+9+1))
for(i in 1:50){w[,i+1]=ifelse(ak[,4]==i,1,0)}
for(i in 1:9){w[,i+51]=ifelse(ak[,3]==i,1,0)}
w[,1]=c(rep(1,length(y)))
z=cbind(qtr1,qtr2,qtr3)
#
# undertake a series of runs with different prior settings
#
nlevel=10
priorstd_gamma=c(seq(from=.0001,to=.01,length=nlevel))
alpha=.05
probs=c(alpha/2,1-alpha/2)
confint=matrix(0,ncol=2,nrow=nlevel)
for(i in 1:nlevel){
   Abg=diag(c(.01,rep(.01,ncol(w)),c(rep(1/(priorstd_gamma[i]**2),ncol(z)))))
   Mcmc=list(); Prior=list(Abg=Abg); Data = list()
   Data$z = z; Data$w=w; Data$x=x; Data$y=y
   Mcmc$R =5000000 ;keep=500 ; Mcmc$keep=keep
   out=rivGibbspe_suff(Data=Data,Prior=Prior,Mcmc=Mcmc)
   begin=100000
   confint[i,]=quantile(out$betadraw[(begin/keep):(Mcmc$R/keep)],probs=probs)
}

matplot(priorstd_gamma,confint,col=c(2,2),lty=c(1,1),type="l",ylab="",lwd=1.5)
write(t(cbind(priorstd_gamma,confint)),file="ak_gammaprior.txt")

