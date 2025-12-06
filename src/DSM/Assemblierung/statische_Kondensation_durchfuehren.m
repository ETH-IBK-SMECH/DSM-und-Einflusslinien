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
F_f = kond.F_sys_f_kond;

K_ff_red = K_ff;
F_f_red = F_f;

% Kein Kondensations-Block im Model -> sofort zurück
if ~isfield(model, 'Kondensation') || isempty(model.Kondensation)
    e = (1:size(K_ff, 1)).';
    kond.K_ff_voll = K_ff;
    kond.F_f_voll = F_f;
    kond.Meta = struct('eIdx', e, 'iIdx', [], 'ne', numel(e), 'n', numel(e));
    return;
end

n = size(K_ff, 1);
keepMask_ff = dofsZuKondensieren(model, DOF, kond, ...
    model.Kondensation.Knoten, model.Kondensation.KomponentenMaske);

num_kept   = nnz(keepMask_ff);
num_intern = n - num_kept;

% --- Fall A: keine internen DOF -> nichts zu kondensieren ---
if num_intern == 0
    e = find(keepMask_ff);
    kond.K_ff_voll = K_ff;
    kond.F_f_voll  = F_f;
    kond.Meta = struct('eIdx', e, 'iIdx', [], 'ne', numel(e), 'n', n);
    return;
end

% --- Fall B: keine externen DOF -> physikalisch unsinnig -> überspringen ---
if num_kept == 0
    warning('Statische Kondensation: alle freien DOF als intern markiert – Kondensation wird übersprungen.');
    e = (1:n).';
    keepMask_ff(:) = true;   % alles behalten
    kond.K_ff_voll = K_ff;
    kond.F_f_voll  = F_f;
    kond.Meta = struct('eIdx', e, 'iIdx', [], 'ne', n, 'n', n);
    return;
end

[K_ff_red, F_f_red, meta] = condensation(K_ff, F_f, keepMask_ff, 'preserve_size', false);
kond.K_ff_voll = K_ff;
kond.F_f_voll = F_f;
kond.Meta = meta;

kond.K_ff_red = K_ff_red;
kond.F_f_red  = F_f_red;
end
