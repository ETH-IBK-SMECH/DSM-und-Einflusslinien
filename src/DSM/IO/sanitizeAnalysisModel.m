function analysis = sanitizeAnalysisModel(analysis)

    % ---- DOF per node (default 3) ----
    if ~isfield(analysis, 'Info') || ~isfield(analysis.Info, 'nKnotenDOF') ...
            || ~isscalar(analysis.Info.nKnotenDOF) || ~isfinite(analysis.Info.nKnotenDOF)
        analysis.Info.nKnotenDOF = 3;
    end
    nDOFperNode = analysis.Info.nKnotenDOF;

    % ---- ensure arrays exist ----
    fields = {'Knoten','Stab','Teilsystem','Feder','KnotenLast','StabLast','SPC'};
    for k = 1:numel(fields)
        f = fields{k};
        if ~isfield(analysis, f) || isempty(analysis.(f))
            analysis.(f) = [];
        end
    end

    % ---- members: releases 1..nDOFperNode, unique row vectors ----
    for i = 1:numel(analysis.Stab)
        if ~isfield(analysis.Stab(i), 'sRelease') || isempty(analysis.Stab(i).sRelease), analysis.Stab(i).sRelease = []; end
        if ~isfield(analysis.Stab(i), 'eRelease') || isempty(analysis.Stab(i).eRelease), analysis.Stab(i).eRelease = []; end
        r = analysis.Stab(i).sRelease(:)'; r = r(r>=1 & r<=nDOFperNode); analysis.Stab(i).sRelease = unique(r);
        r = analysis.Stab(i).eRelease(:)'; r = r(r>=1 & r<=nDOFperNode); analysis.Stab(i).eRelease = unique(r);
        if ~isfield(analysis.Stab(i),'sNode'), analysis.Stab(i).sNode = 0; end
        if ~isfield(analysis.Stab(i),'eNode'), analysis.Stab(i).eNode = 0; end
    end

    % ---- springs: dir ∈ [1..nDOFperNode]; stiffness in .val ----
    for i = 1:numel(analysis.Feder)
        if ~isfield(analysis.Feder(i),'dir') || ~isscalar(analysis.Feder(i).dir) || ~isfinite(analysis.Feder(i).dir) ...
           || analysis.Feder(i).dir < 1 || analysis.Feder(i).dir > nDOFperNode
            analysis.Feder(i).dir = 0;  % ignored later
        end
        if ~isfield(analysis.Feder(i),'node'), analysis.Feder(i).node = 0; end

        if ~isfield(analysis.Feder(i),'val') || ~isfinite(analysis.Feder(i).val) || analysis.Feder(i).val < 0
            if isfield(analysis.Feder(i),'k') && isfinite(analysis.Feder(i).k) && analysis.Feder(i).k >= 0
                analysis.Feder(i).val = analysis.Feder(i).k;
            else
                analysis.Feder(i).val = 0;
            end
        end
        if isfield(analysis.Feder(i),'k')
            analysis.Feder(i).k = analysis.Feder(i).val;
        end
    end

    % ---- node loads: dir ∈ [1..nDOFperNode] else 0 ----
    for i = 1:numel(analysis.KnotenLast)
        if ~isfield(analysis.KnotenLast(i),'dir') || ~isscalar(analysis.KnotenLast(i).dir) || ~isfinite(analysis.KnotenLast(i).dir)
            analysis.KnotenLast(i).dir = 0;
        elseif analysis.KnotenLast(i).dir < 1 || analysis.KnotenLast(i).dir > nDOFperNode
            analysis.KnotenLast(i).dir = 0;
        end
        if ~isfield(analysis.KnotenLast(i),'node'), analysis.KnotenLast(i).node = 0; end
        if ~isfield(analysis.KnotenLast(i),'val')  || ~isfinite(analysis.KnotenLast(i).val), analysis.KnotenLast(i).val = 0; end
    end

    % ---- member loads: optional s/e distances default ----
    for i = 1:numel(analysis.StabLast)
        if ~isfield(analysis.StabLast(i), 'sDist') || isempty(analysis.StabLast(i).sDist), analysis.StabLast(i).sDist = 0; end
        if ~isfield(analysis.StabLast(i), 'eDist') || isempty(analysis.StabLast(i).eDist), analysis.StabLast(i).eDist = analysis.StabLast(i).sDist; end
        if ~isfield(analysis.StabLast(i),'stab'), analysis.StabLast(i).stab = 0; end
        if ~isfield(analysis.StabLast(i),'typ'),  analysis.StabLast(i).typ  = 0; end
    end

    % ---- counts (initial) ----
    if ~isfield(analysis,'Info') || ~isstruct(analysis.Info), analysis.Info = struct(); end
    analysis.Info.nKnoten       = numel(analysis.Knoten);
    analysis.Info.nStaebe       = numel(analysis.Stab);
    analysis.Info.nTeilsys      = numel(analysis.Teilsystem);
    analysis.Info.nFedern       = numel(analysis.Feder);
    analysis.Info.nKnotenLasten = numel(analysis.KnotenLast);
    analysis.Info.nStabLasten   = numel(analysis.StabLast);
    analysis.Info.nSPC          = numel(analysis.SPC);

    % ---- ensure Teilsystem fields exist (structural completeness) ----
    for t = 1:analysis.Info.nTeilsys
        if ~isfield(analysis.Teilsystem(t), 'BeteiligteStaebe'), analysis.Teilsystem(t).BeteiligteStaebe = []; end
        if ~isfield(analysis.Teilsystem(t), 'KnotenTSgeordnet'), analysis.Teilsystem(t).KnotenTSgeordnet = []; end
        if ~isfield(analysis.Teilsystem(t), 'KnotenDesTS'),      analysis.Teilsystem(t).KnotenDesTS      = []; end
    end

    % ---- mark members that belong to any Teilsystem ----
    for i = 1:analysis.Info.nStaebe
        analysis.Stab(i).inTeilSys = false;
    end
    for t = 1:analysis.Info.nTeilsys
        bs = analysis.Teilsystem(t).BeteiligteStaebe(:)';
        bs = bs(bs>=1 & bs<=analysis.Info.nStaebe);
        for s = bs, analysis.Stab(s).inTeilSys = true; end
    end

    % ---- per-Teilsystem node lists (ordered) ----
    for t = 1:analysis.Info.nTeilsys
        bs = analysis.Teilsystem(t).BeteiligteStaebe(:)';
        bs = bs(bs>=1 & bs<=analysis.Info.nStaebe);
        if isempty(bs)
            analysis.Teilsystem(t).KnotenDesTS      = [];
            analysis.Teilsystem(t).KnotenTSgeordnet = [];
            continue;
        end
        nS = numel(bs);
        KnotenDesTS = zeros(2*nS,1);
        for j = 1:nS
            sIdx = bs(j);
            KnotenDesTS(2*j-1) = safeIndex(analysis.Stab, sIdx, 'sNode');
            KnotenDesTS(2*j)   = safeIndex(analysis.Stab, sIdx, 'eNode');
        end
        analysis.Teilsystem(t).KnotenDesTS = KnotenDesTS;
        if exist('getKnotenTS','file') == 2
            analysis.Teilsystem(t).KnotenTSgeordnet = getKnotenTS(KnotenDesTS, nS);
        else
            analysis.Teilsystem(t).KnotenTSgeordnet = unique(KnotenDesTS,'stable');
        end
    end

    % -------------------------
    % PRUNE INVALID ENTRIES
    % -------------------------
    validNode   = @(v) isfinite(v) && v>=1 && v<=analysis.Info.nKnoten;
    validMember = @(v) isfinite(v) && v>=1 && v<=analysis.Info.nStaebe;

    % Node loads
    if ~isempty(analysis.KnotenLast)
        keep = false(1, numel(analysis.KnotenLast));
        for i = 1:numel(analysis.KnotenLast)
            L = analysis.KnotenLast(i);
            dir_ok  = isfield(L,'dir')  && isscalar(L.dir) && ismember(L.dir, 1:nDOFperNode);
            node_ok = isfield(L,'node') && validNode(L.node);
            val_ok  = isfield(L,'val')  && isfinite(L.val);
            keep(i) = dir_ok && node_ok && val_ok;
        end
        analysis.KnotenLast = analysis.KnotenLast(keep);
    end

    % Member loads
    allowedTyp = [1 2 3 4 5 6];
    if ~isempty(analysis.StabLast)
        keep = false(1, numel(analysis.StabLast));
        for i = 1:numel(analysis.StabLast)
            SL = analysis.StabLast(i);
            stab_ok = isfield(SL,'stab') && validMember(SL.stab);
            typ_ok  = isfield(SL,'typ')  && ismember(SL.typ, allowedTyp);
            keep(i) = stab_ok && typ_ok;
        end
        analysis.StabLast = analysis.StabLast(keep);
    end

    % Springs
    if ~isempty(analysis.Feder)
        keep = false(1, numel(analysis.Feder));
        for i = 1:numel(analysis.Feder)
            S = analysis.Feder(i);
            node_ok = isfield(S,'node') && validNode(S.node);
            dir_ok  = isfield(S,'dir')  && isscalar(S.dir) && ismember(S.dir, 1:nDOFperNode);
            k_ok    = isfield(S,'val')  && isfinite(S.val) && S.val>=0;
            keep(i) = node_ok && dir_ok && k_ok;
        end
        analysis.Feder = analysis.Feder(keep);
    end

    % SPCs
    if ~isempty(analysis.SPC)
        keep = false(1, numel(analysis.SPC));
        for i = 1:numel(analysis.SPC)
            C = analysis.SPC(i);
            node_ok = isfield(C,'node') && validNode(C.node);
            dir_ok  = isfield(C,'dir')  && isscalar(C.dir) && ismember(C.dir, 1:nDOFperNode);
            val_ok  = isfield(C,'val')  && isfinite(C.val);
            keep(i) = node_ok && dir_ok && val_ok;
        end
        analysis.SPC = analysis.SPC(keep);
    end

    % ---- refresh counts after pruning ----
    analysis.Info.nKnotenLasten = numel(analysis.KnotenLast);
    analysis.Info.nStabLasten   = numel(analysis.StabLast);
    analysis.Info.nFedern       = numel(analysis.Feder);
    analysis.Info.nSPC          = numel(analysis.SPC);

    % ---- recompute indices for fast loops (AFTER pruning) ----
    analysis.Info.idxFreeStab = find(~[analysis.Stab.inTeilSys]);
    analysis.Info.idxStabLast_free = [];
    analysis.Info.idxStabLast_TS   = [];
    for i = 1:numel(analysis.StabLast)
        si = analysis.StabLast(i).stab;
        if si>=1 && si<=numel(analysis.Stab)
            if analysis.Stab(si).inTeilSys
                analysis.Info.idxStabLast_TS(end+1) = i;
            else
                analysis.Info.idxStabLast_free(end+1) = i;
            end
        end
    end
end

% ---- tiny local helper (keeps sanitize simple) ----
function v = safeIndex(arr, idx, field)
    v = 0;
    if idx>=1 && idx<=numel(arr) && isfield(arr(idx), field)
        vv = arr(idx).(field);
        if ~isempty(vv) && isfinite(vv), v = vv; end
    end
end
