%IV SIMULATION SCRIPT WITH TWINNING EXOGENOUS AND THEN BIASED TO
%VARIOUS DEGREES

n=10000;
sigma=1;
rho_ux=0.5;
rho_uz=0;
rho_zx=0.8;

%DEFINE COVARIANCE MATRIX AND MATRIX FOR SIMULATION
CovMat = sigma.^2.*[1 rho_ux rho_uz; rho_ux 1 rho_zx ; rho_uz rho_zx 1]
SIMUL_est=zeros(1000,4);

%GENERATE CORRELATED RANDOM NORMAL ERROR TERMS
%for k=1:1000
RV = mvnrnd([0 0 0], CovMat, n);
plot3(RV(:,1),RV(:,2),RV(:,3),'.');
grid on; view([-4, 4]);
xlabel('\epsilon_1'); ylabel('\epsilon_2'); zlabel('\epsilon_3')


%educ = 12 - sibship + \epsilon_1
%sibship = 7 or 6 or 5 or 4 or 3 or 2 or 1 (z is a covariate)
    %sibship = gamma_0 + gamma1*z + \epsilon2
%z=1[alpha_0 + \epsilon_3>0]
B1 = 12;
B2 = -1;
G0 = 2;
G1 = 0.8;
A0 = -1.96;

X=ones(10000,2);

z_star = A0 + RV(:,3)
for c=1:10000
    if z_star(c,1)>0
            z(c,1)=1;
    else    z(c,1)=0;
    end
end
    
x=zeros(10000,1);


x_star = G0 + G1*z + RV(:,2)

for c=1:10000
    if x_star(c,1)<0
       X(c,2)=1;
    elseif x_star(c,1)>=0 & x_star(c,1)<1
       X(c,2)=2;
    elseif x_star(c,1)>=1 & x_star(c,1)<2
       X(c,2)=3;
    elseif x_star(c,1)>=2 & x_star(c,1)<3
       X(c,2)=4;
    elseif x_star(c,1)>=3 & x_star(c,1)<4
        X(c,2)=5;
    elseif x_star(c,1)>=4 & x_star(c,1)<5
        X(c,2)=6;
    else X(c,2)=7;
    end
end

y = 12*X(:,1) + B2*X(:,2) + RV(:,1)
%end



%NOW CALCULATE OLS AND IV:
B=inv(X'*X)*(X'*y)
% u=y-X(:,2)*B2-X(:,1);
% r2=1-cov(u)/cov(y);
% V=cov(u)*inv(X'*X);
% se=sqrt(diag(V));
%B-1.96*se;
%B+1.96*se;

XPz=X'*z*inv(z'*z)*z';
BIV=(XPz*X)\(XPz*y)


