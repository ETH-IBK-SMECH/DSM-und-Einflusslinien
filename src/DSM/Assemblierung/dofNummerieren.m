function [DOF, nDOF, model] = dofNummerieren(model)
% Zuständig für DOF-Nummerierung

[~, Stab, ~, Feder, ~, ~, SPC, Info, ~, ~] = extractFields(model);
nN  = Info.nKnoten;    nkd = Info.nKnotenDOF;   n6 = 2*nkd;

transIdx = [1, 2, nkd+1, nkd+2];

% aktive DOF pro Element (orientation + releases)
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

    % 6 lokal DOF-indizen und Element-Knoten-Paare errinern
    Stab(i).loc6 = [(Stab(i).sNode - 1) * nkd + (1:nkd), (Stab(i).eNode - 1) * nkd + (1:nkd)];
end

% global active flags
isActive = false(1, Info.nKnoten * nkd);

% Element aktivität markieren
for i = 1:Info.nStaebe
    g6 = Stab(i).loc6;
    isActive(g6(Stab(i).activeStabDOF)) = true;
end

% Federn
for k = 1:Info.nFedern
    if Feder(k).node>=1 && Feder(k).node<=nN && ismember(Feder(k).dir,1:nkd)
        isActive((Feder(k).node-1)*nkd + Feder(k).dir) = true;
    end
end
% Lagerbedingungen (SPC)
for k=1:Info.nSPC
    if SPC(k).node>=1 && SPC(k).node<=nN && ismember(SPC(k).dir,1:nkd)
        isActive((SPC(k).node-1)*nkd + SPC(k).dir) = true;
    end
end

% Nummerierung
nDOF = sum(isActive);
DOF = zeros(1, numel(isActive)); DOF(isActive) = 1:nDOF;

% globale liste der Elementen (0 wo inaktiv)
for i=1:Info.nStaebe
    g6 = arrayfun(@(idx) safeDOF(idx, DOF), Stab(i).loc6);
    Stab(i).dof_e = g6;   % dimension 1×(2*nkd)
end

model.Stab = Stab;
end
