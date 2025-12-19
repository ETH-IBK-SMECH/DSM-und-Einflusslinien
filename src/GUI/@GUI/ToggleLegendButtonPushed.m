function ToggleLegendButtonPushed(app)
ax = app.SystemViewer;
lgd = legend(ax);

if isempty(lgd) || ~isvalid(lgd)
    lgd = legend(ax, 'show'); % create once if missing
end

if strcmp(lgd.Visible, 'on')
    lgd.Visible = 'off';
else
    lgd.Visible = 'on';
end
end
