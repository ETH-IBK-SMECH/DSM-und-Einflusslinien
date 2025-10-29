function kond = randbedingungenKondensieren(K_sys, F_sys, SPC, DOF, nDOF, nkd)
% Statische Kondensation bei vorgegebenen Verschiebungen
isKnown = false(1,nDOF); U_s = zeros(nDOF,1);
for i = 1:numel(SPC)
    localIdx = (SPC(i).node-1)*nkd + SPC(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        isKnown(g) = true; U_s(g) = U_s(g) + SPC(i).val;
    end
end
freeMask = ~isKnown;

% K_ff, f_f - K_fs*u_s 
[K_red, F_red] = condensation(K_sys, F_sys, freeMask, 'preserve_size', false, 'known_ui', U_s(isKnown));

kond = struct('K_sys_ff',K_red, 'F_sys_f_kond',F_red, ...
              's',isKnown, 'f',freeMask, 'DOF',find(freeMask), ...
              'known',struct('mask',isKnown,'U_s',U_s(isKnown)));
end
