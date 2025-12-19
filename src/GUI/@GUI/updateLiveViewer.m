function updateLiveViewer(app, in)
ax = app.SystemViewer;
cla(ax);

try
    % Read GUI input without hard validation
    if nargin < 2
        [in, ~] = guiToInput(app, false);
    end
    in.Knoten = dropIncompleteRows(app, in.Knoten, {'xPos', 'yPos'});
    in.Staebe = dropIncompleteRows(app, in.Staebe, ...
        {'StartKnoten', 'EndKnoten', 'Querschnitt', 'GelenkStabAnfang', 'GelenkStabende'});

    in.Lager = dropIncompleteRows(app, in.Lager, {'Knoten', 'Lagerung'});
    in.Feder = dropIncompleteRows(app, in.Feder, {'Knoten', 'Feder', 'Betrag'});

    in.KnotenLasten = dropIncompleteRows(app, in.KnotenLasten, {'Knoten', 'Richtung', 'Wert'});
    in.StabLasten_konzentriert = dropIncompleteRows(app, in.StabLasten_konzentriert, ...
        {'Stab', 'Richtung', 'Wert', 'StartPosition'});
    in.StabLasten_verteilt = dropIncompleteRows(app, in.StabLasten_verteilt, ...
        {'Stab', 'Richtung', 'Wert', 'StartPosition', 'EndPosition'});


    % If no nodes yet -> nothing to draw
    if ~istable(in.Knoten) || isempty(in.Knoten)
        return;
    end

    if istable(in.Staebe) && ~isempty(in.Staebe)
        ModelPreview = buildPreviewModel(app, in);
        drawOriginalFig(ax, ModelPreview); % reuse full final drawing pipeline
    end
    Kstruct = table2struct(in.Knoten);
    drawOriginalNodes(ax, Kstruct);
    %create / update the legend
    lgd = legend(ax, 'show');
    lgd.ItemHitFcn = @(src, evt) toggleTrace(app, evt);

    % make sure that the visibility state of the items is kept
    objs = findobj(ax, '-property', 'DisplayName');
    for k = 1:numel(objs)
        if any(app.HiddenLegendNames == string(objs(k).DisplayName))
            objs(k).Visible = 'off';
            if isgraphics(objs(k).UserData)
                objs(k).UserData.Visible = 'off'; % hide group
            end
        end
    end
    axis(ax, 'equal');
    axis(ax, 'padded');
    drawnow;


catch ME
    % Don't block the GUI with alerts while the user is editing
    disp("Live viewer skipped due to error");
    %rethrow(ME) if you want to see the error
end
end
