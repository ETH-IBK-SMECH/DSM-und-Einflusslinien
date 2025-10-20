function [ok, issues] = validateAnalysisModel(A)
% Purpose: structural input is *self-consistent* and numerically usable.
% No mutation; only checks.

    issues = {};
    tol = 1e-12;

    % --- basic presence ---
    for f = {'Knoten','Stab','SPC','Info'}
        if ~isfield(A, f{1})
            issues{end+1} = sprintf('Missing field A.%s.', f{1});
        end
    end

    % --- nDOF per node ---
    if ~isfield(A,'Info') || ~isfield(A.Info,'nKnotenDOF') ...
            || ~isscalar(A.Info.nKnotenDOF) || ~isfinite(A.Info.nKnotenDOF)
        issues{end+1} = 'Info.nKnotenDOF missing/invalid; expected finite scalar.';
        nDOFperNode = 3; % continue with default for checking
    else
        nDOFperNode = A.Info.nKnotenDOF;
    end

    % --- counts ---
    nKnoten = numel(getfield(A,'Knoten')); %#ok<GFLD>
    nStab   = numel(getfield(A,'Stab'));

    if nStab>0 && nKnoten<2
        issues{end+1} = 'At least two nodes required when members are present.';
    end
    if ~isfield(A,'SPC') || isempty(A.SPC)
        issues{end+1} = 'No supports (SPC) defined; system may be a mechanism.';
    end

    % --- nodes ---
    for i=1:nKnoten
        if ~isfield(A.Knoten(i),'x') || ~isfield(A.Knoten(i),'y') ...
           || ~isscalar(A.Knoten(i).x) || ~isscalar(A.Knoten(i).y) ...
           || ~isfinite(A.Knoten(i).x) || ~isfinite(A.Knoten(i).y)
            issues{end+1} = sprintf('Node %d has invalid coordinates.', i);
        end
    end

    % --- members ---
    for i=1:nStab
        if ~isfield(A.Stab(i),'sNode') || ~isfield(A.Stab(i),'eNode') ...
           || ~isfinite(A.Stab(i).sNode) || ~isfinite(A.Stab(i).eNode)
            issues{end+1} = sprintf('Member %d: missing/invalid sNode/eNode.', i);
            continue;
        end
        s = A.Stab(i).sNode; e = A.Stab(i).eNode;
        if ~(s>=1 && s<=nKnoten) || ~(e>=1 && e<=nKnoten)
            issues{end+1} = sprintf('Member %d: sNode/eNode out of range.', i);
        elseif s == e
            issues{end+1} = sprintf('Member %d: identical start and end node.', i);
        else
            L = hypot(A.Knoten(e).x - A.Knoten(s).x, A.Knoten(e).y - A.Knoten(s).y);
            if ~isfinite(L) || L < tol
                issues{end+1} = sprintf('Member %d has near-zero length.', i);
            end
        end
        for prop = {'E','A','Iy'}
            if ~isfield(A.Stab(i),prop{1}) || ~isfinite(A.Stab(i).(prop{1})) || ~(A.Stab(i).(prop{1})>0)
                issues{end+1} = sprintf('Member %d: %s must be > 0.', i, prop{1});
            end
        end
        % release indices
        for relf = {'sRelease','eRelease'}
            if isfield(A.Stab(i), relf{1}) && ~isempty(A.Stab(i).(relf{1}))
                bad = A.Stab(i).(relf{1})( ~ismember(A.Stab(i).(relf{1}), 1:nDOFperNode) );
                if ~isempty(bad)
                    issues{end+1} = sprintf('Member %d: %s contains invalid DOF index.', i, relf{1});
                end
            end
        end
    end

    % --- springs ---
    if isfield(A,'Feder')
        for i = 1:numel(A.Feder)
            if ~isfield(A.Feder(i),'node') || ~isfinite(A.Feder(i).node) || ~(A.Feder(i).node>=1 && A.Feder(i).node<=nKnoten)
                issues{end+1} = sprintf('Spring %d: invalid node index.', i);
            end
            if ~isfield(A.Feder(i),'val') || ~isfinite(A.Feder(i).val) || ~(A.Feder(i).val>=0)
                issues{end+1} = sprintf('Spring %d: stiffness val must be >= 0.', i);
            end
            % dir==0 means "ignored" (from sanitize); only check when nonzero
            if isfield(A.Feder(i),'dir') && A.Feder(i).dir~=0 ...
               && ~ismember(A.Feder(i).dir, 1:nDOFperNode)
                issues{end+1} = sprintf('Spring %d: dir must be 1..%d.', i, nDOFperNode);
            end
        end
    end


    % --- node loads ---
    if isfield(A,'KnotenLast')
        for i = 1:numel(A.KnotenLast)
            if ~isfield(A.KnotenLast(i),'node') || ~isfinite(A.KnotenLast(i).node) || ~(A.KnotenLast(i).node>=1 && A.KnotenLast(i).node<=nKnoten)
                issues{end+1} = sprintf('Node load %d: node index out of range.', i);
            end
            % dir==0 is "ignored"; only check when nonzero
            if ~isfield(A.KnotenLast(i),'dir') || ~(isscalar(A.KnotenLast(i).dir))
                issues{end+1} = sprintf('Node load %d: dir missing/invalid.', i);
            elseif A.KnotenLast(i).dir~=0 && ~ismember(A.KnotenLast(i).dir, 1:nDOFperNode)
                issues{end+1} = sprintf('Node load %d: dir must be 1..%d.', i, nDOFperNode);
            end
            if ~isfield(A.KnotenLast(i),'val') || ~isfinite(A.KnotenLast(i).val)
                issues{end+1} = sprintf('Node load %d: val missing/invalid.', i);
            end
        end
    end

    % --- member loads (minimal schema) ---
    if isfield(A,'StabLast')
        for i = 1:numel(A.StabLast)
            if ~isfield(A.StabLast(i),'stab') || ~isfinite(A.StabLast(i).stab) || ~(A.StabLast(i).stab>=1 && A.StabLast(i).stab<=nStab)
                issues{end+1} = sprintf('Member load %d: invalid member index.', i);
            end
            if ~isfield(A.StabLast(i),'typ') || ~ismember(A.StabLast(i).typ, [1 2 3 4 5 6])
                issues{end+1} = sprintf('Member load %d: unknown typ.', i);
            end
        end
    end

    % --- SPCs ---
    if isfield(A,'SPC')
        for i = 1:numel(A.SPC)
            if ~isfield(A.SPC(i),'node') || ~isfinite(A.SPC(i).node) || ~(A.SPC(i).node>=1 && A.SPC(i).node<=nKnoten)
                issues{end+1} = sprintf('SPC %d: invalid node index.', i);
            end
            if ~isfield(A.SPC(i),'dir') || ~isscalar(A.SPC(i).dir) || ~ismember(A.SPC(i).dir, 1:nDOFperNode)
                issues{end+1} = sprintf('SPC %d: dir must be 1..%d.', i, nDOFperNode);
            end
            if ~isfield(A.SPC(i),'val') || ~isfinite(A.SPC(i).val)
                issues{end+1} = sprintf('SPC %d: val missing/invalid.', i);
            end
        end
    end

    ok = isempty(issues);
end
