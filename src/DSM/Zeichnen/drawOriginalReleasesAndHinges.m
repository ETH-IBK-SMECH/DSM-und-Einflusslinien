function drawOriginalReleasesAndHinges(ax, Knoten, Staebe, Stab, meanL, nKnoten, nStaebe, parent)
% Zeichnet:
% - dicke Linien für EIinf-Stäbe
% - Momentengelenke (inkl. "globales" M-Gelenk am Knoten oder leicht versetzt)

momentengelenk = true(1, nKnoten);
% Querschnitt / EIinf + Releases aus Analysemodell übernehmen
for i = 1:nStaebe
    startK = Staebe(i).StartKnoten;
    endK = Staebe(i).EndKnoten;

    % dickere Linie für biegesteife Stäbe (EIinf Flag)
    if isfield(Stab(i), 'EIinf') && Stab(i).EIinf
        x = [Knoten(startK).xPos, Knoten(endK).xPos, NaN];
        y = [Knoten(startK).yPos, Knoten(endK).yPos, NaN];
        patch(ax, x, y, 'k', 'LineWidth', 2.1, 'LineJoin', 'round', 'Parent', parent);
    end

    % Releases direkt aus Analysemodell übernehmen
    Staebe(i).sRelease = Stab(i).sRelease;
    Staebe(i).eRelease = Stab(i).eRelease;

    if ~isempty(Staebe(i).sRelease) && Staebe(i).sRelease ~= 3
        momentengelenk(Staebe(i).StartKnoten) = false;
    end
    if ~isempty(Staebe(i).eRelease) && Staebe(i).eRelease ~= 3
        momentengelenk(Staebe(i).EndKnoten) = false;
    end
end

% Gelenke zeichnen
for i = 1:nStaebe

    if (~isempty(Staebe(i).sRelease) && Staebe(i).sRelease(1) == 3) && logical(momentengelenk(Staebe(i).StartKnoten))
        centre = [Knoten(Staebe(i).StartKnoten).xPos; ...
            Knoten(Staebe(i).StartKnoten).yPos];
        drawGelenk(ax, 3, centre, meanL, parent);
    elseif ~isempty(Staebe(i).sRelease) && Staebe(i).sRelease(1) == 3
        centre = [0.025 * meanL; 0];
        centre = Staebe(i).R(1:2, 1:2)' * centre;
        centre = [Knoten(Staebe(i).StartKnoten).xPos; ...
            Knoten(Staebe(i).StartKnoten).yPos] + centre;
        drawGelenk(ax, 3, centre, meanL, parent);
    end

    if (~isempty(Staebe(i).eRelease) && Staebe(i).eRelease(1) == 3) && logical(momentengelenk(Staebe(i).EndKnoten))
        centre = [Knoten(Staebe(i).EndKnoten).xPos; ...
            Knoten(Staebe(i).EndKnoten).yPos];
        drawGelenk(ax, 3, centre, meanL, parent);
    elseif ~isempty(Staebe(i).eRelease) && Staebe(i).eRelease(1) == 3
        centre = [-0.025 * meanL; 0];
        centre = Staebe(i).R(1:2, 1:2)' * centre;
        centre = [Knoten(Staebe(i).EndKnoten).xPos; ...
            Knoten(Staebe(i).EndKnoten).yPos] + centre;
        drawGelenk(ax, 3, centre, meanL, parent);
    end
end
end
