function [erfolgreich, status, ErrorMeldung] = istGueltigerInput(in)
    erfolgreich = true;
    status = 1;
    ErrorMeldung = '';
    
%% Input vereinfacht
    Knoten = in.Knoten;
    nKnoten = size(Knoten,1);
    Staebe = in.Staebe;
    nStaebe = size(Staebe,1);
    Querschnitte = in.Querschnitte;
    nQuerschnitte = size(Querschnitte,1);
    Feder = in.Feder;
    nFeder = size(Feder,1);
    Lager = in.Lager;
    nLager = size(Lager,1);
    VorgeschriebeneVerschiebung = in.VorgeschriebeneVerschiebung;
    nVV = size(VorgeschriebeneVerschiebung,1);
    KnotenLasten = in.KnotenLasten;
    nKnotenLasten = size(KnotenLasten,1);
    StabLasten_konzentriert = in.StabLasten_konzentriert;
    nStabLasten_konzentriert = size(StabLasten_konzentriert,1);
    StabLasten_verteilt = in.StabLasten_verteilt;
    nStabLasten_verteilt = size(StabLasten_verteilt,1);


%% Knoten überprüfen
    
    %keine doppelten Knoten
    for i = 1:nKnoten
        for j = i+1:nKnoten
            if isequal(Knoten.xPos(i), Knoten.xPos(j)) && isequal(Knoten.yPos(i), Knoten.yPos(j))
                erfolgreich = false;
                ErrorMeldung = "Die Knoten " + i + " und " + j +  " sind identisch.";
                disp(ErrorMeldung);
            end
        end
    end



%% Stäbe überprüfen

    for i = 1:nStaebe
        %Startknoten != Endknoten
        if isequal(Staebe.StartKnoten(i), Staebe.EndKnoten(i))
            erfolgreich = false;
            ErrorMeldung = "Startknoten darf nicht dem Endknoten entsprechen.";
            disp(ErrorMeldung);
        end

        %Knoten vorhanden?
        if Staebe.StartKnoten(i) > nKnoten
            erfolgreich = false;
            ErrorMeldung = "Der Startknoten vom Stab " + i + " existiert nicht.";
            disp(ErrorMeldung);
        end
        if Staebe.EndKnoten(i) > nKnoten
            erfolgreich = false;
            ErrorMeldung = "Der Endknoten vom Stab "+ i + " existiert nicht.";
            disp(ErrorMeldung);
        end

        %QS vorhanden?
        if Staebe.Querschnitt > nQuerschnitte
            erfolgreich = false;
            ErrorMeldung = "Querschnitt vom Stab " + i + " existiert nicht.";
            disp(ErrorMeldung);
        end

        %keine doppelten Stäbe
        for j = i+1:nStaebe
            if (isequal(Staebe.StartKnoten(i), Staebe.StartKnoten(j)) && isequal(Staebe.EndKnoten(i),Staebe.EndKnoten(j))) || ...
                    (isequal(Staebe.StartKnoten(i), Staebe.EndKnoten(j)) && isequal(Staebe.StartKnoten(j),Staebe.EndKnoten(i)))
                erfolgreich = false;
                ErrorMeldung = "Stab " + j + " existiert bereits (als Stab " + i + ").";
                disp(ErrorMeldung);
            end
        end
    end


%% Teilsysteme überprüfen


%% Querschnitte überprüfen

    for i = 1:nQuerschnitte

        %E-Modul positiv
        if Querschnitte.EModul(i) <= 0
            erfolgreich = false;
            ErrorMeldung = "Das E-Modul des Querschnitts "+ i + " ist negativ oder 0.";
            disp(ErrorMeldung);
        end

        %Fläche positiv
        if Querschnitte.Flaeche(i) <= 0
            erfolgreich = false;
            ErrorMeldung = "Die Fläche des Querschnitts " + i + " ist negativ oder 0.";
            disp(ErrorMeldung);
        end

        %I positiv
        if Querschnitte.Traegheitsmoment(i) <= 0
            erfolgreich = false;
            ErrorMeldung = "Das Trägheitsmoment des Querschnitts " + i + " ist negativ oder 0.";
            disp(ErrorMeldung);
        end

        %sR und eR nicht gleich ausser bei Momentengelenk
        if (isequal(Querschnitte.GelenkStabAnfang(i),1) && isequal(Querschnitte.GelenkStabende(i),1)) || ...
                (isequal(Querschnitte.GelenkStabAnfang(i),2) && isequal(Querschnitte.GelenkStabende(i),2))
            erfolgreich = false;
            ErrorMeldung = "Querschnitt " + i + " ist instabil, da dieser beidseitig nicht gehalten werden kann.";
            disp(ErrorMeldung);
        end
    end


%% Lager überprüfen

