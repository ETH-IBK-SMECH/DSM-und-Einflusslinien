function [in, issues] = guiToInput(app, finInput)
issues.ok = true;
issues.messages = {};

% Material
in.Material = app.uiDataToTable(app.Table_Material);
if finInput
    issues = collect(app, issues, @() app.requireTableVars(in.Material, {'Name', 'EModul'}, 'Material'));
end
% Cross-sections
in.Querschnitte = app.uiDataToTable(app.Table_Section);
%only require these tables when caluclate button is pushed
if finInput
    issues = collect(app, issues, @() app.requireTableVars(in.Querschnitte, ...
        {'Name', 'Material', 'Flaeche', 'Traegheitsmoment'}, ...
        'Querschnitte'));
    if ~isempty(in.Querschnitte)
        matNames = string(in.Material.Name);
        secMatNames = string(in.Querschnitte.Material);

        [~, matIdx] = ismember(secMatNames, matNames);

        % check for unmapped entries (empty / wrong / "– wählen –")
        issues = collect(app, issues, @() app.ensureAllMapped(matIdx, ...
            'Querschnitte', ... % srcTableLabel
            'Material', ... % srcColLabel
            'Material')); % targetTableLabel

        % This is what inputUmwandeln expects:
        in.Querschnitte.Material = matIdx;
    end
end
% map material names in sections to numeric indices

% Nodes
in.Knoten = app.uiDataToTable(app.Table_Node);
if finInput
    issues = collect(app, issues, @() app.requireTableVars(in.Knoten, {'xPos', 'yPos'}, 'Knoten'));
end

% Beams
T_Beam = app.uiDataToTable(app.Table_Beam);
if ~isempty(T_Beam)
    T_Beam.GelenkStabAnfang = mapDropdown(app, T_Beam.GelenkStabAnfang, app.Dropdown_HingeTypes, -1);
    T_Beam.GelenkStabende = mapDropdown(app, T_Beam.GelenkStabende, app.Dropdown_HingeTypes, -1);
end
in.Staebe = T_Beam;
if finInput && ~isempty(T_Beam)
    issues = collect(app, issues, @() app.requireTableVars(T_Beam, ...
        {'StartKnoten', 'EndKnoten', 'Querschnitt', 'GelenkStabAnfang', 'GelenkStabende'}, ...
        'Stäbe'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_Beam.GelenkStabAnfang, 'Stäbe', 'GelenkStabanfang'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_Beam.GelenkStabende, 'Stäbe', 'GelenkStabende'));

    % map section names in beam to numeric indices
    secNames = string(in.Querschnitte.Name);
    beamSecNames = string(in.Staebe.Querschnitt);

    [~, secIdx] = ismember(beamSecNames, secNames);

    % check for unmapped entries (empty / wrong / "– wählen –")
    issues = collect(app, issues, @() app.ensureAllMapped(secIdx, ...
        'Stäbe', ... % srcTableLabel
        'Querschnitt', ... % srcColLabel
        'Querschnitte')); % targetTableLabel

    % This is what inputUmwandeln expects:
    in.Staebe.Querschnitt = secIdx;
end

% Supports
T_Support = app.uiDataToTable(app.Table_Support);
if finInput && ~isempty(T_Support)
    issues = collect(app, issues, @() app.requireTableVars(T_Support, {'Knoten', 'Lagerung'}, 'Lager'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_Support.Lagerung, 'Lager', 'Lagerung'));
end
if ~isempty(T_Support)
    T_Support.Lagerung = mapDropdown(app, T_Support.Lagerung, app.Dropdown_SupportTypes);
end
in.Lager = T_Support;

% Springs
T_Spring = app.uiDataToTable(app.Table_Spring);
if finInput && ~isempty(T_Spring)
    issues = collect(app, issues, @() app.requireTableVars(T_Spring, {'Knoten', 'Feder', 'Betrag'}, 'Federn'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_Spring.Feder, 'Federn', 'Feder'));
end
if ~isempty(T_Spring)
    T_Spring.Feder = mapDropdown(app, T_Spring.Feder, app.Dropdown_SpringTypes);
end
in.Feder = T_Spring;

% Loads
T_NodalLoad = app.uiDataToTable(app.Table_NodalLoad);
if finInput && ~isempty(T_NodalLoad)
    issues = collect(app, issues, @() app.requireTableVars(T_NodalLoad, {'Knoten', 'Richtung', 'Wert'}, 'Knotenlasten'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_NodalLoad.Richtung, 'Knotenlasten', 'Richtung'));
