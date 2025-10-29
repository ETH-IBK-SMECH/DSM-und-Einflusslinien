function keepMask_ff = dofsZuKondensieren(modell, DOF, knotenZuKondensieren, komponentenMaske, nZiel)
% Erzeugt eine logische BEHALTE-Maske über den FREIEN DOF (Grösse = nZiel = size(K_ff,1)).
% true  -> behalten (extern)
% false -> kondensieren (intern)
%
% Idee:
%   1) physikalische freie DOF (freeList) aus DOF(:)>0 bestimmen
%   2) für die gewünschten Knoten/Komponenten die zugehörigen freien Indizes
%      in freeList finden und auf "false" setzen
%   3) Maske auf Länge nZiel bringen (neue/zusätzliche Zeilen, z.B. LM, werden behalten)

    nkd   = modell.Info.nKnotenDOF;
    freeList    = find(DOF(:) > 0);            % globale IDs der freien phys. DOF
    keepMask_ff = true(numel(freeList), 1);    % zunächst alles behalten

    if ~isempty(knotenZuKondensieren)
        km = logical(komponentenMaske(:).');   % 1×nkd
        for k = knotenZuKondensieren(:).'
            loc = (k-1)*nkd + (1:nkd);         % lokale DOF des Knotens
            for d = find(km)                   % betroffene Komponenten
                g = DOF(loc(d));               % globale DOF-ID (0 falls fest)
                if g > 0
                    idx = find(freeList == g, 1); % Position im freien System
                    if ~isempty(idx)
                        keepMask_ff(idx) = false; % intern → kondensieren
                    end
                end
            end
        end
    end

    % Maske an die Zielgrösse des aktuellen freien Systems anpassen:
    % - zusätzliche Zeilen (z.B. LM) als "behalten" markieren
    % - zu lange Masken abschneiden
    if nZiel > numel(keepMask_ff)
        keepMask_ff(end+1:nZiel, 1) = true;
    elseif nZiel < numel(keepMask_ff)
        keepMask_ff = keepMask_ff(1:nZiel);
    end
end
