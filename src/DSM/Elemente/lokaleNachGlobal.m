function Stab = lokaleNachGlobal(Stab)
% [Schritt 1, Rotation] lokale → globale Steifigkeitsblöcke
for i = 1:numel(Stab)
    Stab(i).k_glob = rotiereLocalToGlobal_K(Stab(i).k_loc, Stab(i).R);
end
