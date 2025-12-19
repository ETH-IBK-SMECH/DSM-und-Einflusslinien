function ok = validateCurrentTable(app, tableKey, in, issues1)
%Verify the input of a given table and throw error
%Needed for verifying the input before live visualization

ok = true;
issues2.ok = true;
issues2.messages = {};

switch tableKey
    case ("NodeTable")
        if ~isempty(in.Knoten)
            issues2 = mergeIssues(app, issues2, validateNode(in));
        end
    case ("BeamTable")
        if ~isempty(in.Staebe)
            issues2 = mergeIssues(app, issues2, validateBeam(in));
            if ~isempty(in.Querschnitte)
                secNames = string(in.Querschnitte.Name);
            else
                secNames = string.empty(0, 1); % no materials defined
            end
            beamSecNames = string(in.Staebe.Querschnitt);

            [~, secIdx] = ismember(beamSecNames, secNames);

            % check for unmapped entries (empty / wrong / "– wählen –")
            issues2 = collect(app, issues2, @() app.ensureAllMapped(secIdx, ...
                'Stäbe', ... % srcTableLabel
                'Querschnitt', ... % srcColLabel
                'Querschnitte')); % targetTableLabel
        end
    case ("SupportTable")
        if ~isempty(in.Lager)
            issues2 = mergeIssues(app, issues2, validateSupport(in));
        end
    case ("SpringTable")
        if ~isempty(in.Feder)
            issues2 = mergeIssues(app, issues2, validateSpring(in));
        end
    case ("NodalLoadTable")
        if ~isempty(in.KnotenLasten)
            issues2 = mergeIssues(app, issues2, validateNodalLoad(in));
        end
    case ("PointLoadTable")
        if ~isempty(in.StabLasten_konzentriert)
            issues2 = mergeIssues(app, issues2, validatePointLoad(in));
        end
    case ("DistrLoadTable")
        if ~isempty(in.StabLasten_verteilt)
            issues2 = mergeIssues(app, issues2, validateDistrLoad(in));
        end

end

issues = mergeIssues(app, issues1, issues2);
if ~issues.ok
    msg = strjoin(issues.messages, newline);
    uialert(app.UIFigure, msg, 'Eingabefehler');
    ok = false;
end

end
