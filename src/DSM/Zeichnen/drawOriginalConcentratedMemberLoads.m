function drawOriginalConcentratedMemberLoads(ax, Knoten, Staebe, StabLast_konz, meanL, L_arrow, R_moment)
% Zeichnet konzentrierte Stablasten (rot, inkl. Momente)

for i = 1:numel(StabLast_konz)
    StabIdx = StabLast_konz(i).Stab;
    dir = StabLast_konz(i).Richtung;
    phys = StabLast_konz(i).Wert;

    hg = hggroup(ax); % Groups the arrow elements and label together

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
            if dir == 2 && phys > 0
                vAlign = 'top';
            else
                vAlign = 'bottom';
            end

            drawArrow2(ax, p0, p1, 'r', hg);

            text(ax, p0(1), p0(2), num2str(StabLast_konz(i).Wert), ...
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

             text(ax, base(1), base(2), num2str(StabLast_konz(i).Wert), ...
                 'Parent', hg, ...
                 'FontSize', 14, ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'bottom', ...
                 'Clipping', 'on', ...
                 'HitTest', 'off');

    end
    hLeg = plot(ax, NaN, NaN, 'r', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Konz. Stablast %d', StabIdx)); % Namensgebung vlt anpassen.
    hLeg.UserData = hg;                       % link legend item -> group
    hLeg.HitTest = 'off';                     % legend click still works
end
end
