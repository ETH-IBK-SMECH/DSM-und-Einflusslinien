function drawOriginalConcentratedMemberLoads(Knoten, Staebe, StabLast_konz, meanL, meanSLk)
% Zeichnet konzentrierte Stablasten (rot, inkl. Momente)

for i = 1:numel(StabLast_konz)
    StabIdx = StabLast_konz(i).Stab;
    dir = StabLast_konz(i).Richtung;
    phys = StabLast_konz(i).Wert;

    if dir == 3
        phys = phys / 1000; % kNmm -> kNm
    end

    val = phys / meanSLk;
    sDist = StabLast_konz(i).StartPosition;
    LArr = val * 0.25 * meanL;

    R = Staebe(StabIdx).R(1:2, 1:2);
    SKKord = [Knoten(Staebe(StabIdx).StartKnoten).xPos; ...
        Knoten(Staebe(StabIdx).StartKnoten).yPos];
    L = Staebe(StabIdx).L;

    p1 = [sDist * L; 0];

    switch dir
        case 1
            p0 = [sDist * L - LArr; 0];
        case 2
            p0 = [sDist * L; -LArr];
    end

    p1 = SKKord + R' * p1;

    switch dir
        case {1, 2}
            p0 = SKKord + R' * p0;

            drawArrow2(p0, p1, 'r', meanL);
            basePoint = (p0 + p1) / 2;
            ptext = getTextPos(basePoint, dir, val, meanL);
            text(ptext(1), ptext(2), num2str(StabLast_konz(i).Wert));

        case 3
            radius = abs(val) * meanL * 0.125;
            drawCircularArrow(radius, p1, sign(val), 'r');

            basePoint = p1;
            ptext = getTextPos(basePoint, 3, val, meanL);
            text(ptext(1), ptext(2), num2str(StabLast_konz(i).Wert));
    end
end
end
