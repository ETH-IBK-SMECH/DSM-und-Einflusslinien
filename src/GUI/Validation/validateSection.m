function issues = validateSection(in)
issues.ok = true;
issues.messages = {};
T = in.Querschnitte;

if isempty(T)
    issues.ok = false;
    issues.messages{end+1} = 'Tabelle "Querschnitte": Es ist noch kein Querschnitt definiert.';
    return;
end

nMat = height(in.Material);

% Section name not empty
names = string(T.Name);
emptyName = ismissing(names) | strlength(strtrim(names)) == 0;

if any(emptyName)
    issues.ok = false;
    badRows = find(emptyName);
    issues.messages{end+1} = sprintf( ...
        ['Tabelle "Querschnitte": In Zeile(n) %s ist der Name leer.', ...
        ' Bitte einen gültigen Namen eingeben.'], ...
        strtrim(num2str(badRows.')));
end

% Area > 0
badA = isnan(T.Flaeche) | T.Flaeche <= 0;
if any(badA)
    issues.ok = false;
    rows = find(badA);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Querschnitte": Spalte "Flaeche" muss > 0 sein (Zeile(n): %s).', ...
        num2str(rows(:).'));
end

% Moment of inertia > 0
badIy = isnan(T.Traegheitsmoment) | T.Traegheitsmoment <= 0;
if any(badIy)
    issues.ok = false;
    rows = find(badIy);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Querschnitte": Spalte "Traegheitsmoment" muss > 0 sein (Zeile(n): %s).', ...
        num2str(rows(:).'));
end
end
