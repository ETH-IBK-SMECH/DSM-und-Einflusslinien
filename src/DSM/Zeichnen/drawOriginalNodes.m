function drawOriginalNodes(ax, Knoten)
    % Zeichnet nur die Knoten als Punkte (für Live-Viewer) in die gegebene Achse

    if isempty(Knoten)
        return;
    end

    KnotenKORD = table2array(struct2table(Knoten));
    x = KnotenKORD(:, 1);
    y = KnotenKORD(:, 2);

    % IMPORTANT: ask "ishold" about THIS axes, not gca
    holdState = ishold(ax);

    hold(ax, 'on');
    plot(ax, x, y, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

    if ~holdState
        hold(ax, 'off');
    end
end
