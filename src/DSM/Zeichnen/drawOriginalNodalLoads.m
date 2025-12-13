function drawOriginalNodalLoads(ax, Knoten, KnotenLast, meanL, nKL, L_arrow, R_moment)
% Zeichnet Knotenlasten (rot, Kräfte und Momente)

for i = 1:nKL
    KnotenIdx = KnotenLast(i).node;
    dir = KnotenLast(i).dir;
    phys = KnotenLast(i).val;

    if dir ~= 3
        s = sign(phys);
        if s == 0, continue; end
        LArr = s * L_arrow;
    end

    
    p1 = [Knoten(KnotenIdx).xPos; Knoten(KnotenIdx).yPos];

    switch dir
        case 1
            p0 = [-LArr; 0];
        case 2
            p0 = [0; -LArr];
    end

    switch dir
        case {1, 2}
            p0 = p0 + p1;
            drawArrow2(ax, p0, p1, 'r', meanL);
            ptext = getTextPosFromArrow(ax, p0, s, 5);
            text(ax, ptext(1), ptext(2), num2str(KnotenLast(i).val), ...
                'Clipping','on', 'HorizontalAlignment','center', 'VerticalAlignment','middle');

        case 3
            s = sign(phys);
            if s == 0, continue; end
            drawCircularArrow(ax, R_moment, p1, s, 'r');
            ptext = getTextPosFromMoment(ax, p1, R_moment, sign(phys), 5);
            text(ax, ptext(1), ptext(2), num2str(KnotenLast(i).val), ...
                'Clipping','on', 'HorizontalAlignment','left', 'VerticalAlignment','bottom');

    end
end
end