end
if ~isempty(T_NodalLoad)
    T_NodalLoad.Richtung = mapDropdown(app, T_NodalLoad.Richtung, app.Dropdown_Directions);
end
in.KnotenLasten = T_NodalLoad;
T_PointLoad = app.uiDataToTable(app.Table_PointLoad);
if finInput && ~isempty(T_PointLoad)
    issues = collect(app, issues, @() app.requireTableVars(T_PointLoad, {'Stab', 'Richtung', 'Wert', 'StartPosition'}, 'Stablasten'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_PointLoad.Richtung, 'Stab-Einzellasten', 'Richtung'));
end
if ~isempty(T_PointLoad)
    T_PointLoad.Richtung = mapDropdown(app, T_PointLoad.Richtung, app.Dropdown_Directions);
end
in.StabLasten_konzentriert = T_PointLoad;
T_DistrLoad = app.uiDataToTable(app.Table_DistrLoad);
if finInput && ~isempty(T_DistrLoad)
    issues = collect(app, issues, @() app.requireTableVars(T_DistrLoad, {'Stab', 'Richtung', 'Wert', 'StartPosition', 'EndPosition'}, 'Verteilte Lasten'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_DistrLoad.Richtung, 'Verteilte Lasten', 'Richtung'));
end
if ~isempty(T_DistrLoad)
    T_DistrLoad.Richtung = mapDropdown(app, T_DistrLoad.Richtung, app.Dropdown_Directions);
end
in.StabLasten_verteilt = T_DistrLoad;

% Prescribed displacements
T_ForcedDispl = app.uiDataToTable(app.Table_ForcedDispl);
if finInput && ~isempty(T_ForcedDispl)
    issues = collect(app, issues, @() app.requireTableVars(T_ForcedDispl, {'Knoten', 'Richtung', 'Wert'}, 'Zwängungen'));
    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_ForcedDispl.Richtung, 'Zwängungen', 'Richtung'));
end
if ~isempty(T_ForcedDispl)
    T_ForcedDispl.Richtung = mapDropdown(app, T_ForcedDispl.Richtung, app.Dropdown_Directions);
end
in.VorgeschriebeneVerschiebung = T_ForcedDispl;

% Static Condensation
in.Kondensation = [];
T_StatCond = app.uiDataToTable(app.Table_StatCond);
%No static condensation for influence lines and only if box is
%checked
if finInput && ~isempty(T_StatCond) && app.DropDown_GewnschterOutput.Value ~= "Einflusslinie" && app.JaNeinCheckBox.Value
    issues = collect(app, issues, @() app.requireTableVars(T_StatCond, {'Knoten', 'xDOF', 'yDOF', 'RotationsDOF'}, 'Statische Kondensation'));

    issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_StatCond.Knoten, 'Statische Kondensation', 'Knoten'));
    Knoten = T_StatCond.Knoten(:);
    mask = logical([T_StatCond.xDOF, T_StatCond.yDOF, T_StatCond.RotationsDOF]); % N x 3 logical

    in.Kondensation = struct( ...
        'Knoten', Knoten, ...
        'KomponentenMaske', mask ...
        );
end

% OUTPUT SELECTION
OutputVal = string(app.DropDown_GewnschterOutput.Value);
switch OutputVal
    case "Schnittkräfte", in.gew_output = 1;
    case "Einflusslinie", in.gew_output = 2;
    case "Auflagerreaktionen", in.gew_output = 3;
    otherwise in.gew_output = 1; % default
end

% Influence line options
InfluenceLineVal = string(app.Dropdown_TypEL.Value);
switch InfluenceLineVal
    case "Normalkraft", TypEL = 1;
    case "Querkraft", TypEL = 2;
    case "Biegemoment", TypEL = 3;
    case "Lagerreaktion", TypEL = 4;
    otherwise TypEL = 1; % default
end

if TypEL == 4
    T_InfluenceLine = app.uiDataToTable(app.Table_InfluenceLine_2);
    if finInput && ~isempty(T_InfluenceLine)
        issues = collect(app, issues, @() app.ensureNoDefaultDropdown(T_InfluenceLine.Richtung, 'Einflusslinie (Lagerreaktion)', 'Richtung'));
    end
    if ~isempty(T_InfluenceLine)
        T_InfluenceLine.Richtung = mapDropdown(app, T_InfluenceLine.Richtung, app.Dropdown_Directions);
    end
else
    T_InfluenceLine = app.uiDataToTable(app.Table_InfluenceLine_1);
end
T_InfluenceLine.TypEL = TypEL;
in.Einflusslinie = T_InfluenceLine;

end
