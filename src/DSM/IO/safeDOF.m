function g = safeDOF(localIdx, DOF)
% Returns a valid global DOF index or 0 if invalid.
    if isempty(localIdx) || localIdx < 1 || localIdx > numel(DOF)
        g = 0; return;
    end
    g = DOF(localIdx);
    if g < 1 || ~isfinite(g) || g > numel(DOF)
        g = 0;
    end
end

