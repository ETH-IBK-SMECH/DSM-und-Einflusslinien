function g = safeDOF(localIdx, DOF)
% Gibt einen gültigen globalen Freiheitsgradindex zurück oder 0, falls ungültig.
if isempty(localIdx) || localIdx < 1 || localIdx > numel(DOF)
    g = 0;
    return;
end
g = DOF(localIdx);
if g < 1 || ~isfinite(g) || g > numel(DOF)
    g = 0;
end
end
