for bias=0:2

n=10000;
sigma=1;
rho_ux=0.5;
rho_uz=0+bias/10;
rho_zx=0.8;

CovMat = sigma.^2.*[1 rho_ux rho_uz; rho_ux 1 rho_zx ; rho_uz rho_zx 1]
SIMUL_est=zeros(1000,4);

for k=1:1000
RV = mvnrnd([0 0 0], CovMat, n);
plot3(RV(:,1),RV(:,2),RV(:,3),'.');
grid on; view([-4, 4]);
xlabel('u'); ylabel('x'); zlabel('z');

bx = -0.1;
y = bx.*RV(:,2) + RV(:,1);

[b,bint]=regress(y,RV(:,2));

%OLS
B=inv(RV(:,2)'*RV(:,2))*(RV(:,2)'*y)
 u=y-RV(:,2)*B;
 r2=1-cov(u)/cov(y);
 V=cov(u)*inv(RV(:,2)'*RV(:,2));
 se=sqrt(diag(V));
B-1.96*se;
B+1.96*se;

%IV REG
xPz=RV(:,2)'*RV(:,3)*inv(RV(:,3)'*RV(:,3))*RV(:,3)';
BIV=(xPz*RV(:,2))\(xPz*y)

SIMUL_est(k,1)=B;
SIMUL_est(k,2)=se;
SIMUL_est(k,3)=BIV;
end
OLS_bias=SIMUL_est(:,1);
IV_bias=SIMUL_est(:,3);
end


[pdfOLS OLSi]= ksdensity(OLS);
[pdfIV IVi]= ksdensity(IV);
%[OLS1i,IV1i]     = meshgrid(OLSi,IVi);
%[pdfOLS1,pdfIV1] = meshgrid(pdfOLS,pdfIV);

plot(OLS_0i, pdfOLS_0, IV_0i, pdfIV_0, IV_1i, pdfIV_1, IV_2i, pdfIV_2)
