function importGUIState(app, S)
% Restore tables if present
if isfield(S, "Tables")
    tableNames = fieldnames(app.Tables);
    for i = 1:numel(tableNames)
        key = tableNames{i};
        if isfield(S.Tables, key)
            app.Tables.(key).Data = S.Tables.(key);
        end
    end
end

% Restore dropdowns if present
if isfield(S, "DropDown_GewnschterOutput")
    app.DropDown_GewnschterOutput.Value = S.DropDown_GewnschterOutput;
end
if isfield(S, "Dropdown_TypEL")
    app.Dropdown_TypEL.Value = S.Dropdown_TypEL;
end

% Rebuild dependent dropdown lists
MaterialTableChanged(app);
SectionTableChanged(app);
NodeTableChanged(app);
BeamTableChanged(app);

% Show / hide EL-subpanel depending on restored selection
DropDown_GewnschterOutputValueChanged(app, []);
Dropdown_TypELValueChanged(app, []);
end
