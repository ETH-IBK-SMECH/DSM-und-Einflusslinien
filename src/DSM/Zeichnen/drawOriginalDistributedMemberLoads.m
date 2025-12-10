function drawOriginalDistributedMemberLoads(ax, Knoten, Staebe, StabLast_vert, meanL, meanSLv)
% Zeichnet verteilte Stablasten (blau)

for i = 1:numel(StabLast_vert)
    StabIdx = StabLast_vert(i).Stab;
    dir = StabLast_vert(i).Richtung;
    phys = StabLast_vert(i).Wert;

    val = phys / meanSLv;
    sDist = StabLast_vert(i).StartPosition;
    eDist = StabLast_vert(i).EndPosition;
    LArr = val * 0.125 * meanL;

    R = Staebe(StabIdx).R(1:2, 1:2);
    SKKord = [Knoten(Staebe(StabIdx).StartKnoten).xPos; ...
        Knoten(Staebe(StabIdx).StartKnoten).yPos];
    L = Staebe(StabIdx).L;

    for j = linspace(sDist*L, eDist*L, 6)
        p1 = [j; 0];
        switch dir
            case 1
                p0 = [j - LArr; 0];
            case 2
                p0 = [j; -LArr];
        end

        p1 = SKKord + R' * p1;
        p0 = SKKord + R' * p0;

        drawArrow2(ax, p0, p1, 'b', meanL);
    end

    if dir == 2
        sKordLine = [sDist * L; -LArr];
        eKordLine = [eDist * L; -LArr];

        sKL = SKKord + R' * sKordLine;
        eKL = SKKord + R' * eKordLine;

        line(ax, [sKL(1), eKL(1)], [sKL(2), eKL(2)], 'color', 'b', 'LineWidth', 1.5);
        center = (sKL + eKL) / 2;
        ptext = getTextPos(center, dir, val, meanL);
        text(ax, ptext(1), ptext(2), num2str(StabLast_vert(i).Wert));

    elseif dir == 1
        centerLoc = [(sDist + eDist) / 2 * L; 0];
        center = SKKord + R' * centerLoc;
        ptext = getTextPos(center, dir, val, meanL);
        text(ax, ptext(1), ptext(2), num2str(StabLast_vert(i).Wert));
    end
end
end
