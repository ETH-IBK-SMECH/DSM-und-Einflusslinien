function S = exportGUIState(app)
% Save all table contents
S.Tables = struct();
tableNames = fieldnames(app.Tables);
for i = 1:numel(tableNames)
    key = tableNames{i};
    S.Tables.(key) = app.Tables.(key).Data;
end

% Save dropdowns / options
S.DropDown_GewnschterOutput = app.DropDown_GewnschterOutput.Value;
S.Dropdown_TypEL = app.Dropdown_TypEL.Value;
end
