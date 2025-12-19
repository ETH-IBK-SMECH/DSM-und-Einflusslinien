function [out] = modelFuerEinflusslinie(aM)

out = aM; %damit das alte nicht verloren geht und wir nur das nötige ändern können
%% die nötigen Werte
Knoten = aM.Knoten;
Stab = aM.Stab;
SPC = aM.SPC;
Einflusslinie = aM.Einflusslinie;
%% Änderung des Modells für EL Lager

if Einflusslinie.TypEL == 4

    SPC(end+1).node = Einflusslinie.Knoten;
    SPC(end).dir = Einflusslinie.Richtung;
    SPC(end).val = -1;

    out.SPC = SPC;
    return
end
%% Änderung des Modells für EL

Idx = Einflusslinie.Stab;

xS = Knoten(Stab(Idx).sNode).x;
yS = Knoten(Stab(Idx).sNode).y;
xE = Knoten(Stab(Idx).eNode).x;
yE = Knoten(Stab(Idx).eNode).y;

x_neu = xS + Einflusslinie.Stelle * (xE - xS);
y_neu = yS + Einflusslinie.Stelle * (yE - yS);

Kneu_1 = numel(Knoten) + 1;
Kneu_2 = numel(Knoten) + 2;
Knoten(Kneu_1).x = x_neu;
Knoten(Kneu_1).y = y_neu;
Knoten(Kneu_2).x = x_neu;
Knoten(Kneu_2).y = y_neu;

%erster neuer Teilstab
Stab(end+1) = Stab(Idx); 
Stab(end).eNode = Kneu_1;
Stab(end).eRelease = [];

%zweiter neuer Teilstab
Stab(end+1) = Stab(Idx);
Stab(end).sNode = Kneu_2;
Stab(end).sRelease = [];
%% alten Stab löschen

Stab(Idx) = [];
%% das nötige zurückgeben
out.Knoten = Knoten;
out.Stab = Stab;
out.SPC = SPC;

out.Einflusslinie = Einflusslinie;
out.Einflusslinie.cutNodes = [Kneu_1, Kneu_2];
if ~isfield(out.Einflusslinie, 'keepMask')
    out.Einflusslinie.keepMask = true(1, aM.Info.nKnotenDOF); 
end

% Info konsistent halten, falls vorhanden
if isfield(out, 'Info')
    out.Info.nKnoten = numel(out.Knoten);
    out.Info.nStaebe = numel(out.Stab);
end

%% sicherstellen dass alles existiert
if ~isfield(out, 'Feder'), out.Feder = []; end
if ~isfield(out, 'KnotenLast'), out.KnotenLast = []; end
if ~isfield(out, 'StabLast'), out.StabLast = []; end


end
