function drawOriginalNodes(ax, Knoten)
    % Zeichnet nur die Knoten als Punkte (für Live-Viewer) in die gegebene Achse

    if isempty(Knoten)
        return;
    end

    hg = hggroup(ax);

    KnotenKORD = table2array(struct2table(Knoten));
    x = KnotenKORD(:, 1);
    y = KnotenKORD(:, 2);

    holdState = ishold(ax);

    hold(ax, 'on');
    plot(ax, x, y, 'ko', 'MarkerFaceColor', 'm', 'MarkerSize', 10, 'Parent', hg);

    n = numel(x);
    for i = 1:n
        basePoint = [x(i); y(i)];
        text(ax, basePoint(1), basePoint(2), sprintf('%d', i), ...
            'Parent', hg, ...
            'FontSize', 11, ...
            'Color', 'w', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Clipping', 'on', ...
            'HitTest', 'off');
    end
    
    hLeg = plot(ax, NaN, NaN, ...
    'o', ...                    % marker only
    'Color', 'm', ...
    'MarkerFaceColor', 'm', ...
    'MarkerSize', 6, ...
    'LineStyle', 'none', ...     % no line
    'DisplayName', 'Knoten');
    hLeg.UserData = hg;                       % link legend item -> group
    hLeg.HitTest = 'off';                     % legend click still works
    if ~holdState
        hold(ax, 'off');
    end
end
