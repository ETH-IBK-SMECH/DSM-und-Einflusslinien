% toggles the legend items
function toggleTrace(app, evt)
h = evt.Peer; % the graphics object (line) linked to clicked legend item
ud = h.UserData;
target = h;

if isgraphics(ud)
    target = ud;
end

if strcmp(h.Visible, 'on')
    target.Visible = 'off';
    h.Visible = 'off';
else
    target.Visible = 'on';
    h.Visible = 'on';
end

% so the visibility is not reset
name = string(h.DisplayName);
if strcmp(target.Visible, 'off')
    app.HiddenLegendNames = unique([app.HiddenLegendNames; name]);
else
    app.HiddenLegendNames(app.HiddenLegendNames == name) = [];
end
end
