function [in] = InputFile1()
   %Knoten
      xPos = [0,0,5]';
      yPos = [0,10,10]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2]';
      EndKnoten   = [2,3]';
      Querschnitt = [1,2]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);
   %Querschnitte ( <-- irgendwelche Zahlen)
      nQuerschnitte = size(Querschnitt,1);
      EModul = [210,210]';
      Flaeche = [0.2,0.4]'; 
      Traegheitsmoment = [0.16, 0.28]'; 
      GelenkStabAnfang = [0,3]';  
      GelenkStabende   = [3,0]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   
   %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;
   
   %Federn
      Knoten = [2,3]';
      Feder  = [1,2]';
      Betrag = [12,3]';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,3]';
      Lagerung = [logical([1,0,0,0,0,0]); 
                  logical([1,0,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = 2;
      Richtung = 1;
      Wert = 0.05;
      in.VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert);
      
   %KnotenLasten
      Knoten   = 2; 
      Richtung = 2; 
      Wert     = 10;
      in.KnotenLasten = table(Knoten, Richtung, Wert);   
   %StabLasten (konzentriert)
      Stab = 1;
      Richtung = 1; 
      Wert = 8; 
      StartPosition = 0.25;
      in.StabLasten_konzentriert = table(Stab, Richtung, Wert, StartPosition);   
   %StabLasten (verteilt)
      Stab = 1; 
      Richtung = 2; 
      Wert = 2; 
      StartPosition = 0.1; 
      EndPosition   = 0.9;
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

