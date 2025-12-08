function drawOriginalSprings(Knoten, Feder, meanL)
% Zeichnet Federn am entsprechendem Knoten

for i = 1:numel(Feder)
    type = Feder(i).dir; % 1=x, 2=y, 3=Rotation
    node = Feder(i).node;
    centre = [Knoten(node).xPos; Knoten(node).yPos];

    drawFeder(type, centre, 4*meanL);
end
end
