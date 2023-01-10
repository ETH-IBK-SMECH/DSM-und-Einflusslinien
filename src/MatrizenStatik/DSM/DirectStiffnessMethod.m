function [out] = DirectStiffnessMethod(analysisModel)
   %{
   in = Model.Analyse._
   out = in (weil Matlab keine Pointer bzw. kein pass-by-reference unterstützt)
   %}

%% Clean up nicht nötig da input bereinigt

%% Alias
   [Knoten, Stab, Teilsystem, Feder, KnotenLast, StabLast, SPC, Info, gew_output, Einflusslinie] = extractFields(analysisModel);

%% Parameter
   %mehrheitlich bereits abgedeckt von Info._
   Info.nSPC = size(SPC,2);
   Info.nKnoten = size(Knoten,2);
   Info.nStaebe = size(Stab,2);
      
      
%% Teilsysteme (Optional, d.h., nicht für die Präsentation umzusetzen!)
   %Stäbe markieren welche als Teilsystem wirken (Stab(i).inTeilSys=true)
      %für den Start nehmen wir an, dass keine Teilsysteme vorhanden sind
      for i=1:Info.nStaebe
         Stab(i).inTeilSys = false;
      end    
      
      for i=1:Info.nTeilsys
         Staebe = Teilsystem(i).BeteiligteStaebe;
         KnotenDesTeilSys = zeros(length(Teilsystem(i).BeteiligteStaebe),1);

         for j=1:length(Staebe)
            StabIdx = Staebe(j);
            KnotenDesTeilSys(j*2-1) = Stab(StabIdx).sNode;
            KnotenDesTeilSys(j*2)   = Stab(StabIdx).eNode;
            Stab(StabIdx).inTeilSys = true;
         end

         Teilsystem(i).KnotenDesTS = KnotenDesTeilSys;  %Knoten in Reihenfolge der Stabrichtungen
         Teilsystem(i).KnotenTSgeordnet = getKnotenTS(KnotenDesTeilSys,length(Staebe));

      end                 

      
%% Vorhandene StabDOF
   
   %für alle Stäbe   
   for i = 1:Info.nStaebe
      %Startannahme: alle DOF vorhanden
      vorhandeneStabDOF = true(1,6);

      %falls Stabendgelenke, dann existiert Widerstand in DOF-Richtung nicht
      vorhandeneStabDOF(Stab(i).sRelease) = false;
      vorhandeneStabDOF(Stab(i).eRelease + Info.nKnotenDOF) = false;
      
  
      %Jedem Stab die dazugehörige DOF-Maske zuweisen 
      Stab(i).vorhandeneDOF = vorhandeneStabDOF;       
   end

   

   %% Stabsteifigkeiten
   %lokales Koordinatensystem
   for i = 1:Info.nStaebe
       sX = Knoten(Stab(i).sNode).x; eX = Knoten(Stab(i).eNode).x; %x-Koordinate für Start- und Endknoten
       sY = Knoten(Stab(i).sNode).y; eY = Knoten(Stab(i).eNode).y; %y-Koordinate für Start- und Endknoten
       Stab(i).L = sqrt( (eX - sX)^2 + (eY - sY)^2 ); %Stablänge
       Stab(i).c = (eX - sX) / Stab(i).L; %Stabwinkel cosinus
       Stab(i).s = (eY - sY) / Stab(i).L; %Stabwinkel sinus
       Stab(i).R = getR(Stab(i).c, Stab(i).s); %Rotationsmatrix
       
       Stab(i).k_loc_v = getK(Stab(i).E, Stab(i).A, Stab(i).Iy, Stab(i).L);
       Stab(i).k_loc   = kondensiereK(Stab(i).k_loc_v, Stab(i).vorhandeneDOF);
       Stab(i).k_glob  = rotiereLocalToGlobal_K(Stab(i).k_loc, Stab(i).R);

       %leere P_int erstellen für jeden Stab (für p_int am schluss)
       Stab(i).P_int = zeros(6,1);
   end           

   
