function ele = lokaleNachGlobal(ele)
% [Schritt 1, Rotation] lokale → globale Steifigkeitsblöcke
for i = 1:numel(ele)
    ele(i).k_glob = rotiereLocalToGlobal_K(ele(i).k_loc, ele(i).R); % existing function
end
end
