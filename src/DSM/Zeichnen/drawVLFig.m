function [out] = drawVLFig(model)

Knoten = model.Analyse.Knoten;
KnotenKORD = table2array(struct2table(Knoten));

Stab = model.Analyse.Stab;
nStaebe = numel(Stab);
StaebeKORD = zeros(nStaebe, 2);
for i = 1:nStaebe
    StaebeKORD(i, :) = [Stab(i).sNode, Stab(i).eNode];
end

VLStab = model.Output.VLStab;

Einflusslinie = model.Analyse.Einflusslinie;

t = tiledlayout(2, 1);
title(t, "Einflusslinie");

nexttile;
drawOriginalFig(model);
title("Struktur");


nexttile;
for i = 1:nStaebe

    R = Stab(i).R(1:2, 1:2);

    VL = [VLStab(i).x; VLStab(i).u'];
    VL_rot = R' * VL;

    startKnoten = Stab(i).sNode;
    startKORD = KnotenKORD(startKnoten, :)';

    VL_KORD = VL_rot + startKORD;

    VL_KORD(:, end+1) = [NaN; NaN];

    patch(VL_KORD(1, :), VL_KORD(2, :), 'b', 'FaceAlpha', 0.5, 'FaceColor', "none");
    patch('Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1);
end

switch Einflusslinie.TypEL
    case 1
        teilsatz = "N am Stab " + num2str(Einflusslinie.Stab) + " an der Stelle " + num2str(Einflusslinie.Stelle) + "*L";
    case 2
        teilsatz = "V am Stab " + num2str(Einflusslinie.Stab) + " an der Stelle " + num2str(Einflusslinie.Stelle) + "*L";
    case 3
        teilsatz = "M am Stab " + num2str(Einflusslinie.Stab) + " an der Stelle " + num2str(Einflusslinie.Stelle) + "*L";
    case 4
        teilsatz = "Lager am Knoten " + num2str(Einflusslinie.Knoten) + " in Richtung " + num2str(Einflusslinie.Richtung);
end
title("Einflusslinie für "+teilsatz);
axis equal;


end
