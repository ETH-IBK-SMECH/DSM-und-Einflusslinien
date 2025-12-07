function issues = validateBeam(in)
issues.ok = true;
issues.messages = {};
T = in.Staebe;

if isempty(T)
    issues.ok = false;
    issues.messages{end+1} = 'Tabelle "Stäbe": Es ist noch kein Stab definiert.';
    return;
end

nNodes = height(in.Knoten);
nSecs = height(in.Querschnitte);

% Node indices valid
badStart = isnan(T.StartKnoten) | T.StartKnoten < 1 | T.StartKnoten > nNodes;
badEnd = isnan(T.EndKnoten) | T.EndKnoten < 1 | T.EndKnoten > nNodes;

if any(badStart)
    issues.ok = false;
    rows = find(badStart);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Stäbe": Spalte "StartKnoten" verweist auf ungültige Knoten (Zeile(n): %s).', ...
        num2str(rows(:).'));
end
if any(badEnd)
    issues.ok = false;
    rows = find(badEnd);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Stäbe": Spalte "EndKnoten" verweist auf ungültige Knoten (Zeile(n): %s).', ...
        num2str(rows(:).'));
end

% Start != End
sameNode = T.StartKnoten == T.EndKnoten;
if any(sameNode)
    issues.ok = false;
    rows = find(sameNode);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Stäbe": Start- und Endknoten sind identisch in Zeile(n): %s.', ...
        num2str(rows(:).'));
end

end
