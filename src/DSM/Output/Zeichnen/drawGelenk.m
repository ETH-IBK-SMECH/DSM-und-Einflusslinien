function out = drawGelenk(ax, type, centre, meanL, parent)

switch type

    case 3
        radius = 0.025 * meanL;
        angles = linspace(-pi, pi);

        x = radius * cos(angles) + centre(1);
        y = radius * sin(angles) + centre(2);


        patch(ax, x, y, 'w', 'LineWidth', 1.1, 'Parent', parent);
end

end
