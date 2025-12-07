function issues = validateNodalLoad(in)
issues.ok = true;
issues.messages = {};

Tn = in.KnotenLasten;

if isempty(Tn)
    return;
end

% ---- we need nodes ----
nNodes = height(in.Knoten);
if nNodes == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Knotenlasten": Es sind Knotenlasten eingetragen, aber noch keine Knoten in Tabelle "Knoten".';
    return;
end

% ---- node indices valid ----
badNode = isnan(Tn.Knoten) | Tn.Knoten < 1 | Tn.Knoten > nNodes;
if any(badNode)
    rows = find(badNode);
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Knotenlasten": Zeile(n) %s: Knotenindex verweist auf nicht existierenden Knoten.', ...
        num2str(rows.'));
end

% ---- direction valid (1..3) ----
if ismember('Richtung', Tn.Properties.VariableNames)
    badDir = isnan(Tn.Richtung) | Tn.Richtung < 1 | Tn.Richtung > 3 ...
        | Tn.Richtung ~= round(Tn.Richtung);
    if any(badDir)
        rows = find(badDir);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Knotenlasten": Zeile(n) %s: Richtung muss ganzzahlig zwischen 1 und 3 liegen.', ...
            num2str(rows.'));
    end
end

% ---- value numeric ----
if ismember('Wert', Tn.Properties.VariableNames)
    badVal = isnan(Tn.Wert);
    if any(badVal)
        rows = find(badVal);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Knotenlasten": Zeile(n) %s: Wert ist leer oder kein gültiger Zahlenwert.', ...
            num2str(rows.'));
    end
end
end
