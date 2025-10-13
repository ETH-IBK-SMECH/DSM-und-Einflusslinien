function K_sys = federnHinzufuegen(K_sys, Feder, DOF, nDOF)
% [Schritt 6] Federn diagonal addieren
for i = 1:numel(Feder)
    g = Feder(i).DOF;
    if g ~= 0
        K_sys = K_sys + sparse(g, g, Feder(i).val, nDOF, nDOF);
    end
end
end
