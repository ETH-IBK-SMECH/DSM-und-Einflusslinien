function [F_stab_sys, F_TS_add, Stab] = stabLastenAssemblieren(model, DOF, nDOF)
% System-Elementlastvektor (inkl. Teilsystem-Beiträge)
[~, Stab, Teilsystem, ~, ~, StabLast, ~, Info, ~, ~] = extractFields(model);
F_stab_sys = sparse(nDOF,1);
F_TS_add   = sparse(nDOF,1);
nkd = model.Info.nKnotenDOF;

firstHalf  = 1:nkd;
secondHalf = nkd + (1:nkd);

% freie Stäbe
for i = 1:numel(StabLast)
    sIdx = StabLast(i).stab;
    if sIdx < 1 || sIdx > numel(Stab), continue; end
    if isfield(Stab,'inTeilSys') && ~isempty(Stab) && Stab(sIdx).inTeilSys
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
    if any(mask)
        F_stab_sys = F_stab_sys + sparse(d(mask), 1, f_glob(mask), nDOF, 1);
    end
end

% Teilsysteme : build F_TS aufbauen und kondensieren
for t = 1:Info.nTeilsys
    TS = Teilsystem(t);
    if ~isfield(TS,'KnotenTSgeordnet') || numel(TS.KnotenTSgeordnet) < 2, continue; end
    KnotenTS = TS.KnotenTSgeordnet;  nTSNodes = numel(KnotenTS);
    F_TS = zeros(nTSNodes*nkd, 1);

    staebeTS = TS.BeteiligteStaebe;
    for j = 1:Info.nStabLasten
        idx = StabLast(j).stab;
        if any(idx == staebeTS)
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
    for z=1:Info.nKnotenLasten
        Lz = model.KnotenLast(z);
        localIdx = (Lz.node-1)*nkd + Lz.dir;
        g = safeDOF(localIdx, DOF);
        if g ~= 0, continue; end
        pos  = find(KnotenTS == Lz.node, 1, 'first');
        if isempty(pos), continue; end
        gIdx = (pos-1)*nkd + Lz.dir;
        if gIdx >= 1 && gIdx <= numel(F_TS)
            F_TS(gIdx) = F_TS(gIdx) + Lz.val;
        end
    end

    % TS Kondensieren
    [~, F_TS_kond, activeTS] = tsAssembleAndCondense(TS, Stab, nkd, F_TS);

    sNodeTS = KnotenTS(1);
    eNodeTS = KnotenTS(end);
    loc6 = [(sNodeTS - 1)*nkd + (1:nkd), (eNodeTS - 1)*nkd + (1:nkd)];
    glob6 = arrayfun(@(idx) safeDOF(idx, DOF), loc6);

    d    = glob6;                                % 1×(2*nkd)
    mask = (d~=0) & activeTS(:)';                % 1×(2*nkd)
    if any(mask)
        F_TS_add = F_TS_add + sparse(d(mask), 1, F_TS_kond(mask), nDOF, 1);
    end
end
end
