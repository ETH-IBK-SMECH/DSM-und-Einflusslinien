function issues = validateMaterial(in)
issues.ok = true;
issues.messages = {};
T = in.Material;

if isempty(T)
    issues.ok = false;
    issues.messages{end+1} = 'Tabelle "Material": Es ist noch kein Material definiert.';
    return;
end

% Name not empty
names = string(T.Name);
emptyName = ismissing(names) | strlength(strtrim(names)) == 0;

if any(emptyName)
    issues.ok = false;
    badRows = find(emptyName);
    issues.messages{end+1} = sprintf( ...
        ['Tabelle "Material": In Zeile(n) %s ist der Name leer.', ...
        ' Bitte einen gültigen Namen eingeben.'], ...
        strtrim(num2str(badRows.')));
end

% E-Modul > 0
badE = isnan(T.EModul) | T.EModul <= 0;
if any(badE)
    issues.ok = false;
    rows = find(badE);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Material": Spalte "EModul" muss > 0 sein (Fehler in Zeile(n): %s).', ...
        num2str(rows(:).'));
end
end
