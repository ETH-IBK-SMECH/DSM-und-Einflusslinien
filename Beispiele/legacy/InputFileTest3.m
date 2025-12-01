function [in] = InputFileTest3()

%AUSFÜLLEN
xPos = [0,3,7,10,10]';
yPos = [2,2,2,2,0]';

Knoten = table(xPos,yPos)
in.Knoten = Knoten;

%AUSFÜLLEN
StartKnoten = [1,2,3,4,3]';
EndKnoten   = [2,3,4,5,5]';
Querschnitt = [1,1,1,2,1]';

Staebe = table(StartKnoten, EndKnoten, Querschnitt)
in.Staebe = Staebe;

%AUSFÜLLEN
Teilsysteme = {}; %falls keine vorhanden, bitte leere Klammer lassen
in.Teilsysteme = Teilsysteme;

%AUSFÜLLEN
EModul = [200,200]';
nQuerschnitte = size(EModul,1);
Flaeche = [0.2,0.2]'; %beliebig
Traegheitsmoment = [0.16,0.16]'; %beliebig
GelenkStabAnfang = [0,0]';  
GelenkStabende   = [0,3]';
dehnstarr = false(nQuerschnitte,1);
biegesteif = false(nQuerschnitte,1);

in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);

%AUSFÜLLEN
Knoten = []'; 
Feder  = []'; 
Betrag = []';
Feder = table(Knoten, Feder, Betrag)
in.Feder = Feder;

%AUSFÜLLEN
Knoten = [1,5]'; 
Lagerung = [logical([0,1,0,0,0,0]); ...
            logical([0,1,0,0,0,0])];

Lager = table(Knoten, Lagerung)
in.Lager = Lager;            

%AUSFÜLLEN
Knoten = []; 
Richtung = []; 
Wert = [];
VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert)
in.VorgeschriebeneVerschiebung = VorgeschriebeneVerschiebung;

%AUSFÜLLEN
Knoten   = [3]'; 
Richtung = [2]'; 
Wert     = [300]';
KnotenLasten = table(Knoten, Richtung, Wert)
in.KnotenLasten = KnotenLasten;   

%AUSFÜLLEN
Stab = []'; 
Richtung = []; 
Wert = []; 
StartPosition = []';
StabLasten_konzentriert = table(Stab, Richtung, Wert, StartPosition)
in.StabLasten_konzentriert = StabLasten_konzentriert;   

%AUSFÜLLEN
Stab = []; 
Richtung = []; 
Wert = []; 
StartPosition = []; 
EndPosition   = [];
StabLasten_verteilt = table(Stab, Richtung, Wert, StartPosition, EndPosition)
in.StabLasten_verteilt = StabLasten_verteilt;

%gewünschter Output
%AUSFÜLLEN
in.gew_output = 1; % 1:Schnittkräfte; 2:Einflusslinie

%Einflusslinie
%AUSFÜLLEN
TypEL = []; % 1:N, 2:V, 3:M, 4:Lager

if TypEL == 4
  %AUSFÜLLEN, wenn Einflusslinie für Lagerreaktion gesucht
  Knoten   = [];
  Richtung = [];

  in.Einflusslinie = table(TypEL, Knoten, Richtung);

else
  %AUSFÜLLEN, wenn Einflusslinie für Schnittgrösse gesucht
  Stab   = [];
  Stelle = []; %zw. 0 <= x <= 1

  in.Einflusslinie = table(TypEL, Stab, Stelle);
end

end
