function drawArrow2(ax, p0, p1, color, parent)
%p0 are coordinates of tail as [x;y]
%p1 are coordinates of tip as [x;y]
%color as 'g'
if nargin < 5 || isempty(parent)
    parent = ax;
end

%spike gad do drii schriibe zum patche
patch(ax, [p0(1), p1(1)], [p0(2), p1(2)], color, ...
    'EdgeColor', color, ...
    'LineWidth', 1.5, ...
    'Parent', parent, ...
    'HitTest','off');

%now spike in dependence of tip position and angle

%length usrächne
%winku usrächne
dx = p1(1) - p0(1);
dy = p1(2) - p0(2);

len = hypot(dx, dy);   % actual arrow length
l = 0.8 * len;         % arrowhead size proportional to arrow length


%spitz chunnt bi p1
xKoord = [0, -0.1 * l, -0.1 * l];
yKoord = [0, 0.06 * l, -0.06 * l];

c = dx / len;
s = dy / len;
R = [c, s; -s, c];

tipKoord = R' * [xKoord; yKoord] + p1;

patch(ax, tipKoord(1, :), tipKoord(2, :), color, ...
    'EdgeColor', color, ...
    'Parent', parent, ...
    'HitTest','off');

end
