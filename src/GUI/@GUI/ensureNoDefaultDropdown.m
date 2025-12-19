function ensureNoDefaultDropdown(app, colData, tableLabel, colLabel)
% colData    : table column (cellstr, string, char, etc.)
% tableLabel : human-readable name of the table
% colLabel   : human-readable name of the column
%
% Checks that no entry is still the default "– wählen –" (or empty).

s = string(colData);

% mark all rows where still "– wählen –" or empty
bad = find(s == "– wählen –" | strlength(s) == 0);

if ~isempty(bad)
    rowsText = strtrim(num2str(bad(:).')); % "1 2 5"

    error('DSM:GUI:DropdownNotSelected', ...
        ['In der Tabelle "%s" ist in Zeile(n) %s in der Spalte "%s" ', ...
        'noch kein gültiger Eintrag gewählt ("– wählen –").'], ...
        tableLabel, rowsText, colLabel);
end
end