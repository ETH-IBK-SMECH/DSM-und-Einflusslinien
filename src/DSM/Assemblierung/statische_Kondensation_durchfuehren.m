function [K_ff_red, F_f_red, kond] = statische_Kondensation_durchfuehren(model, DOF, kond)
% Statische Kondensation auf der Ebene der freien DOF.
% Erwartet:
%   kond.K_sys_ff, kond.F_sys_f_kond : freie Gleichungen nach Randbedingungen
%   model.Kondensation.Knoten        : zu kondensierende Knoten-IDs (optional)
%   model.Kondensation.KomponentenMaske : 1×nkd-Logikvektor für ux,uy,rz,... (optional)
% Rückgabe:
%   K_ff_red, F_f_red : ggf. kondensierte freie Gleichungen
%   kond.K_ff_voll, kond.F_f_voll : freie Gleichungen VOR Kondensation (für Rückrechnung)
%   kond.Meta.eIdx, kond.Meta.iIdx : Indizes der behaltenen bzw. internen freien DOF
    
    K_ff = kond.K_sys_ff;
    F_f  = kond.F_sys_f_kond;
    
    K_ff_red = K_ff; F_f_red = F_f;
    
    if ~isfield(model, 'Kondensation') || isempty(model.Kondensation)
        e = (1:size(K_ff,1)).';
        kond.K_ff_voll = K_ff;
        kond.F_f_voll  = F_f;
        kond.Meta      = struct('eIdx', e, 'iIdx', [], 'ne', numel(e), 'n', numel(e));
        return;
    end
    
    n = size(K_ff, 1);
    keepMask_ff = dofsZuKondensieren(model, DOF, ...
        model.Kondensation.Knoten, model.Kondensation.KomponentenMaske, n);
    
    if all(keepMask_ff) || ~any(keepMask_ff)
        e = find(keepMask_ff);
        kond.K_ff_voll = K_ff;
        kond.F_f_voll  = F_f;
        kond.Meta      = struct('eIdx', e, ...
                                'iIdx', setdiff((1:n).', e), ...
                                'ne', numel(e), 'n', n);
    else
        [K_ff_red, F_f_red, meta] = condensation(K_ff, F_f, keepMask_ff, 'preserve_size', false);
        kond.K_ff_voll = K_ff;
        kond.F_f_voll  = F_f;
        kond.Meta      = meta;                      
    end
end