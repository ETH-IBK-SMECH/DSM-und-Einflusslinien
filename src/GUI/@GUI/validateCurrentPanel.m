function ok = validateCurrentPanel(app)
% Validates the currently active main panel.
% Returns true if everything is ok and we may leave the panel,
% false if we must stay (error or exception).

ok = true;

oldKey = app.getPanelKey(app.CurrentPanel);
if oldKey == ""
    % Nothing active -> nothing to validate
    return;
end

[in, issues1] = guiToInput(app, false);
issues2 = validateMainPanel(app, in, oldKey);
issues = mergeIssues(app, issues1, issues2);

if ~issues.ok
    msg = strjoin(issues.messages, newline);
    uialert(app.UIFigure, msg, 'Eingabefehler');
    ok = false; % block leaving this panel
end
end
