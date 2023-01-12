function [out] = ModelFuerEinflusslinie(aM)
    
out = aM; %damit das alte nicht verloren geht und wir nur das nötige ändern können

%% die nötigen Werte
    Knoten  = aM.Knoten;
    Stab    = aM.Stab;
    SPC     = aM.SPC;
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

    x_neu = xS + Einflusslinie.Stelle*(xE-xS);
    y_neu = yS + Einflusslinie.Stelle*(yE-yS);

    Kneu_1 = size(Knoten,2) + 1;
    Kneu_2 = size(Knoten,2) + 2;
    Knoten(Kneu_1).x = x_neu;
    Knoten(Kneu_1).y = y_neu;
    Knoten(Kneu_2).x = x_neu;
    Knoten(Kneu_2).y = y_neu;

    Stab(end+1) = Stab(Idx); %erster neure Teilstab
    Stab(end).eNode = size(Knoten,2)-1;
    Stab(end).eRelease = [];

    Stab(end+1) = Stab(Idx);
    Stab(end).sNode = size(Knoten,2);
    Stab(end).sRelease = [];


        
%% alten Stab löschen

    Stab(Idx) = [];


%% das nötige zurückgeben
    out.Knoten  = Knoten;
    out.Stab    = Stab;
    out.SPC     = SPC;
    out.Einflusslinie = Einflusslinie;


end

