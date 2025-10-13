function [Reactions, SPCout, FederOut] = auflagerreaktionenBerechnen(K_sys, U_sys, F_N, P_int, SPC, Feder, DOF)
% [Schritt 9] Auflagerreaktionen: R = K*U - (F_N - P_int) (physikalische DOF)
nDOF = numel(U_sys);
K_phys   = K_sys(1:nDOF, 1:nDOF);
F_k_phys = F_N(1:nDOF);
F_s_phys = P_int(1:nDOF);
U_phys   = U_sys(1:nDOF);

R_sys = K_phys * U_phys - (F_k_phys - F_s_phys);

Reactions = zeros(nDOF,1);

% Reaktionen an SPC
for i = 1:numel(SPC)
    g = SPC(i).DOF;
    if g ~= 0
        SPC(i).Reaktion = R_sys(g);
        Reactions(g) = R_sys(g);
    else
        SPC(i).Reaktion = 0;
    end
end

% Reaktionen an Federn
for i = 1:numel(Feder)
    g = Feder(i).DOF;
    if g ~= 0
        Feder(i).Reaktion = R_sys(g);
    else
        Feder(i).Reaktion = 0;
    end
end

SPCout = SPC;
FederOut = Feder;
end
