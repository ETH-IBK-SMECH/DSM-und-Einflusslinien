function issues = validateForcedDispl(in)
issues.ok = true;
issues.messages = {};
T = in.VorgeschriebeneVerschiebung;

if isempty(T)
    return;
end

% ---- we need nodes ----
nNodes = height(in.Knoten);
if nNodes == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Zwängungen": Es sind Zwängungen eingetragen, aber noch keine Knoten in Tabelle "Knoten".';
    return;
end

% ---- node indices valid ----
badNode = isnan(T.Knoten) | T.Knoten < 1 | T.Knoten > nNodes;
if any(badNode)
    rows = find(badNode);
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Zwängungen": Zeile(n) %s: Knotenindex verweist auf nicht existierenden Knoten.', ...
        num2str(rows.'));
end

% ---- direction valid (1..3) ----
if ismember('Richtung', T.Properties.VariableNames)
    badDir = isnan(T.Richtung) | T.Richtung < 1 | T.Richtung > 3 ...
        | T.Richtung ~= round(T.Richtung);
    if any(badDir)
        rows = find(badDir);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Zwängungen": Zeile(n) %s: Richtung muss ganzzahlig zwischen 1 und 3 liegen.', ...
            num2str(rows.'));
    end
end

% ---- value numeric ----
if ismember('Wert', T.Properties.VariableNames)
    badVal = isnan(T.Wert);
    if any(badVal)
        rows = find(badVal);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Zwängungen": Zeile(n) %s: Wert ist leer oder kein gültiger Zahlenwert.', ...
            num2str(rows.'));
    end
end
end