% Knoten vorhanden?
    for i = 1:nLager

        %Knoten vorhanden?
        if Lager.Knoten(i) > nKnoten
            erfolgreich = false;
            ErrorMeldung = "Der Knoten des Lagers " + i + " existiert nicht.";
            disp(ErrorMeldung);
        end
        
        %nur 1 Lager pro Knoten
        for j = i+1:nLager
            if Lager.Knoten(i) == Lager.Knoten(j)
                erfolgreich = false;
                ErrorMeldung = "Am Knoten " + i + " existiert bereits ein Lager. Lager " + j + " muss geändert oder gelöscht werden.";
                disp(ErrorMeldung);
            end
        end
        
        %luege ds DOF existiert am Knoten auso ds glänk vorhande eig
        %EIG BESSER DS DSM Z BEHEBE WÄG ACTIVEDOFS WO BRUCHT WÄRDE

    end

% luege wäge SPC nid überschniide um if- in dsm useznäh
% if(~isequal(DOF(SPCIdx),0))
          % SPC(i).DOF = DOF(SPCIdx);
     %  end


%% Feder überprüfen

% Knoten vorhanden?
    for i = 1:nFeder

        %Knoten vorhanden?
        if Feder.Knoten(i) > nKnoten
            erfolgreich = false;
            ErrorMeldung = "Der Knoten der Feder " + i + " existiert nicht.";
            disp(ErrorMeldung);
        end
        
        %Wert > 0
        if Feder.Betrag <= 0
            erfolgreich = false;
            ErrorMeldung = "Die Steifigkeit einer Feder darf nicht negativ oder 0 sein. Überprüfe Feder Nr. " + i + ".";
            disp(ErrorMeldung);
        end

        %Feder nicht doppelt
        for j = i+1:nFeder
            if Feder.Knoten(i) == Feder.Knoten(j) && Feder.Feder(i) == Feder.Feder(j)
                erfolgreich = false;
                ErrorMeldung = "Am Knoten " + Feder.Knoten(i) + " existiert bereits eine Feder in Richtung " + Feder.Feder(i) + ". Feder Nr. " + j + " (oder " + i + ") muss gelöscht oder geändert werden.";
                disp(ErrorMeldung);
            end
        end
    end


%% Vorgeschriebene Verschiebungen überprüfen

    for i = 1:nVV

        %Knoten vorhanden
        if VorgeschriebeneVerschiebung.Knoten(i) > nKnoten
            erfolgreich = false;
            ErrorMeldung = "Der Knoten der vorgeschriebenen Verschiebung " + i + " existiert nicht.";
            disp(ErrorMeldung);
        end
        
        %nichts doppelt -> Knoten - Richtung
        for j = i+1:nVV
            if VorgeschriebeneVerschiebung.Knoten(i) == VorgeschriebeneVerschiebung.Knoten(j) && VorgeschriebeneVerschiebung.Richtung(i) == VorgeschriebeneVerschiebung.Richtung(j)
                erfolgreich = false;
                ErrorMeldung = "Am Knoten " + VorgeschriebeneVerschiebung.Knoten(i) + " existiert bereits eine vorgeschriebene Verschiebung in Richtung " + VorgeschriebeneVerschiebung.Richtung(i) + ". Die vorgeschriebene Verschiebung Nr. " + i + " (oder " + j + ") muss gelöscht oder geändert werden.";
                disp(ErrorMeldung);
            end
        end
    end
    

%% KnotenLasten überprüfen

% Knoten vorhanden?

% DOF muss existieren

%% StabLasten überprüfen

% Stab vorhanden?

% 0 <= Start <= 1

% Start < Ende <= 1


end

%{
Was gilt es hier zu prüfen, bzw. welche Probleme können hier bereits abgefangen werden!

Allgemein:
- Werden alle definierten Grössen verwendet
- Werden Indizes für Grössen verwendet, die ausserhalb des definierten Bereichs sind (z.B. Knoten 20 wenn nur 4 definiert sind usw.)

Stab:
- Stabanfangs- und End-Knoten müssen unterschiedlich sein
- Doppelnormalkraftgelenk sowie Doppelquerkraftgelenk nicht zulässig (ausser evtl. konstrukive Massnahmen getroffen)

Lasten:
- Lastangriffspunkte innerhalb 0<t<1
- Lastanfangspunkt darf nicht Lastendpunkt oder vor Lastendpunkt sein für verteilte Lasten
- Lasten können nur auf DOF angreifen (d.h. DOF muss vorhanden sein)

Lagerung:
- Lagerbedingungen nur für die Lagerknoten DOF zulässig, welche auch Widerstand haben (z.B. infolge Stäbe oder Federn) 

MISC:
- Nicht alle dieser Kontrollen können an dieser Stelle durchgeführt werden.
- Es braucht auch innerhalb des Berechnungscodes gewisse Checks


%}
