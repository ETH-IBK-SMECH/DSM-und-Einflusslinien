function Staebe = drawOriginalBeams(ax, Knoten, Staebe, parentStab, parentStabNummer)
% Zeichnet die Stäbe (wie bisher) und füllt L, c, s, R in Staebe

nStaebe = numel(Staebe);
% Knoten- und Stab-Arrays wie bisher
KnotenKORD = table2array(struct2table(Knoten));
StaebeS = [Staebe.StartKnoten]';
StaebeE = [Staebe.EndKnoten]';
StaebeKORD = [StaebeS, StaebeE];

patch(ax, 'Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1, 'DisplayName','Stäbe', 'Parent', parentStab);

for i = 1:nStaebe
    sX = Knoten(Staebe(i).StartKnoten).xPos;
    eX = Knoten(Staebe(i).EndKnoten).xPos;
    sY = Knoten(Staebe(i).StartKnoten).yPos;
    eY = Knoten(Staebe(i).EndKnoten).yPos;

    dx = eX - sX; dy = eY - sY;
    L  = hypot(dx, dy);

    Staebe(i).L = L;
    Staebe(i).c = dx / L;
    Staebe(i).s = dy / L;
    Staebe(i).R = getR(Staebe(i).c, Staebe(i).s);

    % Richtungsanzeige entlang der Stäbe
    px = sX + 0.5 * dx;
    py = sY + 0.5 * dy;

    tx = dx / L;  ty = dy / L;

    text(px, py, char(9654), ...
        'Parent', parentStabNummer, ...
        'Rotation', atan2d(ty, tx), ...
        'FontSize', 19, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'Color',[1.0, 0.5, 0.0]);

    text(ax, px, py, num2str(i), ...
        'Parent', parentStabNummer, ...
        'FontSize', 11, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Clipping', 'on', ...
        'HitTest', 'off');
end
end
