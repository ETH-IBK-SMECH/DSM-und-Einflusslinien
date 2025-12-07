function issues = validateInfluenceLine(in)
issues.ok = true;
issues.messages = {};

% Only relevant if influence line is selected
if in.gew_output ~= 2
    return;
end

T = in.Einflusslinie;

if isempty(T)
    issues.ok = false;
    issues.messages{end+1} = ...
        'Tabelle "Einflusslinie": Es ist noch kein Eintrag gemacht.';
    return;
end

TypEL = T.TypEL(1); % same for all rows

switch TypEL
    case {1, 2, 3} % N, V, M
        % expect: Stab, Stelle in [0,1]
        if ~ismember('Stab', T.Properties.VariableNames)
            issues.ok = false;
            issues.messages{end+1} = ...
                'Tabelle "Einflusslinie": Für N/V/M fehlt die Spalte "Stab".';
            return;
        end
        if ~ismember('Stelle', T.Properties.VariableNames)
            issues.ok = false;
            issues.messages{end+1} = ...
                'Tabelle "Einflusslinie": Für N/V/M fehlt die Spalte "Stelle".';
            return;
        end

        nBeams = height(in.Staebe);
        badStab = isnan(T.Stab) | T.Stab < 1 | T.Stab > nBeams;
        if any(badStab)
            rows = find(badStab);
            issues.ok = false;
            issues.messages{end+1} = sprintf( ...
                'Tabelle "Einflusslinie": Zeile(n) %s: Stabindex verweist auf nicht existierenden Stab.', ...
                num2str(rows.'));
        end

        % Stelle roughly between 0 and 1
        badPos = isnan(T.Stelle) | T.Stelle < 0 | T.Stelle > 1;
        if any(badPos)
            rows = find(badPos);
            issues.ok = false;
            issues.messages{end+1} = sprintf( ...
                'Tabelle "Einflusslinie": Zeile(n) %s: Stelle muss zwischen 0 und 1 liegen.', ...
                num2str(rows.'));
        end

    case 4 % Lagerreaktion
        % expect: Knoten, Richtung
        if ~ismember('Knoten', T.Properties.VariableNames)
            issues.ok = false;
            issues.messages{end+1} = ...
                'Tabelle "Einflusslinie": Für Lagerreaktion fehlt die Spalte "Knoten".';
            return;
        end
        if ~ismember('Richtung', T.Properties.VariableNames)
            issues.ok = false;
            issues.messages{end+1} = ...
                'Tabelle "Einflusslinie": Für Lagerreaktion fehlt die Spalte "Richtung".';
            return;
        end

        nNodes = height(in.Knoten);
        badNode = isnan(T.Knoten) | T.Knoten < 1 | T.Knoten > nNodes;
        if any(badNode)
            rows = find(badNode);
            issues.ok = false;
            issues.messages{end+1} = sprintf( ...
                'Tabelle "Einflusslinie": Zeile(n) %s: Knotenindex verweist auf nicht existierenden Knoten.', ...
                num2str(rows.'));
        end

        badDir = isnan(T.Richtung) | T.Richtung < 1 | T.Richtung > 3 ...
            | T.Richtung ~= round(T.Richtung);
        if any(badDir)
            rows = find(badDir);
            issues.ok = false;
            issues.messages{end+1} = sprintf( ...
                'Tabelle "Einflusslinie": Zeile(n) %s: Richtung der Lagerreaktion muss ganzzahlig zwischen 1 und 3 liegen.', ...
                num2str(rows.'));
        end

    otherwise
        issues.ok = false;
        issues.messages{end+1} = ...
            'Tabelle "Einflusslinie": Unbekannter Typ der Einflusslinie.';
end
end
