function [k_glob, F_TS_kond, activeTSDOFextern, isActiveTSDOF, K_sys_TS] = tsAssembleAndCondense(TS, Stab, nkd, F_TS_opt)
% Definiere die äußeren Freiheitsgrade (erster/letzter TS-Knoten) und führe die Kondensation durch.
% Falls F_TS_opt angegeben ist (Größe nTS*nkd), werden auch die Kräfte kondensiert.

if ~isfield(TS,'BeteiligteStaebe') || isempty(TS.BeteiligteStaebe) || ...
   ~isfield(TS,'KnotenTSgeordnet') || numel(TS.KnotenTSgeordnet) < 2
    k_glob            = zeros(2*nkd);
    F_TS_kond         = zeros(2*nkd,1);
    activeTSDOFextern = false(1, 2*nkd);
    isActiveTSDOF     = false(1, 0);
    K_sys_TS          = zeros(0);
    return;
end

Knoten = TS.KnotenTSgeordnet;
nTS = numel(Knoten); N = nTS*nkd;
KTS = zeros(N,N); isActive = false(1,N);

for s = TS.BeteiligteStaebe
    isPos = find(Knoten == Stab(s).sNode, 1);
    iePos = find(Knoten == Stab(s).eNode, 1);
    if isempty(isPos) || isempty(iePos), continue; end

    sIdx = (isPos-1)*nkd + (1:nkd);
    eIdx = (iePos-1)*nkd + (1:nkd);

    Kg = Stab(s).k_glob;

    KTS(sIdx, sIdx) = KTS(sIdx, sIdx) + Kg(1:nkd,          1:nkd);
    KTS(eIdx, eIdx) = KTS(eIdx, eIdx) + Kg(nkd+1:end, nkd+1:end);
    KTS(sIdx, eIdx) = KTS(sIdx, eIdx) + Kg(1:nkd,      nkd+1:end);
    KTS(eIdx, sIdx) = KTS(eIdx, sIdx) + Kg(nkd+1:end,       1:nkd);

    isActive(sIdx(Stab(s).activeStabDOF(1:nkd)))       = true;
    isActive(eIdx(Stab(s).activeStabDOF(nkd+1:end)))   = true;
end

K_sys_TS      = KTS;
isActiveTSDOF = isActive;

% externe nodes = erste und letzte TS node
extMaskFull                = false(1, N);
extMaskFull(1:nkd)         = isActive(1:nkd);
extMaskFull(end-nkd+1:end) = isActive(end-nkd+1:end);

% Kondensiere die Steifigkeitsmatrix auf die äußeren Freiheitsgrade
[Kee_ts, ~] = condensation(KTS, [], extMaskFull, 'preserve_size', false);

k_glob = zeros(2*nkd);
kept   = [find(isActive(1:nkd)), nkd + find(isActive(end-nkd+1:end))];
k_glob(kept, kept) = Kee_ts;

% Externe Maske
activeTSDOFextern = [isActive(1:nkd), isActive(end-nkd+1:end)];

% Optional: Kondensiere die TS-Kraft, falls angegeben
F_TS_kond = zeros(2*nkd,1);
if nargin >= 5 && ~isempty(F_TS_opt)
    [~, fext] = condensation(KTS, F_TS_opt(:), extMaskFull, 'preserve_size', false);
    kept2 = [find(isActive(1:nkd)); nkd + find(isActive(end-nkd+1:end))];
    F_TS_kond(kept2) = fext;
end
end
