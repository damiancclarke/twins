# run normal sampler on 401K data
#
source("c:\\userdata\\per\\res\\p exog vars\\Normal Sampler\\rivGibbspe_suff.R")
ex_401k=read.table("ex_401k.txt")
y=as.vector(ex_401k[,1])
x=as.vector(ex_401k[,2])
z=matrix(ex_401k[,3],ncol=1)
w=as.matrix(ex_401k[,4:ncol(ex_401k)])
w=cbind(c(rep(1,length(y))),w)

#
# compute 2SLS for the model X=Z%*%PI + v; Y=XB + E; 
#
X=cbind(x,w)
Z=cbind(z,w)
Y=matrix(y,ncol=1)
tsls(X,Z,Y)


#
# undertake a series of runs with different prior settings
#
sy=sqrt(var(y))
y=y/sy
nlevel=10
priorstd_gamma=c(seq(from=.0001/sy,to=5000/sy,length=nlevel))
alpha=.05
probs=c(alpha/2,1-alpha/2)
confint=matrix(0,ncol=2,nrow=nlevel)
for(i in 1:10){
   Abg=diag(c(.01,rep(.01,ncol(w)),(1/(priorstd_gamma[i]**2))))
   Mcmc=list(); Prior=list(nu=0,Abg=Abg); Data = list()
   Data$z = z; Data$w=w; Data$x=x; Data$y=y
   Mcmc$R =51000;  
   out=rivGibbspe_suff(Data=Data,Prior=Prior,Mcmc=Mcmc)
   begin=1000
   confint[i,]=quantile(sy*out$betadraw[begin:Mcmc$R],probs=probs)
}

matplot(priorstd_gamma*sy,confint,col=c(2,2),lty=c(1,1),type="l",ylab="",lwd=1.5)

write(t(cbind(priorstd_gamma*sy,confint)),file="ex_401k_gammaprior.txt")


