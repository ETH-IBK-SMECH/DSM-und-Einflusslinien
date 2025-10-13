function ele = stabkraefteBerechnen(ele, U_sys, maps, model)
% [Schritt 8] Stabendkräfte (lokal/global) berechnen
[~, Stab, ~, ~, ~, ~, ~, Info] = extractFields(model);
n6 = maps.n6;

for i = find(~[Stab.inTeilSys])
    d   = Stab(i).DOF;
    a6  = find(Stab(i).activeStabDOF);
    u_glob = zeros(n6,1);
    keep = d ~= 0;
    if any(keep)
        u_glob(a6(keep)) = u_glob(a6(keep)) + U_sys(d(keep));
    end
    u_loc = rotiereGlobalToLocal_u(u_glob, ele(i).R);                   % existing
    q_loc = ele(i).k_loc * u_loc + ele(i).P_int;
    q_glob = rotiereLocalToGlobal_F(q_loc, ele(i).R);                   % existing

    ele(i).u_glob = u_glob; ele(i).u_loc = u_loc;
    ele(i).q_loc  = q_loc;  ele(i).q_glob = q_glob;
    ele(i).q_loc_sk = q_loc .* [-1;1;-1;1;-1;1];                       % gleich wie im Original
end

% Optional: Verdrehungen an Momentengelenken korrigieren (wie Original)
for i = 1:Info.nStaebe
    if isfield(ele(i),'u_loc') && ~isempty(ele(i).u_loc)
        ele(i).u_loc = VerdrehungMomentengelenk(ele(i).u_loc, ele(i).L, Stab(i).vorhandeneDOF); % existing
    end
end
end
