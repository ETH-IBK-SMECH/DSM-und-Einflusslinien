function drawOriginalNodalLoads(ax, Knoten, KnotenLast, meanL, nKL, L_arrow, R_moment)
% Zeichnet Knotenlasten (rot, Kräfte und Momente)

for i = 1:nKL
    KnotenIdx = KnotenLast(i).node;
    dir = KnotenLast(i).dir;
    phys = KnotenLast(i).val;

    hg = hggroup(ax); % Groups the arrow elements and label together

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
            if dir == 2 && phys > 0
                vAlign = 'top';
            else
                vAlign = 'bottom';
            end
            drawArrow2(ax, p0, p1, 'r', hg);
            text(ax, p0(1), p0(2), num2str(KnotenLast(i).val), ...
                'Parent', hg, ...
                'FontSize', 14, ...
                'Margin', 1, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', vAlign, ...
                'Clipping', 'on', ...
                'HitTest', 'off');

        case 3
            s = sign(phys);
            if s == 0, continue; end
            drawCircularArrow(ax, R_moment, p1, s, 'r', hg);
            base = p1 + [-s; -1] * (0.7 * R_moment);
            text(ax, base(1), base(2), num2str(KnotenLast(i).val), ...
                 'Parent', hg, ...
                 'FontSize', 14, ...
                 'Margin', 1, ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'bottom', ...
                 'Clipping', 'on', ...
                 'HitTest', 'off');

    end
    hLeg = plot(ax, NaN, NaN, 'r', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Knotenlast %d', KnotenIdx));
    hLeg.UserData = hg;                       % link legend item -> group
    hLeg.HitTest = 'off';                     % legend click still works
end
end

