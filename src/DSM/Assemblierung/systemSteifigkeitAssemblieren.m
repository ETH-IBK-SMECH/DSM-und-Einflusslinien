function K_sys = systemSteifigkeitAssemblieren(model, DOF, nDOF)
% Systemsteifigkeitsmatrix aufbauen (nur freie Stäbe; keine Teilsysteme)

[~, Stab, ~, ~, ~, ~, Info] = extractFields(model);
nkd = Info.nKnotenDOF;

Icell = cell(numel(Stab), 1);
Jcell = cell(numel(Stab), 1);
Vcell = cell(numel(Stab), 1);
wptr = 0;

for k = 1:numel(Stab)
    d = Stab(k).dof_e;
    if ~isfield(Stab(k), 'activeStabDOF') || isempty(Stab(k).activeStabDOF)
        actMask = d ~= 0;
    else
        actMask = (d ~= 0) & logical(Stab(k).activeStabDOF(:)'); % 1×(2*nkd)
    end

    if ~any(actMask), continue; end

    % Globaler Element Steifigkeitsmatrix
    K_e_g = Stab(k).k_glob; % (2*nkd)×(2*nkd)

    dd = d(actMask);
    Kb = K_e_g(actMask, actMask);

    [rr, cc] = ndgrid(dd, dd); % |dd|×|dd|
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
