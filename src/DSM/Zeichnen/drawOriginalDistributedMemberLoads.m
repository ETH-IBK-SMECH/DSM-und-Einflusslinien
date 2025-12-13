function drawOriginalDistributedMemberLoads(ax, Knoten, Staebe, StabLast_vert, meanL, L_arrow)
% Zeichnet verteilte Stablasten (blau)

for i = 1:numel(StabLast_vert)
    StabIdx = StabLast_vert(i).Stab;
    dir = StabLast_vert(i).Richtung;

    phys = StabLast_vert(i).Wert;

    s = sign(phys);
    if s == 0, continue; end

    sDist = StabLast_vert(i).StartPosition;
    eDist = StabLast_vert(i).EndPosition;

    LArr = s * L_arrow;

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
   
        ptext = getTextPosForDistributedLoad(ax, SKKord, R, L, s, sDist, eDist, LArr, 5);
        text(ax, ptext(1), ptext(2), num2str(StabLast_vert(i).Wert), ...
            'Clipping','on', 'HorizontalAlignment','center', 'VerticalAlignment','middle');

    elseif dir == 1
        jmid = 0.5*(sDist + eDist) * L;

        base = SKKord + R' * [jmid; 0];            
        ptext = offsetText(ax, base, [0; 1], 5);     
        text(ax, ptext(1), ptext(2), num2str(StabLast_vert(i).Wert), ...
            'Clipping','on', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    end
end
end
