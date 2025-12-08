function drawOriginalSupports(Knoten, Staebe, Lager, meanL, nStaebe)
% Zeichnet Lager gemäss Lager-Typ

for i = 1:size(Lager, 1)
    type = Lager.Lagerung(i);
    node = Lager.Knoten(i);
    centre = [Knoten(node).xPos; Knoten(node).yPos];

    switch type
        case 1
            stabnodes = [Staebe.StartKnoten; Staebe.EndKnoten]';
            stabnodeidx = find(stabnodes == node);
            if stabnodeidx / nStaebe <= 1
                R = Staebe(stabnodeidx).R(1:2, 1:2);
            else
                stabnodeidx = stabnodeidx - nStaebe;
                R = [-1, 0; 0, -1] * Staebe(stabnodeidx).R(1:2, 1:2);
            end
            drawLager(type, centre, R, 0.6*meanL);

        case {2, 3, 4}
            R = eye(2);
            drawLager(type, centre, R, 0.5*meanL);

        case {5, 6}
            stabnodes = [Staebe.StartKnoten; Staebe.EndKnoten]';
            stabnodeidx = find(stabnodes == node);
            if stabnodeidx / nStaebe <= 1
                R = eye(2);
            else
                R = [-1, 0; 0, -1];
            end
            drawLager(type, centre, R, 0.6*meanL);
    end
end
end
