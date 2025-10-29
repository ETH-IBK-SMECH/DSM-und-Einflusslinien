function [F_stab_sys, Stab] = stabLastenAssemblieren(model, DOF, nDOF)
    % System-Elementlastvektor
    [~, Stab, ~, ~, StabLast] = extractFields(model);
    nkd = model.Info.nKnotenDOF;
    n6  = 2*nkd;

    F_stab_sys = sparse(nDOF,1);
    if isempty(StabLast) || isempty(Stab), return; end

    % Sicherstellen dass P_int existiert
    for s = 1:numel(Stab)
        if ~isfield(Stab(s),'P_int') || isempty(Stab(s).P_int)
            Stab(s).P_int = zeros(n6,1);
        end
    end
    
    for i = 1:numel(StabLast)
        sIdx = StabLast(i).stab;
        if sIdx < 1 || sIdx > numel(Stab), continue; end

        % lokale Endlasten
        f_loc = getF(StabLast(i), Stab(sIdx).L);     % 6x1 lokal
        [~, f_loc] = condensation(Stab(sIdx).k_loc_v, f_loc, Stab(sIdx).vorhandeneDOF, 'preserve_size', true);
        Stab(sIdx).P_int = Stab(sIdx).P_int + f_loc; 

        % Globaler Lastvektor Assemblieren
        f_g = rotiereLocalToGlobal_F(f_loc, Stab(sIdx).R);
        f_g = f_g(:);

        dof_e = [(Stab(sIdx).sNode-1)*nkd + (1:nkd), (Stab(sIdx).eNode-1)*nkd + (1:nkd)];
        g     = DOF(dof_e);
        if isfield(Stab(sIdx),'activeStabDOF') && ~isempty(Stab(sIdx).activeStabDOF)
            elemActive = Stab(sIdx).activeStabDOF(:).';
        else
            elemActive = true(1, n6);
        end
        act = (g > 0) & elemActive;

        if any(act)
            F_stab_sys = F_stab_sys + sparse(g(act), 1, f_g(act), nDOF, 1);
        end
    end
end
