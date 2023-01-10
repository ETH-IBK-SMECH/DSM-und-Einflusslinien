function [in] = InputFile3()
%KOLLOQIUM 6 AUFGABE 2 wobei phi = -2
%LÖSUNG IST KORREKT

   %Knoten
      xPos = [0,10,20,10]';
      yPos = [10,10,10,0]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2,2]';
      EndKnoten   = [2,3,4]';
      Querschnitt = [1,2,3]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);
   %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;
   %Querschnitte ( <-- irgendwelche Zahlen)
      
      EModul = [200,200,200]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [0.2,0.2,0.2]'; 
      Traegheitsmoment = [0.16,0.16,0.16]'; 
      GelenkStabAnfang = [3,0,0]';  
      GelenkStabende   = [0,3,0]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   %Federn
      Knoten = []';
      Feder  = []';
      Betrag = []';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,3,4]';
      Lagerung = [logical([0,0,1,0,0,0]); 
                  logical([0,0,1,0,0,0]);
                  logical([1,0,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = [4];
      Richtung = [3];
      Wert = [-2];
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

