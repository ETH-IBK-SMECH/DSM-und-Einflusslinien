function [in] = InputFile100()

   %Knoten
      xPos = [0,1,1,2]';
      yPos = [0,0,0,0]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,3]';
      EndKnoten   = [2,4]';
      Querschnitt = [1,1]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);

   %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;

   %Querschnitte ( <-- irgendwelche Zahlen)    
      EModul = [1]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [1]'; 
      Traegheitsmoment = [1]'; 
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
      Knoten = [1,2,3,4]';
      Lagerung = [logical([1,0,0,0,0,0]); 
                  logical([1,0,0,0,0,0]);
                  logical([1,0,0,0,0,0]);
                  logical([0,1,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = [2,2,3,3]';
      Richtung = [2,3,2,3]';
      Wert = [0.3125,0.5625, -0.6875, 0.5625]';
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

