function [in] = InputFileTest5()

xPos = [0,1,3,5,7,9,7]';
yPos = [1,1,1,1,1,1,0]';

in.Knoten = table(xPos,yPos);

StartKnoten = [1,2,3,4,5,5]';
EndKnoten   = [2,3,4,5,6,7]';
Querschnitt = [1,1,2,3,1,4]';

in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);

EModul           = [1,1,1,1]';
Flaeche          = [10^6,10^6,10^6,10^6]'; 
Traegheitsmoment = [1,1,1,10^6]'; 
GelenkStabAnfang = [0,0,3,0]';  
GelenkStabende   = [0,3,0,0]';

nQuerschnitte = size(EModul,1);
dehnstarr = false(nQuerschnitte,1);
biegesteif = false(nQuerschnitte,1);
in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);

Knoten = [2,3,6,7]';
Lagerung = [logical([0,0,1,0,0,0]);
            logical([0,1,0,0,0,0]);
            logical([1,0,0,0,0,0]);
            logical([1,0,0,0,0,0])];

in.Lager = table(Knoten,Lagerung);

Knoten = []';
Feder  = []';
Betrag = []';

in.Feder = table(Knoten, Feder, Betrag)

Knoten   = []';
Richtung = []';
Wert     = []';

in.VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert);

in.gew_output = 2;

Knoten   = []'; 
Richtung = []'; 
Wert     = []';

in.KnotenLasten = table(Knoten, Richtung, Wert);

Stab          = []';
Richtung      = []'; 
Wert          = []'; 
StartPosition = []'; % 0 < StartPosition < 1

in.StabLasten_konzentriert = table(Stab, Richtung, Wert, StartPosition);

Stab          = []'; 
Richtung      = []'; 
Wert          = []'; 
StartPosition = []'; % 0 <= StartPosition < 1
EndPosition   = []'; % 0 < StartPosition <= 1

in.StabLasten_verteilt = table(Stab, Richtung, Wert, StartPosition, EndPosition);

TypEL = [3];

if TypEL == 4
  %AUSFÜLLEN, wenn Einflusslinie für Lagerreaktion gesucht
  Knoten   = [2];
  Richtung = [2];

  in.Einflusslinie = table(TypEL, Knoten, Richtung);
else
  %AUSFÜLLEN, wenn Einflusslinie für Schnittgrösse gesucht
  Stab   = [2];
  Stelle = [0.5]; %zw. 0 <= x <= 1

  in.Einflusslinie = table(TypEL, Stab, Stelle);
end

end