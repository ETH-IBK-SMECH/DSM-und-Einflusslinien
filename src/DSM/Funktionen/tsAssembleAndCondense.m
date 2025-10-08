function [k_glob, F_TS_kond, activeTSDOFextern, isActiveTSDOF, K_sys_TS] = tsAssembleAndCondense(TS, Stab, nkd)
% Assemble TS stiffness from members, mark active DOFs, define externals,
% and condense stiffness (and force if TS.F_TS is present) via condensation().

Knoten = TS.KnotenTSgeordnet;       % e.g., [2 3 5 4]
nTS    = numel(Knoten);
N      = nTS * nkd;

KTS      = zeros(N, N);
isActive = false(1, N);

% assemble K_sys_TS from participating members
for s = TS.BeteiligteStaebe
    isPos = find(Knoten == Stab(s).sNode, 1, 'first');
    iePos = find(Knoten == Stab(s).eNode, 1, 'first');
    if isempty(isPos) || isempty(iePos), continue; end

    sIdx = (isPos-1)*nkd + (1:nkd);
    eIdx = (iePos-1)*nkd + (1:nkd);

    Kg = Stab(s).k_glob;  % (2*nkd x 2*nkd)

    % four sub-blocks
    KTS(sIdx, sIdx) = KTS(sIdx, sIdx) + Kg(1:nkd,          1:nkd);
    KTS(eIdx, eIdx) = KTS(eIdx, eIdx) + Kg(nkd+1:end, nkd+1:end);
    KTS(sIdx, eIdx) = KTS(sIdx, eIdx) + Kg(1:nkd,      nkd+1:end);
    KTS(eIdx, sIdx) = KTS(eIdx, sIdx) + Kg(nkd+1:end,       1:nkd);

    % active flags from member masks
    isActive(sIdx(Stab(s).activeStabDOF(1:nkd)))       = true;
    isActive(eIdx(Stab(s).activeStabDOF(nkd+1:end)))   = true;
end

K_sys_TS     = KTS;
isActiveTSDOF = isActive;

% externals = first and last TS node (respecting activity)
extMask                = false(1, N);
extMask(1:nkd)         = isActive(1:nkd);
extMask(end-nkd+1:end) = isActive(end-nkd+1:end);

% condense stiffness to externals (compact 2*nkd x 2*nkd)
[Kee_ts, ~] = condensation(KTS, [], extMask, 'preserve_size', false);

% Pack into canonical 2*nkd (6x6) aligned to external order
k_glob = zeros(2*nkd);
kept   = [find(isActive(1:nkd)), nkd + find(isActive(end-nkd+1:end))];
k_glob(kept, kept) = Kee_ts;

% external mask in 2*nkd frame for later picking
activeTSDOFextern = [isActive(1:nkd), isActive(end-nkd+1:end)];

% optional: condense TS force if provided
F_TS_kond = zeros(2*nkd,1);
if isfield(TS,'F_TS') && ~isempty(TS.F_TS)
    [~, fext] = condensation(KTS, TS.F_TS(:), extMask, 'preserve_size', false);
    kept2 = [find(isActive(1:nkd)); nkd + find(isActive(end-nkd+1:end))];
    F_TS_kond(kept2) = fext;
end
end
