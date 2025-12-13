function [out] = drawAuflagerreaktionen(Model)

fig = figure;

Knoten = struct( ...
    'xPos', num2cell([Model.Analyse.Knoten.x]), ...
    'yPos', num2cell([Model.Analyse.Knoten.y]));

SPC = Model.Analyse.SPC;
meanL = mean([Model.Analyse.Stab.L]);
Feder = Model.Analyse.Feder;

xAll = [Knoten.xPos];
yAll = [Knoten.yPos];
Lsys = hypot(max(xAll)-min(xAll), max(yAll)-min(yAll));
if Lsys <= 0, Lsys = meanL; end

L_arrow  = 0.15 * Lsys;   % constant reaction arrow length
R_moment = 0.08 * Lsys;   % constant reaction moment radius

t = tiledlayout(fig, 1, 1);
title(t, "Auflagerreaktionen")

ax = nexttile(t);

drawOriginalFig(ax, Model);

for i = 1:size(SPC, 2)
    KnotenIdx = SPC(i).node;
    dir = SPC(i).dir;
    phys = SPC(i).Reaktion;
    s = sign(phys);
    if s == 0, continue; end
    LArr = s * L_arrow;

    p1 = [Knoten(KnotenIdx).xPos; Knoten(KnotenIdx).yPos];

    switch dir
        case 1
            p0 = [-LArr; 0];
        case 2
            p0 = [0; -LArr];
    end

    switch dir
        case {1, 2}
            p0 = p0 + p1;

            drawArrow2(ax, p0, p1, 'm', meanL);

            ptext = getTextPosFromArrow(ax, p0, s, 5);
            text(ax, ptext(1), ptext(2), num2str(SPC(i).Reaktion), ...
                'Clipping','on', ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle');

        case 3
            drawCircularArrow(ax, R_moment, p1, sign(phys), 'm');

            ptext = getTextPosFromMoment(ax, p1, R_moment, sign(phys), 5);
            text(ax, ptext(1), ptext(2), num2str(SPC(i).Reaktion), ...
                'Clipping','on', ...
                'HorizontalAlignment','left', ...
                'VerticalAlignment','bottom');

    end

end

%Auflagerreaktion von Feder
if isfield(Feder, 'Reaktion')
    for i = 1:size(Feder, 2)
        KnotenIdx = Feder(i).node;
        dir = Feder(i).dir;
        phys = Feder(i).Reaktion;

        s = sign(phys);
        if s == 0, continue; end

        p1 = [Knoten(KnotenIdx).xPos; Knoten(KnotenIdx).yPos];

        switch dir
            case 1
                p0 = [-LArr; 0];
            case 2
                p0 = [0; -LArr];
        end

        switch dir
            case {1, 2}
                p0 = p0 + p1;

                drawArrow2(ax, p0, p1, 'm', meanL);

                ptext = getTextPosFromArrow(ax, p0, s, 5);   % same as external forces
                text(ax, ptext(1), ptext(2), num2str(SPC(i).Reaktion), ...
                    'Clipping','on', ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle');

            case 3
                drawCircularArrow(ax, R_moment, p1, sign(phys), 'm');

                ptext = getTextPosFromMoment(ax, p1, R_moment, sign(phys), 5);
                text(ax, ptext(1), ptext(2), num2str(SPC(i).Reaktion), ...
                    'Clipping','on', ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','bottom');

        end

    end

end
