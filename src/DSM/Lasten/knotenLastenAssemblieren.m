function F_N = knotenLastenAssemblieren(model, DOF, nDOF)
% System-Knotenlastvektor

if ~isfield(model,'KnotenLast') || isempty(model.KnotenLast)
    F_N = sparse(nDOF,1);
    return;
end

DOF = DOF(:);
nkd = model.Info.nKnotenDOF;

KL = model.KnotenLast(:);
node = [KL.node]'; 
dir  = [KL.dir]';
val = [KL.val]';

local = (node-1)*nkd + dir;                 % vector
ok = local >= 1 & local <= numel(DOF);
g = zeros(size(local)); 
g(ok) = DOF(local(ok));
keep = g > 0;
F_N = sparse(g(keep), 1, val(keep), nDOF, 1); 
end
