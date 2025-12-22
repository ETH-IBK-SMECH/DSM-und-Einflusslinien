function keepMask_ff = dofsZuKondensieren(modell, DOF, kond, knotenZuKondensieren, komponentenMaske)
% Erzeugt eine logische BEHALTE-Maske über den FREIEN DOF (Grösse = nZiel = size(K_ff,1)).
% true  -> behalten (extern)
% false -> kondensieren (intern)

nkd = modell.Info.nKnotenDOF;

% Anzahl freier physikalischer DOF (= max DOF-Nummer)
freeDOF_global = kond.DOF(:);      % == find(kond.f)
nFree = numel(freeDOF_global);
keepMask_ff = true(nFree, 1);            % initial: alle behalten

% nichts angegeben -> nichts zu tun
if isempty(knotenZuKondensieren) || isempty(komponentenMaske)
    return;
end

% Falls alles false ist: ebenfalls nichts tun
if all(~komponentenMaske(:))
    return;
end

% Für jede Tabellenzeile: Knotennummer + zugehörige DOF-Maske
for row = 1:numel(knotenZuKondensieren)
    k  = knotenZuKondensieren(row);
    km = logical(komponentenMaske(row, :));   % 1×nkd für diesen Knoten

    if k < 1 || k > modell.Info.nKnoten
        % ungültiger Knoten -> einfach überspringen (Validator sollte das melden)
        continue;
    end

    if ~any(km)
        % für diesen Knoten nichts zu kondensieren
        continue;
    end
    % lokale "lineare" Indizes der DOF dieses Knotens
    loc = (k - 1) * nkd + (1:nkd);

    for d = find(km)    % welche Komponenten (x,y,phi,...) sollen kondensiert werden?
        g = DOF(loc(d));    % globale DOF-Nummer (1..nDOF) oder 0 (falls fest)
        if g > 0
            % Position dieses globalen DOF in der freien DOF-Liste finden
            j = find(freeDOF_global == g, 1);
            if ~isempty(j)
                keepMask_ff(j) = false;  % -> interner DOF, wird kondensiert
            end
        end
    end
end
end
