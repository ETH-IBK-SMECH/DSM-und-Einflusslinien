function ele = elementeErzeugen(model)
% [Schritt 1] Stabeigenschaften, lokale Steifigkeit (inkl. Freigaben), Elementlastvektor (leer)
[Knoten, Stab, ~, ~, ~, ~, ~, Info] = extractFields(model);

nkd = Info.nKnotenDOF; n6 = 2*nkd;
ele = struct('L',[],'c',[],'s',[],'R',[],'k_loc_v',[],'k_loc',[],'k_glob',[],'P_int',[]);

for i = 1:Info.nStaebe
    sN = Stab(i).sNode; eN = Stab(i).eNode;
    sX = Knoten(sN).x;  eX = Knoten(eN).x;
    sY = Knoten(sN).y;  eY = Knoten(eN).y;

    L = hypot(eX - sX, eY - sY);
    c = (eX - sX)/L; s = (eY - sY)/L;
    R = getR(c, s);          % existing function

    k_loc_v = getK(Stab(i).E, Stab(i).A, Stab(i).Iy, L);  % existing function

    % vorhandeneDOF aus Releases ableiten (wie im ursprünglichen Main)
    vorhanden = true(1,n6);
    if isfield(Stab(i),'sRelease') && ~isempty(Stab(i).sRelease)
        vorhanden(Stab(i).sRelease) = false;
    end
    if isfield(Stab(i),'eRelease') && ~isempty(Stab(i).eRelease)
        vorhanden(Stab(i).eRelease + nkd) = false;
    end
    % lokale Freigaben kondensieren
    [k_loc, ~] = condensation(k_loc_v, [], vorhanden, 'preserve_size', true); % existing

    ele(i).L = L; ele(i).c = c; ele(i).s = s; ele(i).R = R;
    ele(i).k_loc_v = k_loc_v;
    ele(i).k_loc   = k_loc;
    ele(i).k_glob  = [];                % in lokaleNachGlobal()
    ele(i).P_int   = zeros(n6,1);       % wird bei Lastassemblierung gefüllt
end
end