%% ACTIVE DOFS
    %activedofs vo stäb je nach rotation
    %activedof dür federe usglöst
    %när richtig zuewiise
    %bi 90/270 grad dr richtig ziile wächsle

    isActiveDOF = false(1,Info.nKnoten * Info.nKnotenDOF); 


    %activeStabDOF für jeden Stab -> wird auch für Kondensation von TS benötigt
    for i = 1:Info.nStaebe
        Stab(i).activeStabDOF = Stab(i).vorhandeneDOF;
        diff = Stab(i).c - Stab(i).s; %um dof 1,2 zu aktivieren für rotiertes (ausser specialcases)
        if ~isequal(abs(diff),1)
            Stab(i).activeStabDOF([1,2,4,5]) = true;
        end

        if Stab(i).c==0 && abs(Stab(i).s)==1
            Stab(i).activeStabDOF([1,2,4,5]) = Stab(i).activeStabDOF([2,1,5,4]);
        end

    end


    %TeilSys kondensieren mithilfe globalen stabilen Steifigkeitsmatrizen
    for i = 1:Info.nTeilsys
        [Teilsystem(i).activeTSDOFextern, Teilsystem(i).k_glob, Teilsystem(i).isActiveTSDOF, Teilsystem(i).K_sys_TS] = kondensiereTS(Teilsystem(i), Stab);
        %bruchts k_loc überhaupt? vilech für lehrzwecke?
        %c mit snode & enode 
        %s
        %R*K_glob*R' = K_loc
    end


    %Teilsys DOFs aktivieren 
    for i = 1:Info.nTeilsys
        sNodeTS = Teilsystem(i).KnotenTSgeordnet(1);
        sNodesTS = [sNodeTS*3-2:sNodeTS*3];
        eNodeTS = Teilsystem(i).KnotenTSgeordnet(end);
        eNodesTS = [eNodeTS*3-2:eNodeTS*3];
        nodes = [sNodesTS,eNodesTS];
        activeTSdof = nodes(Teilsystem(i).activeTSDOFextern);
        isActiveDOF(activeTSdof) = true;
    end

    %DOFs aktivieren für Stäbe die nicht in einem TS sind
    for i = find(~[Stab.inTeilSys])

        sNodeDOF = Stab(i).sNode*3-2:Stab(i).sNode*3;
        eNodeDOF = Stab(i).eNode*3-2:Stab(i).eNode*3;
        stabDOF = [sNodeDOF, eNodeDOF];

        active = stabDOF(Stab(i).activeStabDOF); %filtert die wirklich aktiven Dofs nach globale Dof nummerierung
        isActiveDOF(active) = true;
    end


    %überprüfen, ob Feder DOF aktiviert
    for i = 1:Info.nFedern
       IdxDOF = (Feder(i).node-1)*3 + Feder(i).dir;
       isActiveDOF(IdxDOF) = true;
    end

    %DOF-Nummerierung im globalen System
    nDOF = sum(isActiveDOF);
    DOF  = zeros(1,length(isActiveDOF));
    DOF(isActiveDOF) = 1:nDOF;

    %activeDOF auf Stab-Stufe (den StabDOFs werden Indices zugeordnet)
    for i=find(~[Stab.inTeilSys])
      Stab(i).DOF = zeros(1,sum(Stab(i).activeStabDOF)); %erstellt Vektor mit Grösse der aktiven DOF's
      sNodeDOF = DOF(Stab(i).sNode*3-2:Stab(i).sNode*3);
      eNodeDOF = DOF(Stab(i).eNode*3-2:Stab(i).eNode*3);
      stabDOF = [sNodeDOF, eNodeDOF];
      Stab(i).DOF = stabDOF(Stab(i).activeStabDOF);
    end


    %DOFs zueordne uf Teilsystem-Stufe
    for i = 1:Info.nTeilsys
        Teilsystem(i).DOF = zeros(1,sum(Teilsystem(i).activeTSDOFextern));
        TSStartEnde = [Teilsystem(i).KnotenTSgeordnet(1),Teilsystem(i).KnotenTSgeordnet(end)];
        sNodesTS = DOF(TSStartEnde(1)*3-2:TSStartEnde(1)*3);
        eNodesTS = DOF(TSStartEnde(2)*3-2:TSStartEnde(2)*3);
        TSDOF = [sNodesTS,eNodesTS];
        Teilsystem(i).DOF = TSDOF(Teilsystem(i).activeTSDOFextern);
    end


    %Feder wird neues Indice zugeordnet
    for i = 1:Info.nFedern
       Feder(i).DOF = DOF((Feder(i).node-1)*3 + Feder(i).dir);
    end

    %KnotenLast wird Indice zugeordnet
    for i = 1:Info.nKnotenLasten
       KnotenLast(i).DOF = DOF((KnotenLast(i).node-1)*3 + KnotenLast(i).dir);
    end


   
