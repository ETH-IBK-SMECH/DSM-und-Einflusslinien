function [F_stab_sys, F_TS_add, Stab] = stabLastenAssemblieren(model, DOF, nDOF)
% System-Elementlastvektor (inkl. Teilsystem-Beiträge)
[~, Stab, Teilsystem, ~, ~, StabLast, ~, Info, ~, ~] = extractFields(model);
nkd = model.Info.nKnotenDOF;
DOF = DOF(:);

firstHalf  = 1:nkd;
secondHalf = nkd + (1:nkd);

% freie Stäbe
g_all = []; v_all = [];

for i = 1:numel(StabLast)
    sIdx = StabLast(i).stab;
    if sIdx < 1 || sIdx > numel(Stab), continue; end
    if isfield(Stab,'inTeilSys') && Stab(sIdx).inTeilSys
        continue; % TS Stäbe überspringen
    end

    % Berechnet lokaler Kraftvektor
    f_loc = getF(StabLast(i), Stab(sIdx).L);
    [~, f_loc] = condensation(Stab(sIdx).k_loc_v, f_loc, Stab(sIdx).vorhandeneDOF, 'preserve_size', true);

    if ~isfield(Stab(sIdx),'P_int') || isempty(Stab(sIdx).P_int)
        Stab(sIdx).P_int = zeros(2*nkd,1);
    end
    Stab(sIdx).P_int = Stab(sIdx).P_int + f_loc;

    % globaler Kraftvektor berechnen
    f_glob = rotiereLocalToGlobal_F(f_loc, Stab(sIdx).R);
    d    = Stab(sIdx).dof_e;                       % 1×(2*nkd)
    mask = (d~=0) & Stab(sIdx).activeStabDOF(:)';  % 1×(2*nkd)
    if ~any(mask), continue; end
    
    g = d(mask); v = f_glob(mask);
    g_all = [g_all; g(:)]; %#ok<AGROW>
    v_all = [v_all; v(:)]; %#ok<AGROW>
end

F_stab_sys = sparse(g_all, 1, v_all, nDOF, 1);

% Teilsysteme : F_TS aufbauen und kondensieren
gts_all = []; vts_all = [];

for t = 1:Info.nTeilsys
    TS = Teilsystem(t);
    if ~isfield(TS,'KnotenTSgeordnet') || numel(TS.KnotenTSgeordnet) < 2, continue; end
    KnotenTS = TS.KnotenTSgeordnet(:).';  nTSNodes = numel(KnotenTS);
    F_TS = zeros(nTSNodes*nkd, 1);

    staebeTS = TS.BeteiligteStaebe;

    if ~isempty(staebeTS) && ~isempty(StabLast)
        maskLoads = ismember([StabLast.stab], staebeTS);
        idxLoads  = find(maskLoads);
        for j = idxLoads
            idx = StabLast(j).stab;
            f_loc = getF(StabLast(j), Stab(idx).L);
            [~, f_loc] = condensation(Stab(idx).k_loc_v, f_loc, Stab(idx).vorhandeneDOF, 'preserve_size', true);
            f_glob = rotiereLocalToGlobal_F(f_loc, Stab(idx).R);

            sNode = Stab(idx).sNode; eNode = Stab(idx).eNode;
            sPos  = find(KnotenTS == sNode, 1, 'first');
            ePos  = find(KnotenTS == eNode, 1, 'first');
            if isempty(sPos) || isempty(ePos), continue; end

            sIdx = (sPos-1)*nkd + firstHalf;
            eIdx = (ePos-1)*nkd + firstHalf;
            F_TS(sIdx) = F_TS(sIdx) - f_glob(firstHalf);
            F_TS(eIdx) = F_TS(eIdx) - f_glob(secondHalf);
        end
    end

    % Knotenkräfte ohne globale DOF → in TS sammeln
    if isfield(model,'KnotenLast') && ~isempty(model.KnotenLast)
        KL = model.KnotenLast(:);
        node = [KL.node]'; dir = [KL.dir]'; val = [KL.val]';
        localIdx = (node-1)*nkd + dir;

        ok = localIdx >= 1 & localIdx <= numel(DOF);
        g  = zeros(size(localIdx));
        g(ok) = DOF(localIdx(ok));

        % Nur Knoten ohne globale DOF behalten
        keep = (g == 0);
        for k = find(keep)'
            pos = find(KnotenTS == KL(k).node, 1, 'first');
            if isempty(pos), continue; end
            gIdx = (pos-1)*nkd + KL(k).dir;
            if gIdx >= 1 && gIdx <= numel(F_TS)
                F_TS(gIdx) = F_TS(gIdx) + KL(k).val;
            end
        end
    end

    % TS Kondensieren
    [~, F_TS_kond, activeTS] = tsAssembleAndCondense(TS, Stab, nkd, F_TS);

    % Globale DOFs der äusseren TS-Knoten
    sNodeTS = KnotenTS(1);
    eNodeTS = KnotenTS(end);
    loc6 = [(sNodeTS - 1)*nkd + (1:nkd), (eNodeTS - 1)*nkd + (1:nkd)];
    glob6 = zeros(size(loc6));
    ok = loc6 >= 1 & loc6 <= numel(DOF);
    glob6(ok) = DOF(loc6(ok));

    mask = (glob6~=0) & activeTS(:)';
    if ~any(mask), continue; end

    gts_all = [gts_all; glob6(mask).']; %#ok<AGROW>
    vts_all = [vts_all; F_TS_kond(mask)];
end

F_TS_add = sparse(gts_all, 1, vts_all, nDOF, 1);
end
