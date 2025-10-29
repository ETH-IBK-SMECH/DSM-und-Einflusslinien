function [out] = inputUmwandeln(in)
%Model.Analyse.Info
    %K
    out.Info.nKnoten  = size(in.Knoten, 1);
    out.Info.nStaebe  = size(in.Staebe, 1);
    out.Info.nFedern  = size(in.Feder, 1);
    %U
    out.Info.nLager       = size(in.Lager, 1);
    out.Info.nZwaengungen = size(in.VorgeschriebeneVerschiebung, 1);
    out.Info.nRandbedingungen = out.Info.nLager + out.Info.nZwaengungen;
    %F
    out.Info.nKnotenLasten = size(in.KnotenLasten,1);
    out.Info.nStabLastenKonzentriert = size(in.StabLasten_konzentriert, 1);
    out.Info.nStabLastenVerteilt     = size(in.StabLasten_verteilt, 1); 
    out.Info.nStabLasten = out.Info.nStabLastenKonzentriert + out.Info.nStabLastenVerteilt; 
    
    %generel für Rahmentragwerke
    out.Info.nKnotenDOF = 3;
    
%Generierte Knoten und Stäbe addieren sofern nötig (z.B. bei Einflusslinie)
    
%Structs initialisieren
   %K --> Steifigkeiten
      %Knoten
      nKnoten = out.Info.nKnoten;
      for i=1:nKnoten
         out.Knoten(i).x = in.Knoten.xPos(i); 
         out.Knoten(i).y = in.Knoten.yPos(i);
      end

      %Stäbe
      nStaebe = out.Info.nStaebe;
      for i = 1:nStaebe 
         %Geometrie
         out.Stab(i).sNode = in.Staebe.StartKnoten(i);
         out.Stab(i).eNode = in.Staebe.EndKnoten(i);
         %Querschnitt
         QsIdx = in.Staebe.Querschnitt(i);
         out.Stab(i).E  = in.Querschnitte.EModul(QsIdx);                      %E-Modul
         out.Stab(i).A  = in.Querschnitte.Flaeche(QsIdx);                     %Querschnittsfläche
         out.Stab(i).Iy = in.Querschnitte.Traegheitsmoment(QsIdx);            %Trägheitsmoment
         out.Stab(i).EAinf = in.Querschnitte.dehnstarr(QsIdx);                %ist denkstarr
         out.Stab(i).EIinf = in.Querschnitte.biegesteif(QsIdx);               %ist biegesteif
         out.Stab(i).sRelease = in.Querschnitte.GelenkStabAnfang(QsIdx);      %Stabstartgelenk (1=N; 2=V; 3=M)
         out.Stab(i).eRelease = in.Querschnitte.GelenkStabende(QsIdx);        %Stabendgelenk   (1=N; 2=V; 3=M)
         if out.Stab(i).sRelease == 0; out.Stab(i).sRelease = []; end         %Stabendgelenk (0=keines --> leer = [] )
         if out.Stab(i).eRelease == 0; out.Stab(i).eRelease = []; end         %Stabendgelenk (0=keines --> leer = [] )
      end

      %Federn
      nFedern = out.Info.nFedern;
      out.Feder = struct('node',{},'dir',{},'val',{});
      for i=1:nFedern
         out.Feder(i).node = in.Feder.Knoten(i);
         out.Feder(i).dir = in.Feder.Feder(i);
         %out.Federn(i).dir  = find(in.Feder.Feder(i)); %gibt 1, 2 oder 3 zurück
         out.Feder(i).val  = in.Feder.Betrag(i); 
      end

   %U --> Randbedingunen (Lager und vorgeschriebene Verschiebungen)
      %Randbedinungen die nur einen DOF betreffen (SPC=single-point constraint)
      out.SPC = struct('node',{},'dir',{},'val',{});
      nSPC = 0;
      for i = 1:out.Info.nLager
          flags = in.Lager.Lagerung(i,:);
          if iscell(flags), flags = flags{1}; end
          flags = logical(flags);
          t = find(flags, 1, 'first');          % one-hot index 1..6 (or [])
          switch t
              case 1 % voll eingespannt
                  nSPC = nSPC + 3;
              case 2 % gelenkig
                  nSPC = nSPC + 2;
              case 3 % Rolllager, gehalten in y
                  nSPC = nSPC + 1;
              case 4 % Rolllager, gehalten in x
                  nSPC = nSPC + 1;
              case 5 % Gleitlager, gehalten in y
                  nSPC = nSPC + 2;
              case 6 % Gleitlager, gehalten in x
                  nSPC = nSPC + 2;
              otherwise
                  % no/invalid type -> zero added; validator will complain later
          end
      end
      out.SPC(nSPC).node = []; out.SPC(nSPC).dir = []; out.SPC(nSPC).val = [];

      Idx = 1;
      for i = 1:out.Info.nLager
          node  = in.Lager.Knoten(i);
          flags = in.Lager.Lagerung(i,:);
          if iscell(flags), flags = flags{1}; end
          flags = logical(flags);
          t = find(flags, 1, 'first');          % one-hot type
    
          switch t
              case 1 % voll eingespannt -> 1,2,3
                  out.SPC(Idx  ).node = node; out.SPC(Idx  ).dir = 1; out.SPC(Idx  ).val = 0;
                  out.SPC(Idx+1).node = node; out.SPC(Idx+1).dir = 2; out.SPC(Idx+1).val = 0;
                  out.SPC(Idx+2).node = node; out.SPC(Idx+2).dir = 3; out.SPC(Idx+2).val = 0;
                  Idx = Idx + 3;
    
              case 2 % gelenkig -> 1,2
                  out.SPC(Idx  ).node = node; out.SPC(Idx  ).dir = 1; out.SPC(Idx  ).val = 0;
                  out.SPC(Idx+1).node = node; out.SPC(Idx+1).dir = 2; out.SPC(Idx+1).val = 0;
                  Idx = Idx + 2;
    
              case 3 % Rollenlager, gehalten in y -> 2
                  out.SPC(Idx).node = node; out.SPC(Idx).dir = 2; out.SPC(Idx).val = 0;
                  Idx = Idx + 1;
    
              case 4 % Rollenlager, gehalten in x -> 1
                  out.SPC(Idx).node = node; out.SPC(Idx).dir = 1; out.SPC(Idx).val = 0;
                  Idx = Idx + 1;
    
              case 5 % Gleitlager, gehalten in y -> 2,3
                  out.SPC(Idx  ).node = node; out.SPC(Idx  ).dir = 2; out.SPC(Idx  ).val = 0;
                  out.SPC(Idx+1).node = node; out.SPC(Idx+1).dir = 3; out.SPC(Idx+1).val = 0;
                  Idx = Idx + 2;
    
              case 6 % Gleitlager, gehalten in x -> 1,3
                  out.SPC(Idx  ).node = node; out.SPC(Idx  ).dir = 1; out.SPC(Idx  ).val = 0;
                  out.SPC(Idx+1).node = node; out.SPC(Idx+1).dir = 3; out.SPC(Idx+1).val = 0;
                  Idx = Idx + 2;
    
              otherwise
                % no/invalid type: skip (validation will flag it)
          end
      end
    
      %Vorgeschriebene Verschiebungen anhängen
      start = Idx - 1;
      for i = 1:out.Info.nZwaengungen
          out.SPC(start + i).node = in.VorgeschriebeneVerschiebung.Knoten(i);
          out.SPC(start + i).dir  = in.VorgeschriebeneVerschiebung.Richtung(i);
          out.SPC(start + i).val  = in.VorgeschriebeneVerschiebung.Wert(i);
      end
      
      %Randbedinungen die mehrere DOF betreffen (MPC=multi-point constraint)
         %noch leer. weil wir das erst später einführen werden
   
   %F --> Lasten
      %Knotenlasten
      out.KnotenLast = struct('node',{},'dir',{},'val',{});
      nKnotenLasten = out.Info.nKnotenLasten;
      for i=1:nKnotenLasten
         out.KnotenLast(i).node = in.KnotenLasten.Knoten(i); %Knoten auf dem die Kraft angreift
         out.KnotenLast(i).dir  = in.KnotenLasten.Richtung(i); %Richtung der angreifenden Kraft
         out.KnotenLast(i).val  = in.KnotenLasten.Wert(i); %Wert der angreifenden Kraft   
      end
      
      %Stablasten
      out.StabLast = struct('stab',{},'dir',{},'val',{},'sDist',{},'eDist',{},'typ',{});
      nStabLastenKonzentriert = out.Info.nStabLastenKonzentriert;
      for i=1:nStabLastenKonzentriert
         out.StabLast(i).stab  = in.StabLasten_konzentriert.Stab(i);
         out.StabLast(i).dir   = in.StabLasten_konzentriert.Richtung(i);
         out.StabLast(i).val   = in.StabLasten_konzentriert.Wert(i);
         out.StabLast(i).sDist = in.StabLasten_konzentriert.StartPosition(i);
         out.StabLast(i).eDist = [];
         out.StabLast(i).typ   = out.StabLast(i).dir; %gibt 1, 2, oder 3 zurück
      end
      
      nStabLastenVerteilt = out.Info.nStabLastenVerteilt;
      for i=1:nStabLastenVerteilt
         out.StabLast(i+nStabLastenKonzentriert).stab  = in.StabLasten_verteilt.Stab(i);
         out.StabLast(i+nStabLastenKonzentriert).dir   = in.StabLasten_verteilt.Richtung(i);
         out.StabLast(i+nStabLastenKonzentriert).val   = in.StabLasten_verteilt.Wert(i);
         out.StabLast(i+nStabLastenKonzentriert).sDist = in.StabLasten_verteilt.StartPosition(i);
         out.StabLast(i+nStabLastenKonzentriert).eDist = in.StabLasten_verteilt.EndPosition(i);
         out.StabLast(i+nStabLastenKonzentriert).typ   = out.StabLast(i+nStabLastenKonzentriert).dir + out.Info.nKnotenDOF; %gibt 4, 5, oder 6 zurück
      end      

  %Einflusslinie
    out.gew_output = in.gew_output(1);
    out.Einflusslinie = struct();
    out.Einflusslinie = table2struct(in.Einflusslinie);

    if out.gew_output == 2 && out.Einflusslinie.TypEL ~= 4
        if out.Einflusslinie.Stelle == 0
            out.Einflusslinie.Stelle = 0.001;
        elseif out.Einflusslinie.Stelle == 1
            out.Einflusslinie.Stelle = 0.999;
        end
    end

    % Statische Kondensation (optional vom Benutzer)
    if isfield(in,'Kondensation') && ~isempty(in.Kondensation)
        out.Kondensation = in.Kondensation;   
    else
        out.Kondensation = [];
    end

    

end

