function [F_stab_sys, F_TS_add, ele] = stabLastenAssemblieren(ele, DOF, nDOF, model)
% [Schritt 3] System-Elementlastvektor (inkl. Teilsystem-Beiträge)
F_stab_sys = sparse(nDOF,1);
F_TS_add = sparse(nDOF,1);

[~, Stab, Teilsystem, ~, ~, StabLast, ~, Info] = extractFields(model);
nkd = Info.nKnotenDOF;
firstHalf  = 1:nkd;
secondHalf = nkd + (1:nkd);

% freie Stäbe
for k = 1:numel(Info.idxStabLast_free)
    i    = Info.idxStabLast_free(k);   % index in StabLast
    sIdx = StabLast(i).stab;

    % LOCAL fixed-end vector for recovery (always accumulate)
    f_loc = getF(StabLast(i), ele(sIdx).L);
    [~, f_loc] = condensation(ele(sIdx).k_loc_v, f_loc, Stab(sIdx).vorhandeneDOF, 'preserve_size', true);
    ele(sIdx).P_int = ele(sIdx).P_int + f_loc;

    % System contribution (global) – only free members here
    f_glob = rotiereLocalToGlobal_F(f_loc, ele(sIdx).R);
    d = Stab(sIdx).DOF; keep = d~=0;
    if any(keep)
        a6 = find(Stab(sIdx).activeStabDOF); a6 = a6(keep); d = d(keep);
        F_stab_sys = F_stab_sys + sparse(d,1, f_glob(a6), nDOF,1);
    end
end

% Teilsysteme
for t = 1:Info.nTeilsys
    KnotenTS = Teilsystem(t).KnotenTSgeordnet;
    nTSNodes = numel(KnotenTS);
    F_TS = zeros(nTSNodes*nkd, 1);

    staebeTS = Teilsystem(t).BeteiligteStaebe;
    for j = 1:Info.nStabLasten
        idx = StabLast(j).stab;
        if any(idx == staebeTS)
            sNode = Stab(idx).sNode; eNode = Stab(idx).eNode;
            sPos = find(KnotenTS == sNode, 1, 'first');
            ePos = find(KnotenTS == eNode, 1, 'first');
            if isempty(sPos) || isempty(ePos), continue; end

            f_loc = getF(StabLast(j), ele(idx).L);
            [~, f_loc] = condensation(ele(idx).k_loc_v, f_loc, Stab(idx).vorhandeneDOF, 'preserve_size', true);
            f_glob = rotiereLocalToGlobal_F(f_loc, ele(idx).R);

            sIdx = (sPos-1)*nkd + firstHalf;
            eIdx = (ePos-1)*nkd + firstHalf;
            F_TS(sIdx) = F_TS(sIdx) - f_glob(firstHalf);
            F_TS(eIdx) = F_TS(eIdx) - f_glob(secondHalf);
        end
    end

    % Knotenlasten ohne globale DOF ebenfalls in TS sammeln
    for z=1:Info.nKnotenLasten
        if model.KnotenLast(z).DOF ~= 0, continue; end
        node = model.KnotenLast(z).node;
        pos  = find(KnotenTS == node, 1, 'first');
        if isempty(pos), continue; end
        gIdx = (pos-1)*nkd + model.KnotenLast(z).dir;
        if gIdx >= 1 && gIdx <= numel(F_TS)
            F_TS(gIdx) = F_TS(gIdx) + model.KnotenLast(z).val;
        end
    end

    % kondensierter TS-Lastvektor auf externe DOF
    Teilsystem(t).F_TS = F_TS;
    [~, F_TS_kond] = tsAssembleAndCondense(Teilsystem(t), Stab, nkd);  % existing
    a6 = find(Teilsystem(t).activeTSDOFextern);
    d  = Teilsystem(t).DOF;
    keep = d~=0;
    if any(keep)
        F_TS_add = F_TS_add + sparse(d(keep),1, F_TS_kond(a6(keep)), nDOF,1);
    end
end
end
