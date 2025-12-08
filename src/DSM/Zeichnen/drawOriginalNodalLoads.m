function drawOriginalNodalLoads(Knoten, KnotenLast, meanL, meanKL, nKL)
% Zeichnet Knotenlasten (rot, Kräfte und Momente)

for i = 1:nKL
    KnotenIdx = KnotenLast(i).node;
    dir = KnotenLast(i).dir;
    phys = KnotenLast(i).val;

    if dir == 3
        phys = phys / 1000; % kNmm -> kNm
    end

    val = phys / meanKL;
    LArr = val * 0.25 * meanL;

    p1 = [Knoten(KnotenIdx).xPos; Knoten(KnotenIdx).yPos];
    ptext = getTextPos(p1, dir, val, meanL);

    switch dir
        case 1
            p0 = [-LArr; 0];
        case 2
            p0 = [0; -LArr];
    end

    switch dir
        case {1, 2}
            p0 = p0 + p1;
            drawArrow2(p0, p1, 'r', meanL);
            text(ptext(1), ptext(2), num2str(KnotenLast(i).val));

        case 3
            radius = abs(val) * meanL * 0.125;
            drawCircularArrow(radius, p1, sign(val), 'r');
            text(ptext(1), ptext(2), num2str(KnotenLast(i).val));
    end
end
end