%% Systemgrössen allozieren
    K_sys        = zeros(nDOF, nDOF);
    F_sys_Knoten = zeros(nDOF,1); 
    F_sys_Stab   = zeros(nDOF,1);

      
%% Stablasten
    for i = 1:Info.nStabLasten
        IdxStab = StabLast(i).stab;
        StabLast(i).f_loc = getF(StabLast(i), Stab(IdxStab).L);
        StabLast(i).f_loc = kondensiereF(StabLast(i).f_loc, Stab(IdxStab).k_loc_v, Stab(IdxStab).vorhandeneDOF);
        Stab(IdxStab).P_int = Stab(IdxStab).P_int + StabLast(i).f_loc;

        StabLast(i).f_glob = rotiereLocalToGlobal_F(StabLast(i).f_loc, Stab(IdxStab).R);
    end

%% Knotenlasten
   %Hier wird nichts gemacht --> direkt einsetzen in F_sys_Knoten im assembly-Schritt
   
%% Stablasten für TS allozieren
    %nur Knotenlasten durchgehen wo DOF = 0 ist

    for i = 1:Info.nTeilsys
        Teilsystem(i).F_TS = zeros(length(Teilsystem(i).isActiveTSDOF),1);
        Staebe = Teilsystem(i).BeteiligteStaebe; % [3,2,1]
        Knoten = Teilsystem(i).KnotenTSgeordnet; % [2 3 5 4]
        alleKnoten = Teilsystem(i).KnotenDesTS; % [3 2 5 3 4 5]

        %Stablasten
        for j = 1:Info.nStabLasten
            IdxS = find(StabLast(j).stab == Staebe);

            %achtung: stablasten abziehen, da F_sys = F_Knoten - F_Stab
            if ~isempty(IdxS)
                %sNode zuewiise
                sNodeIdx = find(alleKnoten(IdxS*2-1) == Knoten);
                snodesF = sNodeIdx*3-2:sNodeIdx*3;
                Teilsystem(i).F_TS(snodesF) = Teilsystem(i).F_TS(snodesF) - StabLast(j).f_glob(1:3);
                %eNode zuewiise
                eNodeIdx = find(alleKnoten(IdxS*2) == Knoten);
                enodesF = eNodeIdx*3-2:eNodeIdx*3;
                Teilsystem(i).F_TS(enodesF) = Teilsystem(i).F_TS(enodesF) - StabLast(j).f_glob(4:6);
            end
        end
            
        %Knotenlasten
        %KL für die DOF = 0 und element von Knoten
        for z = 1:Info.nKnotenLasten
            IdxN = find(KnotenLast(i).node == Knoten);
            if ~isempty(IdxN) && KnotenLast(z).DOF == 0
                IdxNdir = (IdxN-1)*3 + KnotenLast(z).dir;
                Teilsystem(i).F_TS(IdxNdir) = Teilsystem(i).F_TS(IdxNdir) + KnotenLast(z).val;
            end
        end
        disp(Teilsystem(1))
        %F_TS kondensieren
        Teilsystem(i).F_TS_kond = kondensiereFTS(Teilsystem(i));

    end

