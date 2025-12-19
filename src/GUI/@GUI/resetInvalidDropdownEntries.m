function resetInvalidDropdownEntries(app, tableObj, colIndex, validItems)
% tableObj  : handle to the uitable
% colIndex  : column number to sanitize
% validItems: cellstr or string array of allowed values (from ColumnFormat)

T = tableObj.Data;

if isempty(T)
    return; % nothing to fix
end

if istable(T)
    colStr = string(T{:, colIndex});
    invalid = ~ismember(colStr, string(validItems));
    colStr(invalid) = "– wählen –";
    T{:, colIndex} = cellstr(colStr);
else
    colStr = string(T(:, colIndex));
    invalid = ~ismember(colStr, string(validItems));
    colStr(invalid) = "– wählen –";
    T(:, colIndex) = cellstr(colStr);
end
tableObj.Data = T;
end
