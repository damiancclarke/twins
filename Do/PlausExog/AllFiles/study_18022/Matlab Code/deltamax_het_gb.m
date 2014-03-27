function [f] = deltamax_het_gb(theta,yx,dx,zx,alpha)

% b = fminsearch(@(a) ((yx - a*dx - abs(a)*zx*theta)'*zx)*inv(zx'*zx)*(zx'*(yx - a*dx - abs(a)*zx*theta)),.1,optimset('disp','off'));

dxnew = dx + zx*theta;
% dxnew = dx + zx*theta*sign(b);

M = inv((dxnew'*zx)*inv(zx'*zx)*(zx'*dxnew));
Mzx = zx'*dxnew;
Mzz = inv(zx'*zx);

b = M*Mzx'*Mzz*(zx'*yx);
e   = yx - dxnew*b;
% e = yx - b*dx - abs(b)*zx*theta;
V2  = hetero(zx,e);
VC2 = M*Mzx'*Mzz*V2*Mzz*Mzx*M;

f = -b+norminv(alpha/2)*sqrt(VC2);
