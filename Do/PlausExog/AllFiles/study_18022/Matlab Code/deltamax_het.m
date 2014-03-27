function [f,g,h] = deltamax2(theta,y,X,Z,z,Mxz,Mzz,M,A,B,K,alphafunc)

n = size(y,1);
k = size(X,2);
D = z*theta;

[alpha,ga,ha] = feval(alphafunc,B,theta,A,K);

b = M*Mxz*Mzz*(Z'*(y - D));
e = y - D - X*b;
S = hetero(Z,e);
V = M*Mxz*Mzz*S*Mzz*Mxz'*M;

f  = b(1,1) + sqrt(V(1,1))*norminv(1-alpha);

db = -M*Mxz*Mzz*(Z'*z);
for i = 1:size(z,2),
    TEMP = -2*((Z.*((e.*z(:,i))*ones(1,size(Z,2))))'*Z);
    TEMP = M*Mxz*Mzz*TEMP*Mzz*Mxz'*M;
    dS(i,1) = TEMP(1,1);
    for j = 1:size(z,2),
        TEMP = 2*((Z.*((z(:,j).*z(:,i))*ones(1,size(Z,2))))'*Z);
        d2S2(i,j) = TEMP(1,1);
    end
end
g  = [db(1,:)]' + (.5*dS/sqrt(V(1,1)))*norminv(1-alpha)...
    - (sqrt(V(1,1))/normpdf(norminv(1-alpha)))*ga;

d2b2 = 0;
h    = (.5*d2S2/sqrt(V(1,1)))*norminv(1-alpha)...
    - (.25*dS*dS'/(V(1,1)^1.5))*norminv(1 - alpha)...
    - ((.5*dS/sqrt(V(1,1)))/normpdf(norminv(1-alpha)))*ga'...
    - (sqrt(V(1,1))/(normpdf(norminv(1 - alpha))^3))*ga*ga'...
    - (sqrt(V(1,1))/normpdf(norminv(1-alpha)))*ha;

f = -f;
g = -g;
h = -h;

