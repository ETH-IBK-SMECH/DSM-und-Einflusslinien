function [in] = InputFile4()
%Kolloqium 6 Aufgabe 1
%VERSCHIEBUNGEN SIND KORREKT

   %Knoten
      xPos = [0,10,20]';
      yPos = [0,5,0]';
      in.Knoten = table(xPos, yPos);
   %Stäbe
      StartKnoten = [1,2]';
      EndKnoten   = [2,3]';
      Querschnitt = [1,2]';
      in.Staebe = table(StartKnoten, EndKnoten, Querschnitt);

      %Teilsysteme
      BeteiligteStaebe = {};
      in.Teilsysteme = BeteiligteStaebe;
   %Querschnitte ( <-- irgendwelche Zahlen)
      %nQuerschnitte = size(Querschnitt,1);
      EModul = [200,200]';
      nQuerschnitte = size(EModul,1);
      Flaeche = [0.2,0.2*2.5]'; 
      Traegheitsmoment = [0.16,0.16]'; 
      GelenkStabAnfang = [3,3]';  
      GelenkStabende   = [3,3]';
      dehnstarr = false(nQuerschnitte,1);
      biegesteif = false(nQuerschnitte,1);
      in.Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabende, dehnstarr, biegesteif);
   %Federn
      Knoten = []';
      Feder  = []';
      Betrag = []';
      in.Feder = table(Knoten, Feder, Betrag);
      
   %Lager
      Knoten = [1,3]';
      Lagerung = [logical([0,1,0,0,0,0]); 
                  logical([0,1,0,0,0,0])];
      in.Lager = table(Knoten, Lagerung);         
   %Zwängungen
      Knoten = [];
      Richtung = [];
      Wert = [];
      in.VorgeschriebeneVerschiebung = table(Knoten, Richtung, Wert);
      
   %KnotenLasten
      Knoten   = [2,2]'; 
      Richtung = [1,2]'; 
      Wert     = [100,300]';
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

