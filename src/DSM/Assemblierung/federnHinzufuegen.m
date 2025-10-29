function K_sys = federnHinzufuegen(K_sys, Feder, DOF, nDOF, nkd)
% Federn diagonal addieren
for i = 1:numel(Feder)
    if ~isfield(Feder(i),'node') || ~isfield(Feder(i),'dir'), continue; end
    localIdx = (Feder(i).node-1)*nkd + Feder(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        K_sys = K_sys + sparse(g, g, Feder(i).val, nDOF, nDOF);
    end
end
end
