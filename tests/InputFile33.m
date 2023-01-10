function [in] = InputFile33()

   %Knoten
      xPos = [0,1,2,3,1]';
      yPos = [1,1,1,1,0]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2,3,2]';
      EndKnoten   = [2,3,4,5]';
      Querschnitt = [1,1,1,1]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);

   %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;

   %Querschnitte ( <-- irgendwelche Zahlen)    
      EModul = [2.5]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [17*10^10]'; 
      Traegheitsmoment = [14]'; 
      GelenkStabAnfang = [0]';  
      GelenkStabende   = [0]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   %Federn
      Knoten = []';
      Feder  = []';
      Betrag = []';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,3,4,5]';
      Lagerung = [logical([0,1,0,0,0,0]); 
                  logical([0,0,1,0,0,0]); 
                  logical([0,0,1,0,0,0]); 
                  logical([1,0,0,0,0,0])];
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
      Stab = []'; 
      Richtung = []'; 
      Wert = []'; 
      StartPosition = []'; 
      EndPosition   = []';
      in.StabLasten_verteilt = table(Stab, Richtung, Wert, StartPosition, EndPosition);

   %gewünschter Output
      in.gew_output = 2; % 1:Schnittkräfte; 2:Einflusslinie

   %Einflusslinie
      TypEL = [3]; % 1:N, 2:V, 3:M, 4:Lager
      if TypEL == 4
          Knoten = [1];
          Richtung = [2];
          in.Einflusslinie = table(TypEL, Knoten, Richtung);
      else
          Stab = [2];
          Stelle = [0.5]; %zw. 0 <= x <= 1
          in.Einflusslinie = table(TypEL, Stab, Stelle);
      end

end

