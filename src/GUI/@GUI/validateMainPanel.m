function issues = validateMainPanel(app, in, mainKey)
% mainKey: "Material", "Section", "Beam", "Actions"
issues.ok = true;
issues.messages = {};

switch mainKey
    case "Material"
        if ~isempty(in.Material)
            issues = mergeIssues(app, issues, validateMaterial(in));
        end
    case "Section"
        if ~isempty(in.Querschnitte)
            issues = mergeIssues(app, issues, validateSection(in));
            if ~isempty(in.Material)
                matNames = string(in.Material.Name);
            else
                matNames = string.empty(0, 1); % no materials defined
            end
            secMatNames = string(in.Querschnitte.Material);

            [~, matIdx] = ismember(secMatNames, matNames);

            % check for unmapped entries (empty / wrong / "– wählen –")
            issues = app.collect(issues, @() app.ensureAllMapped(matIdx, ...
                'Querschnitte', ... % srcTableLabel
                'Material', ... % srcColLabel
                'Material')); % targetTableLabel
        end
    case "Beam"
        if ~isempty(in.Knoten)
            issues = mergeIssues(app, issues, validateNode(in));
        end
        if ~isempty(in.Staebe)
            issues = mergeIssues(app, issues, validateBeam(in));
            if ~isempty(in.Querschnitte)
                secNames = string(in.Querschnitte.Name);
            else
                secNames = string.empty(0, 1); % no materials defined
            end
            beamSecNames = string(in.Staebe.Querschnitt);

            [~, secIdx] = ismember(beamSecNames, secNames);

            % check for unmapped entries (empty / wrong / "– wählen –")
            issues = app.collect(issues, @() app.ensureAllMapped(secIdx, ...
                'Stäbe', ... % srcTableLabel
                'Querschnitt', ... % srcColLabel
                'Querschnitte')); % targetTableLabel
        end
        if ~isempty(in.Lager)
            issues = mergeIssues(app, issues, validateSupport(in));
        end
        if ~isempty(in.Feder)
            issues = mergeIssues(app, issues, validateSpring(in));
        end
    case "Actions"
        if ~isempty(in.KnotenLasten)
            issues = mergeIssues(app, issues, validateNodalLoad(in));
        end
        if ~isempty(in.StabLasten_konzentriert)
            issues = mergeIssues(app, issues, validatePointLoad(in));
        end
        if ~isempty(in.StabLasten_verteilt)
            issues = mergeIssues(app, issues, validateDistrLoad(in));
        end
        if ~isempty(in.VorgeschriebeneVerschiebung)
            issues = mergeIssues(app, issues, validateForcedDispl(in));
        end
    case "Result"
        %Maybe call when calculate button is pressed.
        if ~isempty(in.Einflusslinie)
            issues = mergeIssues(app, issues, validateInfluenceLine(in));
        end
        if ~isempty(in.Kondensation)
            issues = mergeIssues(app, issues, validateStatCond(in));
        end
    otherwise
        % Unknown / no checks
end
end
