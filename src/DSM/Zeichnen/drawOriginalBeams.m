function Staebe = drawOriginalBeams(ax, Knoten, Staebe, parent)
% Zeichnet die Stäbe (wie bisher) und füllt L, c, s, R in Staebe

nStaebe = numel(Staebe);
% Knoten- und Stab-Arrays wie bisher
KnotenKORD = table2array(struct2table(Knoten));
StaebeS = [Staebe.StartKnoten]';
StaebeE = [Staebe.EndKnoten]';
StaebeKORD = [StaebeS, StaebeE];

% genau wie vorher:
patch(ax, 'Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1, 'DisplayName','Stäbe', 'Parent', parent);

for i = 1:nStaebe
    sX = Knoten(Staebe(i).StartKnoten).xPos;
    eX = Knoten(Staebe(i).EndKnoten).xPos;
    sY = Knoten(Staebe(i).StartKnoten).yPos;
    eY = Knoten(Staebe(i).EndKnoten).yPos;

    Staebe(i).L = sqrt((eX - sX)^2+(eY - sY)^2); % Stablänge
    Staebe(i).c = (eX - sX) / Staebe(i).L; % cos
    Staebe(i).s = (eY - sY) / Staebe(i).L; % sin
    Staebe(i).R = getR(Staebe(i).c, Staebe(i).s); % Rotationsmatrix
end
end
