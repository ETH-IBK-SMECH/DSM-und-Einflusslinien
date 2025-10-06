function [ok, issues] = validateAnalysisModel(A)
% Coarse validation; avoid deep mechanics here.
    issues = {};
    tol = 1e-12;

    % Existence
    req = {'Knoten','Stab','SPC','Info'};
    for k=1:numel(req)
        if ~isfield(A, req{k})
            issues{end+1} = sprintf('Missing field A.%s.', req{k});
        end
    end

    % Counts
    nKnoten = numel(A.Knoten);
    nStab   = numel(A.Stab);
    if nStab>0 && nKnoten<2, issues{end+1} = 'At least two nodes required for members.'; end
    if isempty(A.SPC), issues{end+1} = 'No supports defined; system may be a mechanism.'; end

    % Nodes
    for i=1:nKnoten
        if ~isfield(A.Knoten(i),'x') || ~isfield(A.Knoten(i),'y') || ~isfinite(A.Knoten(i).x) || ~isfinite(A.Knoten(i).y)
            issues{end+1} = sprintf('Node %d has invalid coordinates.', i);
        end
    end

    % Members
    for i=1:nStab
        s = A.Stab(i).sNode; e = A.Stab(i).eNode;
        if ~(isfinite(s) && s>=1 && s<=nKnoten) || ~(isfinite(e) && e>=1 && e<=nKnoten)
            issues{end+1} = sprintf('Member %d references invalid node index.', i); continue;
        end
        if s == e, issues{end+1} = sprintf('Member %d has identical start and end node.', i); end
        if ~isfinite(A.Stab(i).E) || A.Stab(i).E<=0,  issues{end+1} = sprintf('Member %d: E must be > 0.', i); end
        if ~isfinite(A.Stab(i).A) || A.Stab(i).A<=0,  issues{end+1} = sprintf('Member %d: A must be > 0.', i); end
        if ~isfinite(A.Stab(i).Iy) || A.Stab(i).Iy<=0, issues{end+1} = sprintf('Member %d: Iy must be > 0.', i); end
        L = hypot(A.Knoten(e).x - A.Knoten(s).x, A.Knoten(e).y - A.Knoten(s).y);
        if L < tol, issues{end+1} = sprintf('Member %d has (near) zero length.', i); end
        if isfield(A.Stab(i),'sRelease')
            bad = A.Stab(i).sRelease(~ismember(A.Stab(i).sRelease, [1 2 3]));
            if ~isempty(bad), issues{end+1} = sprintf('Member %d: sRelease contains invalid DOF index.', i); end
        end
        if isfield(A.Stab(i),'eRelease')
            bad = A.Stab(i).eRelease(~ismember(A.Stab(i).eRelease, [1 2 3]));
            if ~isempty(bad), issues{end+1} = sprintf('Member %d: eRelease contains invalid DOF index.', i); end
        end
    end

    % Springs
    for i = 1:numel(A.Feder)
        if A.Feder(i).dir<1 || A.Feder(i).dir>3
            issues{end+1} = sprintf('Spring %d: dir must be 1..3.', i);
        end
    end

    % Node loads
    for i = 1:numel(A.KnotenLast)
        if ~(A.KnotenLast(i).dir>=1 && A.KnotenLast(i).dir<=3)
            issues{end+1} = sprintf('Node load %d: dir must be 1..3.', i);
        end
        if ~(A.KnotenLast(i).node>=1 && A.KnotenLast(i).node<=nKnoten)
            issues{end+1} = sprintf('Node load %d: node index out of range.', i);
        end
    end

    % Member loads
    for i = 1:numel(A.StabLast)
        if ~(A.StabLast(i).stab>=1 && A.StabLast(i).stab<=nStab)
            issues{end+1} = sprintf('Member load %d: invalid member index.', i);
        end
        if ~isfield(A.StabLast(i),'typ') || ~ismember(A.StabLast(i).typ, [1 2 3 4 5 6])
            issues{end+1} = sprintf('Member load %d: unknown typ.', i);
        end
    end

    ok = isempty(issues);
end