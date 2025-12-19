function updateIconsForTheme(app)
% Decide which suffix we want in this theme
if app.UIFigure.Theme.BaseColorStyle == "light"
    findStr = "-dark.png";
    repStr = "-light.png";
else
    findStr = "-light.png";
    repStr = "-dark.png";
end

% Switch all registered buttons from light<->dark
for btn = app.IconButtons(:)' % iterate over row vector
    if ~isempty(btn.Icon)
        btn.Icon = strrep(btn.Icon, findStr, repStr);
    end
end
end
