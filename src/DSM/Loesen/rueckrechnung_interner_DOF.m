function u_free = rueckrechnung_interner_DOF(kond, u_kept)
% Rekonstruiert den vollständigen freien Verschiebungsvektor nach einer
% statischen Kondensation (freie Ebene).
% kond muss enthalten:
%   - K_ff_voll, F_f_voll : volle freie Gleichungen vor Kondensation
%   - Meta.eIdx, Meta.iIdx: Indizes der behaltenen / internen freien DOF

if ~isfield(kond, 'Meta') || isempty(kond.Meta) || isempty(kond.Meta.iIdx)
    % keine Kondensation → Rückgabe = Eingabe
    u_free = u_kept(:);
    return;
end

e = kond.Meta.eIdx(:);
i = kond.Meta.iIdx(:);

Kee = kond.K_ff_voll(e, e);
Kei = kond.K_ff_voll(e, i);
Kie = kond.K_ff_voll(i, e);
Kii = kond.K_ff_voll(i, i);

fe = kond.F_f_voll(e);
fi = kond.F_f_voll(i);

u_e = u_kept(:);
% u_i = Kii^{-1} ( f_i - K_ie * u_e )
u_i = Kii \ (fi - Kie * u_e);

% zusammensetzen
u_free = zeros(size(kond.F_f_voll), 'like', kond.F_f_voll);
u_free(e) = u_e;
u_free(i) = u_i;
end
