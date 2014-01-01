n=10000;
sigma=1;
rho=0.7;
SigmaInd = sigma.^2.*[1 rho; rho 1]

XInd = mvnrnd([0,0], SigmaInd, n);
plot(XInd(:,1), XInd(:,2),'.'); axis equal; axis([-3 3 -3 3]);
xlabel('X1'); ylabel('X2')


subplot(1,1,1);
n = 1000;
Rho = [1 .4 .2; .4 1 -.8; .2 -.8 1];
Z = mvnrnd([0 0 0], Rho, n);
U = normcdf(Z,0,1);
X = [U(:,1) U(:,2) U(:,3)];
plot3(X(:,1),X(:,2),X(:,3),'.');
grid on; view([-55, 15]);
xlabel('U1'); ylabel('U2'); zlabel('U3');

tauTheoretical = 2.*asin(Rho)./pi
tauSample = corr(X, 'type','Kendall')