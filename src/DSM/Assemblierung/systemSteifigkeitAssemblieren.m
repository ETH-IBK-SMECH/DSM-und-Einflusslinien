function K_sys = systemSteifigkeitAssemblieren(model, DOF, nDOF)
% Systemsteifigkeitsmatrix aufbauen (freie Stäbe + Teilsysteme)
[~, Stab, Teilsystem, ~, ~, ~, ~, Info] = extractFields(model);
nkd = Info.nKnotenDOF;
nFree  = sum(~[Stab.inTeilSys]);
nTS    = Info.nTeilsys;
Icell  = cell(nFree + nTS, 1);
Jcell  = cell(nFree + nTS, 1);
Vcell  = cell(nFree + nTS, 1);
wptr   = 0;

% freie Stäbe
idxFree = find(~[Stab.inTeilSys]);
for k = 1:numel(idxFree)
    i = idxFree(k);

    d    = Stab(i).dof_e;                       % 1×(2*nkd)
    mask = (d ~= 0) & Stab(i).activeStabDOF(:)';% 1×(2*nkd)
    if ~any(mask), continue; end

    Kb = Stab(i).k_glob(mask, mask);
    dd = d(mask);

    [rr, cc] = ndgrid(dd, dd);

    wptr = wptr + 1;
    Icell{wptr} = rr(:);
    Jcell{wptr} = cc(:);
    Vcell{wptr} = Kb(:);
end

% Teilsysteme
if ~isfield(Stab,'inTeilSys'), [Stab.inTeilSys] = deal(false); end
for t = 1:nTS
    TS = Teilsystem(t);
    if ~isfield(TS,'KnotenTSgeordnet') || numel(TS.KnotenTSgeordnet) < 2
        continue;
    end

    [k_ext, activeTS] = tsAssembleAndCondense(TS, Stab, nkd, []);

    sNodeTS = TS.KnotenTSgeordnet(1);
    eNodeTS = TS.KnotenTSgeordnet(end);
    loc6    = [(sNodeTS - 1)*nkd + (1:nkd), (eNodeTS - 1)*nkd + (1:nkd)];

    glob6 = zeros(size(loc6));
    ok    = loc6 >= 1 & loc6 <= numel(DOF);
    glob6(ok) = DOF(loc6(ok));
    glob6(~isfinite(glob6)) = 0;  

    mask = (glob6 ~= 0) & activeTS(:)';     % 1×(2*nkd)
    if ~any(mask), continue; end

    Kb = k_ext(mask, mask);
    dd = glob6(mask);

    [rr, cc] = ndgrid(dd, dd);

    wptr = wptr + 1;
    Icell{wptr} = rr(:);
    Jcell{wptr} = cc(:);
    Vcell{wptr} = Kb(:);
end
if wptr == 0
    K_sys = sparse(nDOF, nDOF);
else
    I = vertcat(Icell{1:wptr});
    J = vertcat(Jcell{1:wptr});
    V = vertcat(Vcell{1:wptr});
    K_sys = sparse(I, J, V, nDOF, nDOF);
end
end