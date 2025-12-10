function issues = validatePointLoad(in)
issues.ok = true;
issues.messages = {};

Tp = in.StabLasten_konzentriert;

if isempty(Tp)
    return;
end

% ---- we need beams ----
nBeams = height(in.Staebe);
if nBeams == 0
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Stab-Einzellasten": Es sind Einzellasten eingetragen, aber noch keine Stäbe in Tabelle "Stäbe".';
    return;
end

% ---- beam indices valid ----
badStab = isnan(Tp.Stab) | Tp.Stab < 1 | Tp.Stab > nBeams;
if any(badStab)
    rows = find(badStab);
    issues.ok = false;
    issues.messages{end+1} = sprintf( ...
        'Tabelle "Stab-Einzellasten": Zeile(n) %s: Stabindex verweist auf nicht existierenden Stab.', ...
        num2str(rows.'));
end

% ---- direction valid (1..3) ----
if ismember('Richtung', Tp.Properties.VariableNames)
    badDir = isnan(Tp.Richtung) | Tp.Richtung < 1 | Tp.Richtung > 3 ...
        | Tp.Richtung ~= round(Tp.Richtung);
    if any(badDir)
        rows = find(badDir);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Stab-Einzellasten": Zeile(n) %s: Richtung muss x-Richtung, y-Richtung oder Rotation sein..', ...
            num2str(rows.'));
    end
end

% ---- value numeric ----
if ismember('Wert', Tp.Properties.VariableNames)
    badVal = isnan(Tp.Wert);
    if any(badVal)
        rows = find(badVal);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Stab-Einzellasten": Zeile(n) %s: Wert ist leer oder kein gültiger Zahlenwert.', ...
            num2str(rows.'));
    end
end

% ---- start position numeric & ≥ 0 ----
if ismember('StartPosition', Tp.Properties.VariableNames)
    badPos = isnan(Tp.StartPosition) | Tp.StartPosition < 0;
    if any(badPos)
        rows = find(badPos);
        issues.ok = false;
        issues.messages{end+1} = sprintf( ...
            'Tabelle "Stab-Einzellasten": Zeile(n) %s: Startposition muss ≥ 0 und numerisch sein.', ...
            num2str(rows.'));
    end
end
end
