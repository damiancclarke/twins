function [ci,constraint] = pw_interval_het_L_sym(y,d,z,gamma,p_gamma,level,np,L,tol1,tol2)
% Function assumes all exogenous variables (including constant) have been
% partialed out of y, d, and z.

J = size(gamma,1);

Mzz = inv(z'*z);
Mzx = z'*d;
M   = inv(Mzx'*Mzz*Mzx);

b2 = M*Mzx'*Mzz*(z'*y);
e = y - d*b2;
V = hetero(z,e);
VC = M*Mzx'*Mzz*V*Mzz*Mzx*M;
s = sqrt(VC);
minL = 2*norminv(1-level/2)*s;

btemp = zeros(J,1);
stemp = zeros(J,1);
for i = 1:J,
    btemp(i,1) = M*Mzx'*Mzz*(z'*(y - z*gamma(i,:)'));
    etemp      = y - z*gamma(i,:)' - d*btemp(i,1);
    Vtemp      = hetero(z,etemp);
    VCtemp     = M*Mzx'*Mzz*Vtemp*Mzz*Mzx*M;
    stemp(i,1) = sqrt(VCtemp);
end

mgamma = gamma'*p_gamma;
I = find(abs(gamma - mgamma) == min(abs(gamma - mgamma)));
mb = btemp(I(1),1);
ms = stemp(I(1),1);

alphas = 1/(np+1):1/(np+1):(1-1/(np+1));

critvals = norminv(alphas);

B = btemp*ones(1,np) + stemp*critvals;

if nargin < 8,
    I = find(abs(alphas-level/2) == min(abs(alphas-level/2)));
    s_lb = min(B(:,I)); %#ok<FNDSB>
    I = find(abs(alphas-(1-level/2)) == min(abs(alphas-(1-level/2))));
    s_ub = max(B(:,I)); %#ok<FNDSB>
    L = s_ub-s_lb;
elseif isempty(L),
    I = find(abs(alphas-level/2) == min(abs(alphas-level/2)));
    s_lb = min(B(:,I)); %#ok<FNDSB>
    I = find(abs(alphas-(1-level/2)) == min(abs(alphas-(1-level/2))));
    s_ub = max(B(:,I)); %#ok<FNDSB>
    L = s_ub-s_lb;
end
if nargin < 9,
    tol1 = ms/10;
elseif isempty(tol1),
    tol1 = ms/10;
end
if nargin < 10,
    tol2 = .002;
elseif isempty(tol2),
    tol2 = .002;
end

lb = mb-minL/2;  ub = mb+minL/2;
CMAT = (B >= lb & B <= ub);
LMAT = mean(CMAT,2);
constraint = (1 - LMAT'*p_gamma) - level;
if constraint < tol2,
    ci = [lb,ub];
else
    
    LB0 = min(min(B));  UB0 = max(max(B));
    maxL = UB0-LB0;

    lb = mb-L/2;  ub = mb+L/2;

    CMAT = (B >= lb & B <= ub);
    LMAT = mean(CMAT,2);
    constraint = (1 - LMAT'*p_gamma) - level;
    ci = [lb,ub];

    while (constraint > tol2) && (lb > LB0) && (ub < UB0),
        lbm = lb-tol1;  ubm = lb+L-tol1;
        lbp = ub-L+tol1;  ubp = ub+tol1;
        CMAT = (B >= lbm & B <= ubm);
        LMAT = mean(CMAT,2);
        cm = (1 - LMAT'*p_gamma) - level;
        CMAT = (B >= lbp & B <= ubp);
        LMAT = mean(CMAT,2);
        cp = (1 - LMAT'*p_gamma) - level;
        lb = lbm;  ub = ubp;  constraint = min(cp,cm);
        if cp < tol2 && (cm > tol2 || abs(cp) < abs(cm)),
            ci = [lbp,ubp];
        elseif cm < tol2 && (cp > tol2 || abs(cm) < abs(cp)),
            ci = [lbm,ubm];
        end
    end

    ci0 = ci;
    L0 = L;
    if constraint < tol2,
        Lval0 = 1;
    else
        Lval0 = 0;
    end

    if Lval0 == 1,
        L1 = (L0 + minL)/2;
        maxL = L0;
    else
        L1 = (L0 + maxL)/2;
        minL = L0;
    end

    lb = mb-L1/2;  ub = mb+L1/2;

    CMAT = (B >= lb & B <= ub);
    LMAT = mean(CMAT,2);
    constraint = (1 - LMAT'*p_gamma) - level;
    ci = [lb,ub];

    while (constraint > tol2) && (lb > LB0) && (ub < UB0),
        lbm = lb-tol1;  ubm = lb+L1-tol1;
        lbp = ub-L1+tol1;  ubp = ub+tol1;
        CMAT = (B >= lbm & B <= ubm);
        LMAT = mean(CMAT,2);
        cm = (1 - LMAT'*p_gamma) - level;
        CMAT = (B >= lbp & B <= ubp);
        LMAT = mean(CMAT,2);
        cp = (1 - LMAT'*p_gamma) - level;
        lb = lbm;  ub = ubp;  constraint = min(cp,cm);
        if cp < tol2 && (cm > tol2 || abs(cp) < abs(cm)),
            ci = [lbp,ubp];
        elseif cm < tol2 && (cp > tol2 || abs(cm) < abs(cp)),
            ci = [lbm,ubm];
        end
    end

    ci1 = ci;
    if constraint < tol2,
        Lval1 = 1;
    else
        Lval1 = 0;
    end

    niter = 1;
    while (abs(Lval0-Lval1) ~= 1 || abs(L0-L1) > tol1) && (niter < 250),
        L0 = L1;  Lval0 = Lval1;  ci0 = ci1;
        niter = niter+1;
        if Lval1 == 0,
            L1 = (L0+maxL)/2;
            minL = L0;
        else
            L1 = (L0+minL)/2;
            maxL = L0;
        end
        lb = mb-L1/2;  ub = mb+L1/2;

        CMAT = (B >= lb & B <= ub);
        LMAT = mean(CMAT,2);
        constraint = (1 - LMAT'*p_gamma) - level;
        ci = [lb,ub];

        while (constraint > tol2) && (lb > LB0) && (ub < UB0),
            lbm = lb-tol1;  ubm = lb+L1-tol1;
            lbp = ub-L1+tol1;  ubp = ub+tol1;
            CMAT = (B >= lbm & B <= ubm);
            LMAT = mean(CMAT,2);
            cm = (1 - LMAT'*p_gamma) - level;
            CMAT = (B >= lbp & B <= ubp);
            LMAT = mean(CMAT,2);
            cp = (1 - LMAT'*p_gamma) - level;
            lb = lbm;  ub = ubp;  constraint = min(cp,cm);
            if cp < tol2 && (cm > tol2 || abs(cp) < abs(cm)),
                ci = [lbp,ubp];
            elseif cm < tol2 && (cp > tol2 || abs(cm) < abs(cp)),
                ci = [lbm,ubm];
            end
        end
        ci1 = ci;

        if constraint < tol2,
            Lval1 = 1;
        else
            Lval1 = 0;
        end
    end
    if niter == 250,
        disp('Failed to converge in 250 iterations');
    end

    if Lval0 == 1 && Lval1 == 0,
        Lstar = L0;
        ci = ci0;
    elseif Lval0 == 0 && Lval1 == 1,
        Lstar = L1;
        ci = ci1;
    elseif Lval0 == 1 && Lval1 == 1,
        Lstar = min(L0,L1);
        if Lstar == L0,
            ci = ci0;
        else
            ci = ci1;
        end
    else
        Lstar = max(L0,L1);
        if Lstar == L0,
            ci = ci0;
        else
            ci = ci1;
        end
    end

end