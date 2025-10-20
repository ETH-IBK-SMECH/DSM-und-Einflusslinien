function [isH, isV] = isOrientation(c, s, tol)
%ISORIENTATION gibt booleans zurück für ~horizontal/~vertical mit Toleranz.

if nargin < 3, tol = 1e-12; end
    % optionale renormalization
    n = hypot(c, s);
    if abs(n-1) > 1e-9 && n > eps
        c = c/n; s = s/n;
    end
    isH = abs(s) < tol;
    isV = abs(c) < tol;
end