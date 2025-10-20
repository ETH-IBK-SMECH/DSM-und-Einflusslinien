function Stab = lokalZuGlobal(Stab)
% lokale → globale Steifigkeitsblöcke (Wrapper um DirectStiffnessMethod
% kurz zu halten)
for i = 1:numel(Stab)
    Stab(i).k_glob = rotiereLocalToGlobal_K(Stab(i).k_loc, Stab(i).R);
end
