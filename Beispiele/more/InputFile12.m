function [in] = InputFile12()
%HAUSÜBUNG 2 AUFGABE 2
%SCHNITTKRÄFTE KORREKT
%überprüft Steifigkeit gegen unendlich

   %Knoten
      xPos = [0,0,1,2]';
      yPos = [0,1,1,1]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2,3]';
      EndKnoten   = [2,3,4]';
      Querschnitt = [1,2,1]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);
      %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;
   %Querschnitte ( <-- irgendwelche Zahlen)
      
      EModul = [2,2]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [1*10^10,1*10^10]'; 
      Traegheitsmoment = [1,1*10^10]'; 
      GelenkStabAnfang = [0,0]';  
      GelenkStabende   = [0,0]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   %Federn
      Knoten = []';
      Feder  = []';
      Betrag = []';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,4]';
      Lagerung = [logical([1,0,0,0,0,0]); 
                  logical([0,1,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = []';
      Richtung = []';
      Wert = []';
      in.VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert);
      
   %KnotenLasten
      Knoten   = [3]'; 
      Richtung = [2]'; 
      Wert     = [-1]';
      in.KnotenLasten = table(Knoten, Richtung, Wert);   
   %StabLasten (konzentriert)
      Stab = []';
      Richtung = []'; 
      Wert = []'; 
      StartPosition = []';
      in.StabLasten_konzentriert = table(Stab, Richtung, Wert, StartPosition);   
   %StabLasten (verteilt)
      Stab = []; 
      Richtung = []; 
      Wert = []; 
      StartPosition = []; 
      EndPosition   = [];
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

