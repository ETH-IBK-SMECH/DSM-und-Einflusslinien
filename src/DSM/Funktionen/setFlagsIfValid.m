function vec = setFlagsIfValid(gs, vec)
    if isempty(gs), return; end
    gs = gs(gs >= 1 & gs <= numel(vec));
    if ~isempty(gs), vec(gs) = true; end
end
