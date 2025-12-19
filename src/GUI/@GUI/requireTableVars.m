function requireTableVars(app, T, neededVars, tableLabel)
% T           : table to check
% neededVars  : cellstr or string array of required variable names
% tableLabel  : human-readable table name for the error message

if ~istable(T)
    error('DSM:GUI:NotATable', ...
        'Die Eingaben der Tabelle "%s" konnten nicht gelesen werden.', tableLabel);
end

have = string(T.Properties.VariableNames);

for k = 1:numel(neededVars)
    v = string(neededVars{k});
    if ~any(have == v)
        error('DSM:GUI:MissingColumn', ...
            'In der Tabelle "%s" fehlt die erforderliche Spalte "%s".', ...
            tableLabel, v);
    end
end
end
