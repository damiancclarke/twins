%IV SIMULATION SCRIPT WITH TWINNING EXOGENOUS AND THEN BIASED TO
%VARIOUS DEGREES

SIMUL_VEC = zeros(61,8);

for k=0:60
k    
SIMUL_VECOLS=zeros(100:3);
SIMUL_VECIV=zeros(100:3);
for reps=1:100    
n=10000;
sigma=1;
rho_ux=0.5;
rho_uz=0+k/100;
rho_zx=0.8;

%DEFINE COVARIANCE MATRIX AND MATRIX FOR SIMULATION
CovMat = sigma.^2.*[1 rho_ux rho_uz; rho_ux 1 rho_zx ; rho_uz rho_zx 1];

%%GENERATE CORRELATED RANDOM NORMAL ERROR TERMS
%%Set seed
%defaultStream = RandStream.getDefaultStream()
%savedState = defaultStream.State;
%whos savedState
%defaultStream.State = savedState;
%%Gen RV
RV = mvnrnd([0 0 0], CovMat, n);
plot3(RV(:,1),RV(:,2),RV(:,3),'.');
grid on; view([-4, 4]);
%xlabel('\epsilon_1'); ylabel('\epsilon_2'); zlabel('\epsilon_3')

%MODEL
%educ = 12 - sibship + \epsilon_1
%sibship = 7 or 6 or 5 or 4 or 3 or 2 or 1 (z is a covariate)
    %sibship = gamma_0 + gamma1*z + \epsilon2
%z=1[alpha_0 + \epsilon_3>0]
B1 = 12;
B2 = -0.05;
G0 = 2;
G1 = 0.8;
A0 = -1.96;

X=ones(10000,2);

z_star = A0 + RV(:,3)
for c=1:10000
    if z_star(c,1)>0;
            z(c,1)=1;
    else    z(c,1)=0;
    end
end
    
Z=zeros(10000,2);
Z(:,2)=z(:,1);

r=randi(5,10000,1);
Z(:,1)=r+3;
X(:,2) = Z(:,1) + G1*Z(:,2) + RV(:,2);

y = 12*X(:,1) + B2*X(:,2) + RV(:,1);
%end



%NOW CALCULATE OLS AND IV:
B=inv(X'*X)*(X'*y);
u=y-X(:,2)*B2-X(:,1);
r2=1-cov(u)/cov(y);
V=cov(u)*inv(X'*X);
se=sqrt(diag(V));
MIN_OLS=B-1.96*se;
MAX_OLS=B+1.96*se;

SIMUL_VECOLS(reps,1)=B(2,1);
SIMUL_VECOLS(reps,2)=MAX_OLS(2,1);
SIMUL_VECOLS(reps,3)=MIN_OLS(2,1);
BOLS=mean(SIMUL_VECOLS(reps,1));
BMAXOLS=mean(SIMUL_VECOLS(reps,2));
BMINOLS=mean(SIMUL_VECOLS(reps,3));


XPZ=X'*Z*inv(Z'*Z)*Z';
BIV=(XPZ*X)\(XPZ*y);
u_iv=y-X*BIV;
V_iv=cov(u_iv)*inv(XPZ'*XPZ);
se_iv=sqrt(diag(V_iv));
MIN_IV=BIV-1.96*se_iv;
MAX_IV=BIV+1.96*se_iv;

SIMUL_VECIV(reps,1)=BIV(2,1);
SIMUL_VECIV(reps,2)=MAX_IV(2,1);
SIMUL_VECIV(reps,3)=MIN_IV(2,1);
BIV2=mean(SIMUL_VECIV(reps,1));
BMAXIV=mean(SIMUL_VECIV(reps,2));
BMINIV=mean(SIMUL_VECIV(reps,3));

end

SIMUL_VEC(k+1,1) = 0+k/100;
SIMUL_VEC(k+1,2) = B2;
SIMUL_VEC(k+1,3) = BMINOLS;
SIMUL_VEC(k+1,4) = BOLS;
SIMUL_VEC(k+1,5) = BMAXOLS;
SIMUL_VEC(k+1,6) = BMINIV;
SIMUL_VEC(k+1,7) = BIV2;
SIMUL_VEC(k+1,8) = BMAXIV;


end
SIMUL_VEC

plot(SIMUL_VEC(:,1), SIMUL_VEC(:,2))
hold all
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,3))
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,4))
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,5))
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,6))
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,7))
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,8))
legend('\beta=-1','\beta_{OLS}', '\beta_{IV}', 'Location','NorthWest')
axis([0 0.6 -1.1 -0.3])
xlabel('Cov(\epsilon_1 \epsilon_3)','FontSize',14)
ylabel('E[\beta]','FontSize',14)
title(['\fontsize{16} E[Simulated Family Size] with Invalid Exclusion Restriction', ...
       '\newline \fontsize{12} ']);
hold off
