function [DOF, nDOF, model] = dofNummerieren(model)
% Pure DOF numbering; no model mutation.

[~, Stab, ~, Feder, ~, ~, SPC, Info, ~, ~] = extractFields(model);
nN  = Info.nKnoten;    nkd = Info.nKnotenDOF;   n6 = 2*nkd;

transIdx = [1, 2, nkd+1, nkd+2];

% active DOF per element (orientation + releases)
for i=1:Info.nStaebe
    vorhanden = true(1,n6);
    if isfield(Stab(i),'sRelease') && ~isempty(Stab(i).sRelease), vorhanden(Stab(i).sRelease)       = false; end
    if isfield(Stab(i),'eRelease') && ~isempty(Stab(i).eRelease), vorhanden(Stab(i).eRelease + nkd) = false; end
    Stab(i).vorhandeneDOF = vorhanden;

    [isH, isV] = isOrientation(Stab(i).cs, Stab(i).sn);
    active = vorhanden;
    if isV
        active(transIdx) = active(transIdx([2,1,4,3]));
    elseif ~isH
        active(transIdx) = true;
    end
    Stab(i).activeStabDOF = active;

    % remember local 6 indices and element node pair
    Stab(i).loc6 = [(Stab(i).sNode - 1) * nkd + (1:nkd), (Stab(i).eNode - 1) * nkd + (1:nkd)];
end

% global active flags
isActive = false(1, Info.nKnoten * nkd);

% mark element activity
for i = 1:Info.nStaebe
    g6 = Stab(i).loc6;
    isActive(g6(Stab(i).activeStabDOF)) = true;
end

% springs
for k = 1:Info.nFedern
    if Feder(k).node>=1 && Feder(k).node<=nN && ismember(Feder(k).dir,1:nkd)
        isActive((Feder(k).node-1)*nkd + Feder(k).dir) = true;
    end
end
% SPC (they can "activate" rows)
for k=1:Info.nSPC
    if SPC(k).node>=1 && SPC(k).node<=nN && ismember(SPC(k).dir,1:nkd)
        isActive((SPC(k).node-1)*nkd + SPC(k).dir) = true;
    end
end

% numbering
nDOF = sum(isActive);
DOF = zeros(1, numel(isActive)); DOF(isActive) = 1:nDOF;

% element compact global lists (0 where inactive)
for i=1:Info.nStaebe
    g6 = arrayfun(@(idx) safeDOF(idx, DOF), Stab(i).loc6);
    Stab(i).dof_e = g6;   % size 1×(2*nkd)
end

model.Stab = Stab;
end
