function [Reactions, SPCout, FederOut] = auflagerreaktionenBerechnen(K_sys, U_sys, F_N, P_int, SPC, Feder, DOF, nkd)
% Auflagerreaktionen: R = K*U - (F_N - P_int) (physikalische DOF)
nDOF = numel(U_sys);
R_sys = K_sys * U_sys - (F_N - P_int);
% Numerische Rundungsfehler null setzen
tolR = 1e-12 * max(1, norm(R_sys, inf));
R_sys(abs(R_sys) < tolR) = 0;
Reactions = zeros(nDOF, 1);

% SPC
for i = 1:numel(SPC)
    localIdx = (SPC(i).node - 1) * nkd + SPC(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        SPC(i).Reaktion = R_sys(g);
        Reactions(g) = R_sys(g);
    else
        SPC(i).Reaktion = 0;
    end
end

% Feder
for i = 1:numel(Feder)
    localIdx = (Feder(i).node - 1) * nkd + Feder(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        Feder(i).Reaktion = -Feder(i).val * U_sys(g);
    else
        Feder(i).Reaktion = 0;
    end
end
SPCout = SPC;
FederOut = Feder;
end
