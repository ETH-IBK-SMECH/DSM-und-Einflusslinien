function [in] = InputFile10()
%KOLLOQUIUM 4 AUFGABE 2
%VERSCHIEBUNGEN UND SCHNITTKRÄFTE(M) KORREKT
%überprüft verteilte Last und Federn


   %Knoten
      xPos = [0,1.5,3.5,5,0.5,4.5]';
      yPos = [1,1,1,1,0,0]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2,3,2,3]';
      EndKnoten   = [2,3,4,5,6]';
      Querschnitt = [1,1,1,2,2]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);

   %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;

   %Querschnitte ( <-- irgendwelche Zahlen)
      
      EModul = [100, sqrt(2)*100]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [0.16*10^10,0.16*10^10]'; 
      Traegheitsmoment = [0.16,0.16]'; 
      GelenkStabAnfang = [0,0]';  
      GelenkStabende   = [0,0]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   %Federn
      Knoten = [5,6]';
      Feder  = [3,3]';
      Betrag = [(3*100*0.16),(3*100*0.16)]';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,4,5,6]';
      Lagerung = [logical([0,0,1,0,0,0]); 
                  logical([0,0,1,0,0,0]);
                  logical([0,1,0,0,0,0])
                  logical([0,1,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = []';
      Richtung = []';
      Wert = []';
      in.VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert);
      
   %KnotenLasten
      Knoten   = []'; 
      Richtung = []'; 
      Wert     = []';
      in.KnotenLasten = table(Knoten, Richtung, Wert);   
   %StabLasten (konzentriert)
      Stab = []';
      Richtung = []'; 
      Wert = []'; 
      StartPosition = []';
      in.StabLasten_konzentriert = table(Stab, Richtung, Wert, StartPosition);   
   %StabLasten (verteilt)
      Stab = [1]; 
      Richtung = [2]; 
      Wert = [-1]; 
      StartPosition = [0]; 
      EndPosition   = [1];
      in.StabLasten_verteilt = table(Stab, Richtung, Wert, StartPosition, EndPosition);

%gewünschter Output
      in.gew_output = 1; % 1:Schnittkräfte; 2:Einflusslinie

   %Einflusslinie
      TypEL = []; % 1:N, 2:V, 3:M, 4:Lager
      if TypEL == 4
          Knoten = [];
          Richtung = [];
          in.Einflusslinie = table(TypEL, Knoten, Richtung);
      else
          Stab = [];
          Stelle = []; %zw. 0 <= x <= 1
          in.Einflusslinie = table(TypEL, Stab, Stelle);
      end
end

