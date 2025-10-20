function [k_glob, F_TS_kond, activeTSDOFextern, isActiveTSDOF, K_sys_TS] = tsAssembleAndCondense(TS, Stab, nkd, F_TS_opt)
% define externals (first/last TS node), and condense. No model writes.
% If F_TS_opt provided (size nTS*nkd), also condense forces.

% quick exit
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
    % locate s/e positions in the TS node stack
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

    % activity
    isActive(sIdx(Stab(s).activeStabDOF(1:nkd)))       = true;
    isActive(eIdx(Stab(s).activeStabDOF(nkd+1:end)))   = true;
end

K_sys_TS      = KTS;
isActiveTSDOF = isActive;

% externals = first and last TS node
extMaskFull                = false(1, N);
extMaskFull(1:nkd)         = isActive(1:nkd);
extMaskFull(end-nkd+1:end) = isActive(end-nkd+1:end);

% condense stiffness to externals (compact 2*nkd)
[Kee_ts, ~] = condensation(KTS, [], extMaskFull, 'preserve_size', false);

% pack into canonical 2*nkd aligned to external order
k_glob = zeros(2*nkd);
kept   = [find(isActive(1:nkd)), nkd + find(isActive(end-nkd+1:end))];
k_glob(kept, kept) = Kee_ts;

% external mask in 2*nkd frame
activeTSDOFextern = [isActive(1:nkd), isActive(end-nkd+1:end)];

% optional: condense TS force if provided
F_TS_kond = zeros(2*nkd,1);
if nargin >= 5 && ~isempty(F_TS_opt)
    [~, fext] = condensation(KTS, F_TS_opt(:), extMaskFull, 'preserve_size', false);
    kept2 = [find(isActive(1:nkd)); nkd + find(isActive(end-nkd+1:end))];
    F_TS_kond(kept2) = fext;
end
end
