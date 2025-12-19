function ensureAllMapped(app, idx, srcTableLabel, srcColLabel, targetTableLabel)
% idx             : index vector returned by ismember
% srcTableLabel   : name of the table where the user entered the value
% srcColLabel     : name of the column in that table
% targetTableLabel: name of the table that should contain the referenced entry

bad = find(idx == 0); % 0 => not found by ismember

if ~isempty(bad)
    % make a nice comma-separated list: "1 2 5"
    rowsText = strtrim(num2str(bad(:).'));

    error('DSM:GUI:MappingFailed', ...
        ['In der Tabelle "%s" ist in Zeile(n) %s in der Spalte "%s" ', ...
        'kein gültiger Eintrag gewählt, der in der Tabelle "%s" gefunden wurde.'], ...
        srcTableLabel, rowsText, srcColLabel, targetTableLabel);
end
end
