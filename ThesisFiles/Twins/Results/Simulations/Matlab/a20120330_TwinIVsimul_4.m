%IV SIMULATION SCRIPT WITH TWINNING EXOGENOUS AND THEN BIASED TO
%VARIOUS DEGREES

SIMUL_VEC = zeros(51,4);

for k=0:50
k    
SIMUL_VECOLS=zeros(100:1);
SIMUL_VECIV=zeros(100:1);
for reps=1:100
n=1000; 
sigma=1;
rho_ux=-0.3;
rho_uz=0-k/100;
rho_zx=0.85;  %This was 0.65 before.  0.65 gives 0.21 cov between z and x (I want higher)

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

X=ones(1000,2);

z=zeros(1000,1);
z_star = A0 + RV(:,3)
for c=1:1000
    if z_star(c,1)>0;
            z(c,1)=1;
    else    z(c,1)=0;
    end
end
    
Z=zeros(1000,2);
Z(:,2)=z(:,1);

r=randi(5,1000,1);
Z(:,1)=r+3;
X(:,2) = Z(:,1) + G1*Z(:,2) + RV(:,2);

y = 12*X(:,1) + B2*X(:,2) + RV(:,1);
%end



%NOW CALCULATE OLS AND IV:
B=inv(X'*X)*(X'*y);
SIMUL_VECOLS(reps,1)=B(2,1);
confint_OLS=sort(SIMUL_VECOLS)
BOLS=mean(SIMUL_VECOLS);
% u=y-X(:,2)*B2-X(:,1);
% r2=1-cov(u)/cov(y);
% V=cov(u)*inv(X'*X);
% se=sqrt(diag(V));
%B-1.96*se;
%B+1.96*se;

XPZ=X'*Z*inv(Z'*Z)*Z';
BIV=(XPZ*X)\(XPZ*y);
SIMUL_VECIV(reps,1)=BIV(2,1);
BIV2=mean(SIMUL_VECIV);
confint_IV=sort(SIMUL_VECIV);

coef=corrcoef([RV(:,1),X(:,2),Z(:,2)]);
C(reps,1)=coef(1,3)
C_uz=mean(C)
end
%NOTE: THIS IS 90% CONFIDENCE INTERVAL. SCALE UP (?) AND TIGHTEN BAND
SIMUL_VEC(k+1,1) = 0+k/100;
SIMUL_VEC(k+1,2) = B2;
SIMUL_VEC(k+1,3) = confint_OLS(5,1)
SIMUL_VEC(k+1,4) = BOLS;
SIMUL_VEC(k+1,5) = confint_OLS(95,1)
SIMUL_VEC(k+1,6) = confint_IV(5,1)
SIMUL_VEC(k+1,7) = BIV2;
SIMUL_VEC(k+1,8) =confint_IV(95,1)
SIMUL_VEC(k+1,9) = C_uz
end
SIMUL_VEC

plot(SIMUL_VEC(:,1), SIMUL_VEC(:,2),':+','LineWidth',2)
hold all
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,4),':o','LineWidth',2)
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,7),':x','LineWidth',2)
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,3),'k:','LineWidth',2)
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,5),'k:','LineWidth',2)
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,6),'k:','LineWidth',2)
plot(SIMUL_VEC(:,1), SIMUL_VEC(:,8),'k:','LineWidth',2)
h_legend=legend('\beta=-0.05','\beta_{OLS}', '\beta_{IV}', 'Location','SouthWest')
set(h_legend,'FontSize',16);
axis([0 0.501 -0.7 0.1])
xlabel('Cov(\epsilon_1 \epsilon_3)','FontSize',18)
ylabel('E[\beta]','FontSize',18)
title(['\fontsize{22} E[Simulated Family Size] with Invalid Exclusion Restriction']);
hold off

c=corrcoef([RV(:,1),X(:,2),Z(:,2)])

%THEN TRY SAME AS ABOVE BUT WITH DIFFERENT X-AXIS (SIMUL_VEC(:,9))