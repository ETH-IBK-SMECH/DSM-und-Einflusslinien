function out = drawFig(model)

fig = figure;

t = tiledlayout(fig, 1, 1);
title(t, 'Struktur');

ax = nexttile(t);
axis(ax, 'equal');
drawOriginalFig(ax, model);

end
