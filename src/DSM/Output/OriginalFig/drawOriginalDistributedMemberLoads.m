function drawOriginalDistributedMemberLoads(ax, Knoten, Staebe, StabLast_vert, meanL, L_arrow)
% Zeichnet verteilte Stablasten (blau)

for i = 1:numel(StabLast_vert)
    StabIdx = StabLast_vert(i).Stab;
    dir = StabLast_vert(i).Richtung;
    phys = StabLast_vert(i).Wert;

    hg = hggroup(ax); % Groups the arrow elements and label together

    s = sign(phys);
    if s == 0, continue; end

    sDist = StabLast_vert(i).StartPosition;
    eDist = StabLast_vert(i).EndPosition;

    LArr = s * L_arrow;

    R = Staebe(StabIdx).R(1:2, 1:2);
    SKKord = [Knoten(Staebe(StabIdx).StartKnoten).xPos; ...
        Knoten(Staebe(StabIdx).StartKnoten).yPos];
    L = Staebe(StabIdx).L;

    jmid = 0.5*(sDist + eDist) * L;

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

        drawArrow2(ax, p0, p1, 'r', hg);
    end

    if dir == 2
        base = SKKord + R' * [jmid; -LArr];

        if s > 0
            vAlign = 'top';
        else
            vAlign = 'bottom';
        end

        sKordLine = [sDist * L; -LArr];
        eKordLine = [eDist * L; -LArr];

        sKL = SKKord + R' * sKordLine;
        eKL = SKKord + R' * eKordLine;

        line(ax, [sKL(1), eKL(1)], [sKL(2), eKL(2)], 'color', 'r', 'LineWidth', 1.5, 'Parent', hg);
   
        text(ax, base(1), base(2), num2str(abs(StabLast_vert(i).Wert)), ...
            'Parent', hg, ...
            'FontSize', 14, ...
            'Margin', 1, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', vAlign, ...
            'Clipping', 'on', ...
            'HitTest', 'off');

    elseif dir == 1
        base = SKKord + R' * [jmid; 0];

        text(ax, base(1), base(2), num2str(abs(StabLast_vert(i).Wert)), ...
            'Parent', hg, ...
            'FontSize', 14, ...
            'Margin', 1, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'Clipping', 'on', ...
            'HitTest', 'off');
            
    end
    hLeg = plot(ax, NaN, NaN, 'r', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Vert. Stablast S%d', StabIdx)); % Namensgebung vlt anpassen.
    hLeg.UserData = hg;                       % link legend item -> group
    hLeg.HitTest = 'off';                     % so legend click still works
end
end
