function F_N = knotenLastenAssemblieren(model, DOF, nDOF)
% [Schritt 2] System-Knotenlastvektor
F_N = sparse(nDOF,1);
[~, ~, ~, ~, KnotenLast, ~, ~, Info] = extractFields(model);

for i = 1:Info.nKnotenLasten
    g = KnotenLast(i).DOF;
    if g ~= 0
        F_N(g) = F_N(g) + KnotenLast(i).val;
    end
end
end
