function Stab = stabkraefteBerechnen(Stab, U_sys, nkd)
% Stabendkräfte (lokal/global) berechnen
n6 = 2 * nkd;
for i = 1:numel(Stab)
    d = Stab(i).dof_e; % 1×(2*nkd)
    mask = Stab(i).activeStabDOF(:)' & (d ~= 0); % 1×(2*nkd) logical
    u_glob = zeros(n6, 1);
    if any(mask)
        u_glob(mask) = U_sys(d(mask));
    end
    u_loc = rotiereGlobalToLocal_u(u_glob, Stab(i).R);
    q_loc = Stab(i).k_loc * u_loc + Stab(i).P_int;
    q_glob = rotiereLocalToGlobal_F(q_loc, Stab(i).R);

    Stab(i).u_glob = u_glob;
    Stab(i).u_loc = u_loc;
    Stab(i).q_loc = q_loc;
    Stab(i).q_glob = q_glob;
    Stab(i).q_loc_sk = q_loc .* [-1; 1; -1; 1; -1; 1];
end

% Verdrehungen an Momentengelenken korrigieren (wie Original)
for i = 1:numel(Stab)
    if isfield(Stab(i), 'u_loc') && ~isempty(Stab(i).u_loc)
        Stab(i).u_loc = verdrehungMomentengelenk(Stab(i).u_loc, Stab(i).L, Stab(i).vorhandeneDOF);
    end
end
end
