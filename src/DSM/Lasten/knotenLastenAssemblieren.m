function F_N = knotenLastenAssemblieren(model, DOF, nDOF)
% System-Knotenlastvektor
F_N = sparse(nDOF,1);

if ~isfield(model,'KnotenLast') || isempty(model.KnotenLast)
    return;
end
nkd = model.Info.nKnotenDOF;

for i = 1:numel(model.KnotenLast)
    L = model.KnotenLast(i);
    if ~isfield(L,'node') || ~isfield(L,'dir') || ~isfield(L,'val'), continue; end
    if ~isscalar(L.node) || ~isscalar(L.dir), continue; end
    localIdx = (L.node-1)*nkd + L.dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        F_N(g) = F_N(g) + L.val;
    end
end
end
