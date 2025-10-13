function K_sys = systemSteifigkeitAssemblieren(ele, DOF, nDOF, model)
% [Schritt 5] Systemsteifigkeitsmatrix aufbauen (freie Stäbe + Teilsysteme)
[~, Stab, Teilsystem, ~, ~, ~, ~, Info] = extractFields(model);
K_sys = sparse(nDOF, nDOF);

% freie Stäbe
idxFree = find(~[Stab.inTeilSys]);
for ii = 1:numel(idxFree)
    i = idxFree(ii);
    d = Stab(i).DOF; keep = d~=0;
    if any(keep)
        a6 = find(Stab(i).activeStabDOF); a6=a6(keep); d=d(keep);
        Kb = ele(i).k_glob(a6, a6);
        K_sys = addBlockTo(K_sys, d, Kb, nDOF);
    end
end

% Teilsysteme
for t = 1:Info.nTeilsys
    d = Teilsystem(t).DOF; keep = d~=0;
    if any(keep)
        a6 = find(Teilsystem(t).activeTSDOFextern); a6=a6(keep); d=d(keep);
        Kb = Teilsystem(t).k_glob(a6, a6);
        K_sys = addBlockTo(K_sys, d, Kb, nDOF);
    end
end

    function Ksys = addBlockTo(Ksys, dvec, Kb, nd)
        [rr, cc] = ndgrid(dvec, dvec);
        Ksys = Ksys + sparse(rr(:), cc(:), Kb(:), nd, nd);
    end
  
end
