function ptext = offsetText(ax, basePoint, dirVec, pix)
    % basePoint: [x;y] in data units
    % dirVec: direction in data coords (will be normalized)
    % pix: desired offset in pixels

    dirVec = dirVec(:);
    if norm(dirVec) < eps, dirVec = [0;1]; end
    dirVec = dirVec / norm(dirVec);

    % Axes size in pixels
    oldUnits = ax.Units;
    ax.Units = 'pixels';
    pos = ax.Position;            % [left bottom width height] in px
    ax.Units = oldUnits;

    % Data range
    xl = xlim(ax); yl = ylim(ax);

    % Convert pixels -> data units (approx)
    dx_per_px = (xl(2)-xl(1)) / max(pos(3),1);
    dy_per_px = (yl(2)-yl(1)) / max(pos(4),1);

    offset = [dirVec(1)*pix*dx_per_px; dirVec(2)*pix*dy_per_px];
    ptext = basePoint + offset;
end
