function analysis = sanitizeAnalysisModel(analysis)

    if ~isfield(analysis, 'Info') || ~isfield(analysis.Info, 'nKnotenDOF')
        analysis.Info.nKnotenDOF = 3;
    end
    nDOFperNode = analysis.Info.nKnotenDOF;

    % Ensure arrays exist
    fields = {'Knoten','Stab','Teilsystem','Feder','KnotenLast','StabLast','SPC'};
    for k = 1:numel(fields)
        f = fields{k};
        if ~isfield(analysis, f) || isempty(analysis.(f))
            analysis.(f) = [];
        end
    end

    % Releases → clamp to 1..nDOFperNode and unique
    for i = 1:numel(analysis.Stab)
        if ~isfield(analysis.Stab(i), 'sRelease') || isempty(analysis.Stab(i).sRelease), analysis.Stab(i).sRelease = []; end
        if ~isfield(analysis.Stab(i), 'eRelease') || isempty(analysis.Stab(i).eRelease), analysis.Stab(i).eRelease = []; end
        analysis.Stab(i).sRelease = unique(analysis.Stab(i).sRelease(:)');
        analysis.Stab(i).eRelease = unique(analysis.Stab(i).eRelease(:)');
        analysis.Stab(i).sRelease = analysis.Stab(i).sRelease( analysis.Stab(i).sRelease>=1 & analysis.Stab(i).sRelease<=nDOFperNode );
        analysis.Stab(i).eRelease = analysis.Stab(i).eRelease( analysis.Stab(i).eRelease>=1 & analysis.Stab(i).eRelease<=nDOFperNode );
    end

    % Springs: clamp dir to 1..3 if present
    for i = 1:numel(analysis.Feder)
        if ~isfield(analysis.Feder(i), 'dir') || ~isfinite(analysis.Feder(i).dir)
            analysis.Feder(i).dir = 0;  % will be ignored later
        end
        if analysis.Feder(i).dir < 1 || analysis.Feder(i).dir > 3
            analysis.Feder(i).dir = 0;
        end
    end

    % Node loads: default dir clamp
    for i = 1:numel(analysis.KnotenLast)
        if ~isfield(analysis.KnotenLast(i), 'dir') || ~isfinite(analysis.KnotenLast(i).dir)
            analysis.KnotenLast(i).dir = 0;
        end
        if analysis.KnotenLast(i).dir < 1 || analysis.KnotenLast(i).dir > nDOFperNode
            analysis.KnotenLast(i).dir = 0;
        end
    end

    % StabLast: fill optional fields if missing
    for i = 1:numel(analysis.StabLast)
        if ~isfield(analysis.StabLast(i), 'sDist') || isempty(analysis.StabLast(i).sDist)
            analysis.StabLast(i).sDist = 0;
        end
        if ~isfield(analysis.StabLast(i), 'eDist') || isempty(analysis.StabLast(i).eDist)
            analysis.StabLast(i).eDist = analysis.StabLast(i).sDist;
        end
    end
end