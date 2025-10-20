function K_sys = systemSteifigkeitAssemblieren(DOF, nDOF, model)
% [Schritt 5] Systemsteifigkeitsmatrix aufbauen (freie Stäbe + Teilsysteme)
[~, Stab, Teilsystem, ~, ~, ~, ~, Info] = extractFields(model);
K_sys = sparse(nDOF, nDOF);
nkd = Info.nKnotenDOF;

% freie Stäbe
idxFree = find(~[Stab.inTeilSys]);
for ii = 1:numel(idxFree)
    i = idxFree(ii);

    d    = Stab(i).dof_e;                         % 1×(2*nkd)
    mask = (d~=0) & Stab(i).activeStabDOF(:)';    % 1×(2*nkd) logical
    if ~any(mask), continue; end
    if any(mask)
        Kb = Stab(i).k_glob(mask, mask);
        dd = d(mask);
        [rr, cc] = ndgrid(dd, dd);
        K_sys = K_sys + sparse(rr(:), cc(:), Kb(:), nDOF, nDOF);
    end
end

% Teilsysteme
if ~isfield(Stab,'inTeilSys'), [Stab.inTeilSys] = deal(false); end
for t = 1:Info.nTeilsys
    TS = Teilsystem(t);
    if ~isfield(TS,'KnotenTSgeordnet') || numel(TS.KnotenTSgeordnet) < 2
        continue;
    end

    % condensed TS stiffness and activity (external 2*nkd frame)
    [k_ext, activeTS] = tsAssembleAndCondense(TS, Stab, nkd, []);

    % global DOFs of first/last TS node
    sNodeTS = TS.KnotenTSgeordnet(1);
    eNodeTS = TS.KnotenTSgeordnet(end);
    loc6    = [(sNodeTS - 1)*nkd + (1:nkd), (eNodeTS - 1)*nkd + (1:nkd)];
    glob6   = arrayfun(@(idx) safeDOF(idx, DOF), loc6);

    % mask in same 2*nkd frame
    mask = (glob6~=0) & activeTS(:)';            % 1×(2*nkd)
    if ~any(mask), continue; end
    if any(mask)
        Kb = k_ext(mask, mask);
        dd = glob6(mask);
        [rr, cc] = ndgrid(dd, dd);
        K_sys = K_sys + sparse(rr(:), cc(:), Kb(:), nDOF, nDOF);
    end
end
end