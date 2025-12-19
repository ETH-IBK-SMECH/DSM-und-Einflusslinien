function PopupFigCloseRequest(app, event)
% Instead of deleting the figure, just hide it
% Figure is fully deleted with UIfig
app.PopupFig.Visible = 'off';

% Hide any active popup panel too
if ~isempty(app.CurrentPopUpPanel) && isvalid(app.CurrentPopUpPanel)
    app.CurrentPopUpPanel.Visible = 'off';
end

% Reset state
app.CurrentPopUpPanel = [];
end
