function drawOriginalConcentratedMemberLoads(ax, Knoten, Staebe, StabLast_konz, meanL, L_arrow, R_moment)
% Zeichnet konzentrierte Stablasten (rot, inkl. Momente)

for i = 1:numel(StabLast_konz)
    StabIdx = StabLast_konz(i).Stab;
    dir = StabLast_konz(i).Richtung;
    phys = StabLast_konz(i).Wert;

    sDist = StabLast_konz(i).StartPosition;

    if dir ~= 3
        s = sign(phys);
        if s == 0, continue; end
        LArr = s * L_arrow;
    end

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

            drawArrow2(ax, p0, p1, 'r', meanL);
            ptext = getTextPosFromArrow(ax, p0, s, 5);
            text(ax, ptext(1), ptext(2), num2str(StabLast_konz(i).Wert), ...
                'Clipping','on', 'HorizontalAlignment','center', 'VerticalAlignment','middle');


        case 3
             s = sign(phys);
             if s == 0, continue; end

             drawCircularArrow(ax, R_moment, p1, s, 'r');

             ptext = getTextPosFromMoment(ax, p1, R_moment, sign(phys), 5);
             text(ax, ptext(1), ptext(2), num2str(StabLast_konz(i).Wert), ...
                 'Clipping','on', 'HorizontalAlignment','left', 'VerticalAlignment','bottom');

    end
end
end
