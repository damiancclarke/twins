function [f,g,h] = alphafunc_cons(b,theta,A,K)

k = size(theta,1);

LAMBDA = exp(b)/(1 + exp(b));
f = A*LAMBDA;
g = zeros(k,1);
h = zeros(k,k);

