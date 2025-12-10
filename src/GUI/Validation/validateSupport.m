function issues = validateSupport(in)
issues.ok = true;
issues.messages = {};
T = in.Lager;

if isempty(T)
    % maybe OK (System ohne Lager -> später auf Analyse-Ebene abgefangen)
    return;
end

nNodes = height(in.Knoten);
if nNodes == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Lager": Es existieren Lager, aber es sind noch keine Knoten definiert.';
    return;
end

% node indices valid
badNode = isnan(T.Knoten) | T.Knoten < 1 | T.Knoten > nNodes;
if any(badNode)
    issues.ok = false;
    rows = find(badNode);
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Lager": Spalte "Knoten" verweist auf ungültige Knoten (Zeile(n): %s).', ...
        num2str(rows(:).'));
end

% support type valid (1..6)
if ismember('Lagerung', T.Properties.VariableNames)
    badType = isnan(T.Lagerung) | T.Lagerung < 1 | T.Lagerung > 6 ...
        | T.Lagerung ~= round(T.Lagerung);
    if any(badType)
        issues.ok = false;
        rows = find(badType);
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Lager": Spalte "Lagerung" enthält ungültige Lagertypen (Zeile(n): %s).', ...
            num2str(rows(:).'));
    end
end
end
