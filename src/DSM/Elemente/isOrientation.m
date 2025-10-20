function [isH, isV] = isOrientation(c, s, tol)
%ISORIENTATION Return booleans for ~horizontal/~vertical with tolerance.

if nargin < 3, tol = 1e-12; end
    % optional renormalization
    n = hypot(c, s);
    if abs(n-1) > 1e-9 && n > eps
        c = c/n; s = s/n;
    end
    isH = abs(s) < tol;
    isV = abs(c) < tol;
end