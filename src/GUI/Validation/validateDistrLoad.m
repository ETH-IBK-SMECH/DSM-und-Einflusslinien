function issues = validateDistrLoad(in)
issues.ok = true;
issues.messages = {};

Td = in.StabLasten_verteilt;

if isempty(Td)
    return;
end

% ---- we need beams ----
nBeams = height(in.Staebe);
if nBeams == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Verteilte Stablasten": Es sind verteilte Lasten eingetragen, aber noch keine Stäbe in Tabelle "Stäbe".';
    return;
end

% ---- beam indices valid ----
badStab = isnan(Td.Stab) | Td.Stab < 1 | Td.Stab > nBeams;
if any(badStab)
    rows = find(badStab);
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Verteilte Stablasten": Zeile(n) %s: Stabindex verweist auf nicht existierenden Stab.', ...
        num2str(rows.'));
end

% ---- direction valid (1..2) because GUI only allows x/y ----
if ismember('Richtung', Td.Properties.VariableNames)
    badDir = isnan(Td.Richtung) | Td.Richtung < 1 | Td.Richtung > 2 ...
        | Td.Richtung ~= round(Td.Richtung);
    if any(badDir)
        rows = find(badDir);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Verteilte Stablasten": Zeile(n) %s: Richtung muss x-Richtung oder y-Richtung sein.', ...
            num2str(rows.'));
    end
end

% ---- value numeric ----
if ismember('Wert', Td.Properties.VariableNames)
    badVal = isnan(Td.Wert);
    if any(badVal)
        rows = find(badVal);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Verteilte Stablasten": Zeile(n) %s: Wert ist leer oder kein gültiger Zahlenwert.', ...
            num2str(rows.'));
    end
end

% ---- start & end positions numeric, ≥ 0, and End ≥ Start ----
haveStart = ismember('StartPosition', Td.Properties.VariableNames);
haveEnd = ismember('EndPosition', Td.Properties.VariableNames);

if haveStart
    badStart = isnan(Td.StartPosition) | Td.StartPosition < 0;
    if any(badStart)
        rows = find(badStart);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Verteilte Stablasten": Zeile(n) %s: Startposition muss ≥ 0 und numerisch sein.', ...
            num2str(rows.'));
    end
end

if haveEnd
    badEnd = isnan(Td.EndPosition) | Td.EndPosition < 0;
    if any(badEnd)
        rows = find(badEnd);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Verteilte Stablasten": Zeile(n) %s: Endposition muss ≥ 0 und numerisch sein.', ...
            num2str(rows.'));
    end
end

if haveStart && haveEnd
    badOrder = Td.EndPosition < Td.StartPosition;
    if any(badOrder)
        rows = find(badOrder);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Verteilte Stablasten": Zeile(n) %s: Endposition liegt vor der Startposition.', ...
            num2str(rows.'));
    end
end
end
