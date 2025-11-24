function out = DirectStiffnessMethod(model)
% Hauptpipeline
% Analog aufgebaut zu den Schritten auf der DSM-Hilfstabelle

%% 1) Stabeigenschaften --> Stabsteifigkeitsmatrix --> Elementlastvektor
model = elementeErzeugen(model);

[DOF, nDOF, model] = dofNummerieren(model);

%% 2) Systemknotenlastvektor
F_sys_Knoten = knotenLastenAssemblieren(model, DOF, nDOF);

%% 3) Systemelementlastvektor
[F_sys_Stab, model.Stab] = stabLastenAssemblieren(model, DOF, nDOF);

%% 4) Systemlastvektor
F_sys = F_sys_Knoten - F_sys_Stab;

%% 5) Systemsteifigkeitsmatrix
K_sys = systemSteifigkeitAssemblieren(model, DOF, nDOF);

%% 6) Federn
K_sys = federnHinzufuegen(K_sys, model.Feder, DOF, nDOF, model.Info.nKnotenDOF);

%% 7) Systemdeformationen (& Einflusslinie)
if isfield(model, 'gew_output') && model.gew_output == 2 && ...
        isfield(model, 'Einflusslinie') && model.Einflusslinie.TypEL ~= 4

    % --- Einflusslinie via Lagrange-Multiplikatoren ---
    kond = randbedingungenKondensierenEinflusslinie( ...
        K_sys, F_sys, model.SPC, DOF, model.Info.nKnotenDOF, model.Einflusslinie);
    u_free_ext = reduziertesSystemLoesen(kond.K_sys_ff, kond.F_sys_f_kond);
    u_kept = [];
    u_free_phys = u_free_ext(1:end-kond.nLM);
    known = struct('U_s', kond.known_U_vector);
    U_sys = verschiebungenEinsammeln(u_free_phys, known, kond.phys_freeMask, nDOF);

else
    % --- Standardweg ohne Einflusslinie ---
    kond = randbedingungenKondensieren(K_sys, F_sys, model.SPC, DOF, nDOF, model.Info.nKnotenDOF);
    % optionale statische Kondensation (auf freie DOF)
    [K_ff_red, F_f_red, kond] = statische_Kondensation_durchfuehren(model, DOF, kond);
    u_kept = reduziertesSystemLoesen(K_ff_red, F_f_red);
    % Rückrechnung interner freie DOF (falls Kondensation stattfand)
    u_free = rueckrechnung_interner_DOF(kond, u_kept);
    U_sys = verschiebungenEinsammeln(u_free, kond.known, kond.f, nDOF);
end

%% 8) Nachrechnung Stabgrössen
model.Stab = stabkraefteBerechnen(model.Stab, U_sys, model.Info.nKnotenDOF);

%% 9) Auflagerreaktionen
[Reaktionen, SPCout, FederOut] = auflagerreaktionenBerechnen(K_sys, U_sys, F_sys_Knoten, F_sys_Stab, model.SPC, model.Feder, DOF, model.Info.nKnotenDOF);

% Ergebnis-Struktur zurückgeben

out = copyFields(model.Knoten, model.Stab, FederOut, ...
    model.KnotenLast, model.StabLast, SPCout, model.Info, ...
    model.gew_output, model.Einflusslinie, K_sys, F_sys, F_sys_Knoten, F_sys_Stab, ...
    kond, U_sys, DOF, u_kept, Reaktionen);
end