%% Assembly (alle releventen _.glob --> _.sys)
   %Stäbe

   %Teilsys für jede k_sys addiere und när no bi laschte
   %Achtung bi F_knoten -> mit .dof ~= 0 arbeite!!

   for i = find(~[Stab.inTeilSys])
       K_sys(Stab(i).DOF, Stab(i).DOF) = K_sys(Stab(i).DOF, Stab(i).DOF) + Stab(i).k_glob(Stab(i).activeStabDOF,Stab(i).activeStabDOF);
   end

   for i = 1:Info.nTeilsys
       K_sys(Teilsystem(i).DOF,Teilsystem(i).DOF) = K_sys(Teilsystem(i).DOF,Teilsystem(i).DOF) + Teilsystem(i).k_glob(Teilsystem(i).activeTSDOFextern,Teilsystem(i).activeTSDOFextern);
   end
      
   %Federn
   for i = 1:Info.nFedern
       K_sys(Feder(i).DOF,Feder(i).DOF) = K_sys(Feder(i).DOF,Feder(i).DOF) + Feder(i).val;
   end

   
   %Lasten
   %Stablasten F_sys_Stab
   for i = 1:Info.nStabLasten
       StabIndx = StabLast(i).stab;
       if ~Stab(StabIndx).inTeilSys
           F_sys_Stab(Stab(StabIndx).DOF) = F_sys_Stab(Stab(StabIndx).DOF) + StabLast(i).f_glob(Stab(StabIndx).activeStabDOF);
       end
   end
   
   %Knotenlasten durch direktes Einsetzen in F_sys_Knoten
   for i = 1:Info.nKnotenLasten
       if KnotenLast(i).DOF ~= 0
           F_sys_Knoten(KnotenLast(i).DOF) = F_sys_Knoten(KnotenLast(i).DOF) + KnotenLast(i).val;
       end
   end

   %System = Knoten-Stab
   F_sys = F_sys_Knoten - F_sys_Stab;

   %F_TS_kond dazuzählen
   for i = 1:Info.nTeilsys
       F_sys(Teilsystem(i).DOF) = F_sys(Teilsystem(i).DOF) + Teilsystem(i).F_TS_kond(Teilsystem(i).activeTSDOFextern);
   end

%% Randbedingungen
   %einfache Randbedingungen (als Funktion eines DOF wie z.B. bei Lager und Zwängungen)
   
   isVVDOF = false(1, nDOF);

   %SPC DOFs zuewiise
   for i = 1:Info.nSPC
       SPCIdx = (SPC(i).node-1)*3 + SPC(i).dir;
       if(~isequal(DOF(SPCIdx),0))
           SPC(i).DOF = DOF(SPCIdx);
       end
       isVVDOF(SPC(i).DOF) = true;
   end

   
   %komplizierte Randbedingunen wie z.B.
      %- die multi-point constraints bei der Einflusslinie
      %- dehnstarrr und/oder biegesteif in der numerischen Analyse

%% Kondensation
    
    U_sys = zeros(nDOF,1);

    for i = 1:Info.nSPC
        U_sys(SPC(i).DOF) = U_sys(SPC(i).DOF) + SPC(i).val;
    end


    kond.s = isVVDOF; %s for strained DOF / vorgeschriebene Verschiebung
    kond.f = ~isVVDOF; %f for free DOF
    kond.DOF = find(~isVVDOF); % weli DOFs no do si auso für weli mir u_sys bechöme

    %Lagrange Multiplier Adjunction für Einflusslinie
    if gew_output == 2 && Einflusslinie.TypEL ~=4
        U_sys(end+3) = 0;

        sizeK = size(K_sys,2);
        A1 = zeros(3,sizeK-6);
        A2 = [1,0,0,-1, 0, 0;
              0,1,0, 0,-1, 0;
              0,0,1, 0, 0,-1] ;
        A = [A1,A2];

        F_sys2 = zeros(3,1);
        F_sys2(Einflusslinie.TypEL) = -1;
        if Einflusslinie.TypEL == 2; F_sys2(Einflusslinie.TypEL) = 1; end

        F_sys = [F_sys; F_sys2];

        K_sys = [K_sys, A';
                 A, zeros(3)];

        kond.s(end+1:end+3) = false;
        kond.f(end+1:end+3) = true;
    end


    %K_ff \ f_f_kond
    %f_f_kond = f_f - K_fs*u_s
    kond.F_sys_f_kond = F_sys(kond.f) - K_sys(kond.f,kond.s)*U_sys(kond.s);
    kond.K_sys_ff = K_sys(kond.f,kond.f);

    
