function [DOF, nDOF, model] = dofNummerieren(model)
% Zuständig für DOF-Nummerierung

[~, Stab, Feder, ~, ~, SPC, Info, ~, ~] = extractFields(model);
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
if Info.nStaebe > 0
    % Matrizen aufbauen: jede Zeile -> ein Stab, Spalten -> 2*nkd DOFs
    loc6Mat  = vertcat(Stab.loc6);                 % [nStaebe x (2*nkd)]
    maskMat  = vertcat(Stab.activeStabDOF);        % [nStaebe x (2*nkd)] logical

    % Nur valide Einträge behalten (0 bedeutet inaktiv/ausserhalb)
    valid    = loc6Mat > 0;
    keepMat  = valid & maskMat;

    if any(keepMat,'all')
        idx = loc6Mat(keepMat);                    % Vektor aller aktiven globalen DOF
        isActive(idx) = true;                      % einmalig setzen (OR)
    end
end

% Federn
if Info.nFedern > 0
    nodes = [Feder.node]'; dirs = [Feder.dir]';
    okNodes = nodes >= 1 & nodes <= Info.nKnoten;
    okDirs  = dirs  >= 1 & dirs  <= nkd;
    ok      = okNodes & okDirs;
    if any(ok)
        idxF = (nodes(ok) - 1) * nkd + dirs(ok);
        isActive(idxF) = true;
    end
end

% Lagerbedingungen (SPC)
if Info.nSPC > 0
    nodes = [SPC.node]'; dirs = [SPC.dir]';
    okNodes = nodes >= 1 & nodes <= Info.nKnoten;
    okDirs  = dirs  >= 1 & dirs  <= nkd;
    ok      = okNodes & okDirs;
    if any(ok)
        idxS = (nodes(ok) - 1) * nkd + dirs(ok);
        isActive(idxS) = true;
    end
end

% Nummerierung
nDOF = sum(isActive);
DOF = zeros(1, numel(isActive)); DOF(isActive) = 1:nDOF;

% globale liste der Elementen (0 wo inaktiv)
for i=1:Info.nStaebe
    loc = Stab(i).loc6;
    act = Stab(i).activeStabDOF;    %ok  = loc >= 1 & loc <= numel(DOF);
    g6  = zeros(size(loc));
    g6(act) = DOF(loc(act));        %g6(ok) = DOF(loc(ok));
    Stab(i).dof_e = g6;
end

model.Stab = Stab;
end
