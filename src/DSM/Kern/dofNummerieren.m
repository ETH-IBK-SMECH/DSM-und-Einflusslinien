function [DOF, nDOF, maps, model] = dofNummerieren(model, ele)
% DOF-Nummerierung und Aktivierung (Stäbe, Teilsysteme, Federn)
[Knoten, Stab, Teilsystem, Feder, KnotenLast, StabLast, SPC, Info, ~, ~] = extractFields(model);

nkd = Info.nKnotenDOF; n6 = 2*nkd;
nodeDOFs = @(n) (n-1)*nkd + (1:nkd);
pairDOFs = @(s,e) [nodeDOFs(s), nodeDOFs(e)];
transIdx = [1, 2, nkd+1, nkd+2];

% aktiveStabDOF bestimmen (inkl. Orientierung)
for i=1:Info.nStaebe
    vorhanden = true(1,n6);
    if isfield(Stab(i),'sRelease'), vorhanden(Stab(i).sRelease) = false; end
    if isfield(Stab(i),'eRelease'), vorhanden(Stab(i).eRelease + nkd) = false; end
    Stab(i).vorhandeneDOF = vorhanden;

    Stab(i).activeStabDOF = vorhanden;
    [isH, isV] = isOrientation(ele(i).c, ele(i).s);   % existing
    if isV
        Stab(i).activeStabDOF(transIdx) = Stab(i).activeStabDOF(transIdx([2,1,4,3]));
    elseif ~isH
        Stab(i).activeStabDOF(transIdx) = true;
    end
end

% Teilsysteme kondensieren (liefert k_glob, F_TS_kond, aktive externe DOF, usw.)
for t = 1:Info.nTeilsys
    [Teilsystem(t).k_glob, Teilsystem(t).F_TS_kond, Teilsystem(t).activeTSDOFextern, ...
     Teilsystem(t).isActiveTSDOF, Teilsystem(t).K_sys_TS] = tsAssembleAndCondense(Teilsystem(t), Stab, nkd); % existing
end

% Globale Aktiv-Flags
isActive = false(1, Info.nKnoten * nkd);

% TS-DOF aktivieren
for t = 1:Info.nTeilsys
    if ~isfield(Teilsystem(t),'KnotenTSgeordnet') || numel(Teilsystem(t).KnotenTSgeordnet) < 2 ...
       || ~isfield(Teilsystem(t),'activeTSDOFextern') || isempty(Teilsystem(t).activeTSDOFextern)
        continue;
    end
    sNodeTS = Teilsystem(t).KnotenTSgeordnet(1);
    eNodeTS = Teilsystem(t).KnotenTSgeordnet(end);
    nodes = pairDOFs(sNodeTS, eNodeTS);
    activeTS = nodes(Teilsystem(t).activeTSDOFextern);
    isActive = setFlagsIfValid(activeTS, isActive);
end

% Einzelstäbe
for i = Info.idxFreeStab
    stabDOF = pairDOFs(Stab(i).sNode, Stab(i).eNode);
    active = stabDOF(Stab(i).activeStabDOF);
    isActive = setFlagsIfValid(active, isActive);
end

% Federn
for i=1:Info.nFedern
   IdxDOF = (Feder(i).node-1)*nkd + Feder(i).dir;
   isActive = setFlagsIfValid(IdxDOF, isActive);
end

% Nummerierung
nDOF = sum(isActive);
DOF = zeros(1, numel(isActive));
DOF(isActive) = 1:nDOF;

% DOF den Stäben zuordnen
for i = Info.idxFreeStab
    loc6  = pairDOFs(Stab(i).sNode, Stab(i).eNode);
    glob6 = arrayfun(@(idx) safeDOF(idx, DOF), loc6);
    Stab(i).DOF = glob6(Stab(i).activeStabDOF);
end

% DOF den TS zuordnen
for t = 1:Info.nTeilsys
    if ~isfield(Teilsystem(t),'KnotenTSgeordnet') || numel(Teilsystem(t).KnotenTSgeordnet) < 2
        Teilsystem(t).DOF = zeros(1,0);
        continue;
    end
    sNodeTS = Teilsystem(t).KnotenTSgeordnet(1);
    eNodeTS = Teilsystem(t).KnotenTSgeordnet(end);
    loc6 = pairDOFs(sNodeTS, eNodeTS);
    glob6 = arrayfun(@(idx) safeDOF(idx, DOF), loc6);
    Teilsystem(t).DOF = glob6(Teilsystem(t).activeTSDOFextern);
end


% DOF an Federn/Knotenlast schreiben
for i=1:Info.nFedern
   Feder(i).DOF = safeDOF(dofIndex(Feder(i).node, Feder(i).dir, nkd), DOF); % existing names preserved
end
for i=1:Info.nKnotenLasten
   KnotenLast(i).DOF = safeDOF(dofIndex(KnotenLast(i).node, KnotenLast(i).dir, nkd), DOF);
end

% SPC DOF zuordnen (global)
for i = 1:Info.nSPC
    if ~(isfinite(SPC(i).node) && SPC(i).node>=1 && SPC(i).node<=Info.nKnoten), SPC(i).DOF = 0; continue; end
    if ~(isfinite(SPC(i).dir)  && SPC(i).dir>=1  && SPC(i).dir<=nkd),            SPC(i).DOF = 0; continue; end
    localIdx = (SPC(i).node-1)*nkd + SPC(i).dir;
    SPC(i).DOF = safeDOF(localIdx, DOF);
end

% zurück ins Modell
model.Knoten     = Knoten;
model.Stab       = Stab;
model.Teilsystem = Teilsystem;
model.Feder      = Feder;
model.KnotenLast = KnotenLast;
model.StabLast   = StabLast;
model.SPC        = SPC;
model.Info       = Info;

% maps
maps.nkd = nkd; maps.n6 = n6; maps.nodeDOFs = nodeDOFs; maps.pairDOFs = pairDOFs; maps.transIdx = transIdx;
end