%% Lösen
   U_sys_kond = kond.K_sys_ff \ kond.F_sys_f_kond;

   if gew_output == 2 && Einflusslinie.TypEL ~=4
       U_sys_kond = U_sys_kond(1:end-3);
   end

   U_sys(kond.DOF) = U_sys(kond.DOF) + U_sys_kond;
      
   
   %Stabquerschnittseigenschaften erzwingen wie z.B.
      %- dehnstarrr und/oder biegesteif in der symbolischen Analyse (limit as EA-->inf)
      %- siehe hierzu https://ch.mathworks.com/help/symbolic/sym.limit.html
   
%% Lösungzuweisen
   %z.B. indem bei den Teilsystemen die internen DOF errechnet werden (Umkehr des Kondensieren der internen DOF)
   
   for i = find(~[Stab.inTeilSys])
       %Stab(i).u_glob = U_sys(Stab(i).DOF);
       %eso oder mit zeros initiere und mache
       Stab(i).u_glob = zeros(6,1);
       Stab(i).u_glob(Stab(i).activeStabDOF) = Stab(i).u_glob(Stab(i).activeStabDOF) + U_sys(Stab(i).DOF);
       Stab(i).u_loc = rotiereGlobalToLocal_u(Stab(i).u_glob, Stab(i).R);

   end

   for i = 1:Info.nTeilsys
       Teilsystem(i).u_glob = zeros(6,1);
       Teilsystem(i).u_glob(Teilsystem(i).activeTSDOFextern) = Teilsystem(i).u_glob(Teilsystem(i).activeTSDOFextern) + U_sys(Teilsystem(i).DOF);
   end

   %do u_i usefinge wider mit zruggrächne
   %när u_i de Stäb zuewiise und SK usefinge


   
   
%% Nachrechnung
   %Stabendkräfte

   for i = find(~[Stab.inTeilSys])
       %+F_sys_Stab die richtige DOFs
       Stab(i).q_loc = Stab(i).k_loc * Stab(i).u_loc + Stab(i).P_int;
       Stab(i).q_glob = rotiereLocalToGlobal_F(Stab(i).q_loc, Stab(i).R);
       Stab(i).q_loc_sk = Stab(i).q_loc .* [-1;1;-1;1;-1;1];
   end

   %Auflagerkräfte

   SummeInDOF = zeros(nDOF,1);

   for i = 1:Info.nStaebe
       SummeInDOF(Stab(i).DOF) = SummeInDOF(Stab(i).DOF) + Stab(i).q_glob(Stab(i).activeStabDOF);
   end

   for i = 1:Info.nKnotenLasten
       SummeInDOF(KnotenLast(i).DOF) = SummeInDOF(KnotenLast(i).DOF) - KnotenLast(i).val;
   end

   for i = 1:Info.nSPC
       SPC(i).Reaktion = SummeInDOF(SPC(i).DOF);
   end

   for i = 1:Info.nFedern
       Feder(i).Reaktion = SummeInDOF(Feder(i).DOF);
   end

   %Verdrehungen an einem Momentengelenk

   for i = 1:Info.nStaebe
       Stab(i).u_loc = VerdrehungMomentengelenk(Stab(i).u_loc,Stab(i).L,Stab(i).vorhandeneDOF);
   end

      
%% retourniere Model
   out = copyFields(Knoten, Stab, Teilsystem, Feder, KnotenLast, StabLast, SPC, Info, gew_output, ...
                    K_sys, F_sys, F_sys_Knoten, F_sys_Stab, kond, U_sys, DOF);
end

