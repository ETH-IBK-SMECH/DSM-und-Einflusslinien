function issues = validateSpring(in)
issues.ok = true;
issues.messages = {};
T = in.Feder;

if isempty(T)
    return;
end

% ---- basic consistency: we need nodes ----
nNodes = height(in.Knoten);
if nNodes == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Federn": Es sind Federn eingetragen, aber noch keine Knoten in Tabelle "Knoten".';
    return;
end

% ---- node indices valid ----
badNode = isnan(T.Knoten) | T.Knoten < 1 | T.Knoten > nNodes;
if any(badNode)
    rows = find(badNode);
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Federn": Zeile(n) %s: Knotenindex verweist auf nicht existierenden Knoten.', ...
        num2str(rows.'));
end

% ---- spring type valid (1..3) ----
if ismember('Feder', T.Properties.VariableNames)
    badType = isnan(T.Feder) | T.Feder < 1 | T.Feder > 3 ...
        | T.Feder ~= round(T.Feder);
    if any(badType)
        rows = find(badType);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Federn": Zeile(n) %s: Ungültiger Federtyp (erlaubt: 1–3).', ...
            num2str(rows.'));
    end
end

% ---- stiffness >= 0 & numeric ----
if ismember('Betrag', T.Properties.VariableNames)
    badK = isnan(T.Betrag) | T.Betrag < 0;
    if any(badK)
        rows = find(badK);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Federn": Zeile(n) %s: Federwert "Betrag" muss ≥ 0 und numerisch sein.', ...
            num2str(rows.'));
    end
end
end
