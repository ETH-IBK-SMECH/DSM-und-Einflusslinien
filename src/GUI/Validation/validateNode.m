function issues = validateNode(in)
issues.ok = true;
issues.messages = {};
T = in.Knoten;

if isempty(T)
    issues.ok = false;
    issues.messages{end+1} = 'Tabelle "Knoten": Es sind noch keine Knoten definiert.';
    return;
end

badX = isnan(T.xPos);
badY = isnan(T.yPos);

if any(badX)
    issues.ok = false;
    rows = find(badX);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Knoten": Spalte "xPos" darf nicht leer sein (Zeile(n): %s).', ...
        num2str(rows(:).'));
end

if any(badY)
    issues.ok = false;
    rows = find(badY);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Knoten": Spalte "yPos" darf nicht leer sein (Zeile(n): %s).', ...
        num2str(rows(:).'));
end
end
