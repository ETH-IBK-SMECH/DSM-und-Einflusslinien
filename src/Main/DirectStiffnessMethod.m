function out = DirectStiffnessMethod(model)
% Hauptpipeline
% Analog aufgebaut zu den Schritten auf der DSM-Hilfstabelle

% 1) Stabeigenschaften → Stabsteifigkeitsmatrix → Elementlastvektor
model = elementeErzeugen(model);                % lokale & globale Steifigkeiten pro Stab, Freigaben, Geometrie

[DOF, nDOF, model] = dofNummerieren(model); % DOF-Nummerierung 

% 2) System-Knotenlastvektor
F_sys_Knoten = knotenLastenAssemblieren(model, DOF, nDOF);

% 3) System-Elementlastvektor
[F_sys_Stab, F_sys_TS, model.Stab] = stabLastenAssemblieren(model, DOF, nDOF);

% 4) Systemlastvektor
F_sys = F_sys_Knoten - F_sys_Stab + F_sys_TS;

% 5) Systemsteifigkeitsmatrix
K_sys = systemSteifigkeitAssemblieren(model, DOF, nDOF);

% 6) Federn
K_sys = federnHinzufuegen(K_sys, model.Feder, DOF, nDOF, model.Info.nKnotenDOF);

% 7) Systemdeformationen (& Einflusslinie)
if isfield(model,'gew_output') && model.gew_output==2 && ...
   isfield(model,'Einflusslinie') && model.Einflusslinie.TypEL ~= 4

    % --- Einflusslinie via Lagrange-Multiplikatoren ---
    kond = randbedingungenKondensierenEinflusslinie( ...
                K_sys, F_sys, model.SPC, DOF, nDOF, model.Info.nKnotenDOF, model.Einflusslinie);
    u_free_ext = reduziertesSystemLoesen(kond.K_sys_ff, kond.F_sys_f_kond);
    u_free     = u_free_ext(1:end - kond.nLM);               % drop λ
    U_sys      = verschiebungenEinsammeln(u_free, kond.known, kond.f(1:nDOF), nDOF);

else
    % --- Standardweg ohne Einflusslinie ---
    kond  = randbedingungenKondensieren(K_sys, F_sys, model.SPC, DOF, nDOF, model.Info.nKnotenDOF);
    u_free = reduziertesSystemLoesen(kond.K_sys_ff, kond.F_sys_f_kond);
    U_sys  = verschiebungenEinsammeln(u_free, kond.known, kond.f, nDOF);
end

% 8) Nachrechnung Stabgrössen
model.Stab = stabkraefteBerechnen(model.Stab, U_sys, model.Info.nKnotenDOF);

% 9) Auflagerreaktionen
[Reactions, SPCout, FederOut] = auflagerreaktionenBerechnen(K_sys, U_sys, F_sys_Knoten, F_sys_Stab, model.SPC, model.Feder, DOF, model.Info.nKnotenDOF);

% Ergebnis-Struktur zurückgeben

out = copyFields(model.Knoten, model.Stab, model.Teilsystem, FederOut, ...
                 model.KnotenLast, model.StabLast, SPCout, model.Info, ...
                 model.gew_output, K_sys, F_sys, F_sys_Knoten, F_sys_Stab, ...
                 kond, U_sys, DOF);
end
