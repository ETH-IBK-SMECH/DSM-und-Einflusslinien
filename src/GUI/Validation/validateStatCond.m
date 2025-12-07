function issues = validateStatCond(in)
issues.ok = true;
issues.messages = {};

K = in.Kondensation;

if isempty(K)
    return;
end

nNodes = height(in.Knoten);

% check node indices
badNode = isnan(K.Knoten) | K.Knoten < 1 | K.Knoten > nNodes;
if any(badNode)
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Statische Kondensation": Knotenindex verweist auf nicht existierenden Knoten.');
end

% at least one DOF selected per row
mask = K.KomponentenMaske;
emptyRows = find(~any(mask, 2));
if ~isempty(emptyRows)
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Statische Kondensation": Zeile(n) %s: Es ist kein DOF zur Kondensation ausgewählt.', ...
        num2str(emptyRows.'));
end
end
