function [Reactions, SPCout, FederOut] = auflagerreaktionenBerechnen(K_sys, U_sys, F_N, P_int, SPC, Feder, DOF, nkd)
% [Schritt 9] Auflagerreaktionen: R = K*U - (F_N - P_int) (physikalische DOF)
nDOF = numel(U_sys);
R_sys = K_sys * U_sys - (F_N - P_int);
Reactions = zeros(nDOF,1);

% SPC
for i = 1:numel(SPC)
    localIdx = (SPC(i).node-1)*nkd + SPC(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        SPC(i).Reaktion = R_sys(g); Reactions(g) = R_sys(g);
    else
        SPC(i).Reaktion = 0;
    end
end

% Feder
for i = 1:numel(Feder)
    localIdx = (Feder(i).node-1)*nkd + Feder(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        Feder(i).Reaktion = R_sys(g);
    else
        Feder(i).Reaktion = 0;
    end
end
SPCout = SPC; FederOut = Feder;
end