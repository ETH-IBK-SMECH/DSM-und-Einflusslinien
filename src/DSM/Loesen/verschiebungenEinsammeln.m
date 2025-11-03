function U_sys = verschiebungenEinsammeln(u_free, known, freeMask, nDOF)
% Setzt freie und bekannte Verschiebungen zu U_sys zusammen
U_sys = zeros(nDOF, 1);
U_sys(freeMask) = u_free;
U_sys(~freeMask) = known.U_s;
end
