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

   if ~isfield(Info,'nTeilsys'),       Info.nTeilsys       = numel(Teilsystem);     end
   if ~isfield(Info,'nFedern'),        Info.nFedern        = numel(Feder);          end
   if ~isfield(Info,'nKnotenLasten'),  Info.nKnotenLasten  = numel(KnotenLast);     end
   if ~isfield(Info,'nStabLasten'),    Info.nStabLasten    = numel(StabLast);       end
      
%% Teilsysteme (Optional, d.h., nicht für die Präsentation umzusetzen!)
   %Stäbe markieren welche als Teilsystem wirken (Stab(i).inTeilSys=true)
      %für den Start nehmen wir an, dass keine Teilsysteme vorhanden sind
      for i=1:Info.nStaebe
         Stab(i).inTeilSys = false;
      end    
      
      for i=1:Info.nTeilsys
            Staebe = Teilsystem(i).BeteiligteStaebe;
            nS = length(Teilsystem(i).BeteiligteStaebe);
            KnotenDesTeilSys = zeros(2*nS, 1);
            for j = 1:nS
                StabIdx = Staebe(j);
                KnotenDesTeilSys(2*j-1) = Stab(StabIdx).sNode;
                KnotenDesTeilSys(2*j)   = Stab(StabIdx).eNode;
                Stab(StabIdx).inTeilSys = true;
            end
    
            Teilsystem(i).KnotenDesTS = KnotenDesTeilSys;  %Knoten in Reihenfolge der Stabrichtungen
            Teilsystem(i).KnotenTSgeordnet = getKnotenTS(KnotenDesTeilSys,length(Staebe));

      end                 
      
%% Vorhandene StabDOF

    if ~isfield(Info,'nKnotenDOF') || isempty(Info.nKnotenDOF)
        Info.nKnotenDOF = 3;
    end

    nkd = Info.nKnotenDOF;      % DOFs per node
    n6 = 2*nkd;                 % DOFs for 2-node member
    nodeDOFs = @(n) (n-1)*nkd + (1:nkd);
    pairDOFs = @(s,e) [nodeDOFs(s), nodeDOFs(e)];
    firstHalf  = 1:nkd;
    secondHalf = nkd + (1:nkd);
    transIdx = [1, 2, nkd+1, nkd+2];

   %für alle Stäbe   
   for i = 1:Info.nStaebe
      %Startannahme: alle DOF vorhanden
      vorhandeneStabDOF = true(1,n6);

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
       [Stab(i).k_loc, ~] = condensation(Stab(i).k_loc_v, [], Stab(i).vorhandeneDOF, 'preserve_size', true);
       Stab(i).k_glob  = rotiereLocalToGlobal_K(Stab(i).k_loc, Stab(i).R);

       %leere P_int erstellen für jeden Stab (für p_int am schluss)
       Stab(i).P_int = zeros(n6,1);
   end           

   
%% ACTIVE DOFS
    %activedofs vo stäb je nach rotation
    %activedof dür federe usglöst
    %när richtig zuewiise
    %bi 90/270 grad dr richtig ziile wächsle

    isActiveDOF = false(1,Info.nKnoten * Info.nKnotenDOF); 

    %activeStabDOF für jeden Stab -> wird auch für Kondensation von TS benötigt
    for i = 1:Info.nStaebe
        % Start mit vorhandenen DOF (Freigaben etc. sind schon berücksichtigt)
        Stab(i).activeStabDOF = Stab(i).vorhandeneDOF;
    
        % Orientierung robust bestimmen
        [isH, isV] = isOrientation(Stab(i).c, Stab(i).s);
    
        if isV
            % Vertikal: x/y vertauschen (auch an der Endknoten-Seite)
            Stab(i).activeStabDOF(transIdx) = Stab(i).activeStabDOF(transIdx([2,1,4,3]));
        elseif ~isH
            % Geneigt: beide Translationsfreiheiten aktivieren
            Stab(i).activeStabDOF(transIdx) = true;
        end
    end


    %TeilSys kondensieren mithilfe globalen stabilen Steifigkeitsmatrizen
    for i = 1:Info.nTeilsys
        [Teilsystem(i).k_glob, Teilsystem(i).F_TS_kond, Teilsystem(i).activeTSDOFextern, Teilsystem(i).isActiveTSDOF, Teilsystem(i).K_sys_TS] ...
        = tsAssembleAndCondense(Teilsystem(i), Stab, nkd);
    end

    %Teilsys DOFs aktivieren 
    for i = 1:Info.nTeilsys
        sNodeTS = Teilsystem(i).KnotenTSgeordnet(1);
        eNodeTS = Teilsystem(i).KnotenTSgeordnet(end);
        nodes = pairDOFs(sNodeTS, eNodeTS);
        activeTSdof = nodes(Teilsystem(i).activeTSDOFextern);
        isActiveDOF = setFlagsIfValid(activeTSdof, isActiveDOF);
    end

    %DOFs aktivieren für Stäbe die nicht in einem TS sind
    for i = find(~[Stab.inTeilSys])
        stabDOF = pairDOFs(Stab(i).sNode, Stab(i).eNode);
        active = stabDOF(Stab(i).activeStabDOF); %filtert die wirklich aktiven Dofs nach globale Dof nummerierung
        isActiveDOF = setFlagsIfValid(active, isActiveDOF);
    end


    %überprüfen, ob Feder DOF aktiviert
    for i = 1:Info.nFedern
       IdxDOF = (Feder(i).node-1)*nkd + Feder(i).dir;
       isActiveDOF = setFlagsIfValid(IdxDOF, isActiveDOF);
    end

    %DOF-Nummerierung im globalen System
    nDOF = sum(isActiveDOF);
    DOF  = zeros(1,length(isActiveDOF));
    DOF(isActiveDOF) = 1:nDOF;

    %activeDOF auf Stab-Stufe (den StabDOFs werden Indices zugeordnet)
    for i=find(~[Stab.inTeilSys])
        loc6 = pairDOFs(Stab(i).sNode, Stab(i).eNode);
        glob6 = arrayfun(@(idx) safeDOF(idx, DOF), loc6);
        Stab(i).DOF = glob6(Stab(i).activeStabDOF);
    end


    %DOFs zueordne uf Teilsystem-Stufe
    for i = 1:Info.nTeilsys
        sNodeTS = Teilsystem(i).KnotenTSgeordnet(1);
        eNodeTS = Teilsystem(i).KnotenTSgeordnet(end);
        loc6  = pairDOFs(sNodeTS, eNodeTS);
        glob6 = arrayfun(@(idx) safeDOF(idx, DOF), loc6);
        Teilsystem(i).DOF = glob6(Teilsystem(i).activeTSDOFextern);
    end


    %Feder wird neues Indice zugeordnet
    for i = 1:Info.nFedern
       Feder(i).DOF = safeDOF(dofIndex(Feder(i).node, Feder(i).dir), DOF);
    end

    %KnotenLast wird Indice zugeordnet
    for i = 1:Info.nKnotenLasten
       KnotenLast(i).DOF = safeDOF(dofIndex(KnotenLast(i).node, KnotenLast(i).dir), DOF);
    end


   
%% Systemgrössen allozieren
    K_sys        = sparse(nDOF, nDOF);
    F_sys_Knoten = sparse(nDOF,1); 
    F_sys_Stab   = sparse(nDOF,1);

      
%% Stablasten
    for i = 1:Info.nStabLasten
        IdxStab = StabLast(i).stab;
        StabLast(i).f_loc = getF(StabLast(i), Stab(IdxStab).L);
        [~, StabLast(i).f_loc] = condensation(Stab(IdxStab).k_loc_v, StabLast(i).f_loc, Stab(IdxStab).vorhandeneDOF, 'preserve_size', true);
        Stab(IdxStab).P_int = Stab(IdxStab).P_int + StabLast(i).f_loc;
        StabLast(i).f_glob = rotiereLocalToGlobal_F(StabLast(i).f_loc, Stab(IdxStab).R);
    end

%% Knotenlasten
   %Hier wird nichts gemacht --> direkt einsetzen in F_sys_Knoten im assembly-Schritt
   
%% Stablasten für TS allozieren
    %nur Knotenlasten durchgehen wo DOF = 0 ist

    for i = 1:Info.nTeilsys
        % Full DOF vector for all TS nodes in order
        KnotenTS = Teilsystem(i).KnotenTSgeordnet;
        nTSNodes = numel(KnotenTS);
        Teilsystem(i).F_TS = zeros(nTSNodes*nkd, 1);

        %Stablasten
        StaebeTS = Teilsystem(i).BeteiligteStaebe;
        for j = 1:Info.nStabLasten
            IdxStab = StabLast(j).stab;
            if any(IdxStab == StaebeTS)
                %Global end nodes of this member
                sNode = Stab(IdxStab).sNode;
                eNode = Stab(IdxStab).eNode;
    
                %Positions of these nodes inside the ordered TS node list
                sPos = find(KnotenTS == sNode, 1, 'first');
                ePos = find(KnotenTS == eNode, 1, 'first');
                if isempty(sPos) || isempty(ePos), continue; end  % safety
    
                sIdx = (sPos-1)*nkd + (firstHalf);
                eIdx = (ePos-1)*nkd + (firstHalf);
    
                %F_sys = F_Knoten - F_Stab
                Teilsystem(i).F_TS(sIdx) = Teilsystem(i).F_TS(sIdx) - StabLast(j).f_glob(firstHalf);
                Teilsystem(i).F_TS(eIdx) = Teilsystem(i).F_TS(eIdx) - StabLast(j).f_glob(secondHalf);
            end
        end
            
        %Knotenlasten
        %KL für die DOF = 0 und element von Knoten
        for z = 1:Info.nKnotenLasten
            if KnotenLast(z).DOF ~= 0, continue; end
            node = KnotenLast(z).node;
            pos  = find(KnotenTS == node, 1, 'first');
            if isempty(pos), continue; end
            gIdx = (pos-1)*nkd + KnotenLast(z).dir;
            if gIdx >= 1 && gIdx <= numel(Teilsystem(i).F_TS)
                Teilsystem(i).F_TS(gIdx) = Teilsystem(i).F_TS(gIdx) + KnotenLast(z).val;
            end
        end
        
        %F_TS kondensieren
        [~, Teilsystem(i).F_TS_kond] = tsAssembleAndCondense(Teilsystem(i), Stab, nkd);


    end

%% Assembly (alle releventen _.glob --> _.sys)
   %Stäbe

   %Teilsys für jede k_sys addiere und när no bi laschte
   %Achtung bi F_knoten -> mit .dof ~= 0 arbeite!

   idxFreeStab = find(~[Stab.inTeilSys]);    
    for ii = 1:numel(idxFreeStab)
        i   = idxFreeStab(ii);
        d   = Stab(i).DOF;
        keep = d ~= 0;
        if any(keep)
            a6  = find(Stab(i).activeStabDOF);
            a6  = a6(keep);
            d   = d(keep);
            Kb  = Stab(i).k_glob(a6, a6);
    
            % add local block as a tiny sparse
            [rr, cc] = ndgrid(d, d);
            K_sys = K_sys + sparse(rr(:), cc(:), Kb(:), nDOF, nDOF);
        end
    end

    for i = 1:Info.nTeilsys
        d   = Teilsystem(i).DOF;
        keep = d ~= 0;
        if any(keep)
            a6  = find(Teilsystem(i).activeTSDOFextern);
            a6  = a6(keep);
            d   = d(keep);
            Kb  = Teilsystem(i).k_glob(a6, a6);
    
            [rr, cc] = ndgrid(d, d);
            K_sys = K_sys + sparse(rr(:), cc(:), Kb(:), nDOF, nDOF);
        end
    end
      
   %Federn
    for i = 1:Info.nFedern
        g = Feder(i).DOF;
        if g ~= 0
            K_sys = K_sys + sparse(g, g, Feder(i).val, nDOF, nDOF); 
        end
    end

   
   %Lasten
   %Stablasten F_sys_Stab
    F_sys = sparse(nDOF, 1);

    for i = 1:Info.nStabLasten
        sIdx = StabLast(i).stab;
        if ~Stab(sIdx).inTeilSys
            d   = Stab(sIdx).DOF;
            keep = d ~= 0;
            if any(keep)
                a6  = find(Stab(sIdx).activeStabDOF);
                a6  = a6(keep);
                d   = d(keep);
                fseg = StabLast(i).f_glob(a6);
                F_sys = F_sys - sparse(d, 1, fseg, nDOF, 1);
                F_sys_Stab   = F_sys_Stab + sparse(d, 1, fseg, nDOF, 1);
            end
        end
    end
   
   %Knotenlasten durch direktes Einsetzen in F_sys_Knoten
    for i = 1:Info.nKnotenLasten
        g = KnotenLast(i).DOF;
        if g ~= 0
            F_sys = F_sys + sparse(g, 1, KnotenLast(i).val, nDOF, 1);
            F_sys_Knoten = F_sys_Knoten + sparse(g, 1, KnotenLast(i).val, nDOF, 1); 
        end
    end

   %F_TS_kond dazuzählen
    for i = 1:Info.nTeilsys
        d   = Teilsystem(i).DOF;
        keep = d ~= 0;
        if any(keep)
            a6  = find(Teilsystem(i).activeTSDOFextern);
            a6  = a6(keep);
            d   = d(keep);
            fts = Teilsystem(i).F_TS_kond(a6);
            F_sys = F_sys + sparse(d, 1, fts, nDOF, 1);
        end
    end

%% Randbedingungen
   %einfache Randbedingungen (als Funktion eines DOF wie z.B. bei Lager und Zwängungen)
   
   isVVDOF = false(1, nDOF);

   % ensure SPC(i).DOF exists and starts at 0
   [SPC(1:Info.nSPC).DOF] = deal(0);

   %SPC DOFs zuewiise
   for i = 1:Info.nSPC
       if ~(isfinite(SPC(i).node) && SPC(i).node >= 1 && SPC(i).node <= Info.nKnoten), continue; end
       if ~(isfinite(SPC(i).dir)  && SPC(i).dir  >= 1 && SPC(i).dir <= nkd), continue; end

       localIdx = (SPC(i).node-1)*nkd + SPC(i).dir;

        g = safeDOF(localIdx, DOF);                               % global DOF
        SPC(i).DOF = g;
        isVVDOF = setFlagsIfValid(g, isVVDOF);
  
   end

   %komplizierte Randbedingunen wie z.B.
      %- die multi-point constraints bei der Einflusslinie
      %- dehnstarrr und/oder biegesteif in der numerischen Analyse

%% Kondensation
    
    U_sys = zeros(nDOF,1);

    for i = 1:Info.nSPC
        g = SPC(i).DOF;
        if g ~= 0
            U_sys(g) = U_sys(g) + SPC(i).val;
        end
    end


    kond.s = isVVDOF; %s for strained DOF / vorgeschriebene Verschiebung
    kond.f = ~isVVDOF; %f for free DOF
    kond.DOF = find(~isVVDOF); % weli DOFs no do si auso für weli mir u_sys bechöme

    %Lagrange Multiplier Adjunction für Einflusslinie
    if gew_output == 2 && Einflusslinie.TypEL ~=4
        U_sys(end+nkd) = 0;

        sizeK = size(K_sys,2);
        A1 = zeros(nkd,sizeK-n6);
        A2 = [1,0,0,-1, 0, 0;
              0,1,0, 0,-1, 0;
              0,0,1, 0, 0,-1] ;
        A = [A1,A2];

        F_sys2 = zeros(nkd,1);
        F_sys2(Einflusslinie.TypEL) = -1;
        if Einflusslinie.TypEL == 2; F_sys2(Einflusslinie.TypEL) = 1; end

        F_sys = [F_sys; F_sys2];

        K_sys = [K_sys, A';
                 A, zeros(nkd)];

        kond.s(end+1:end+nkd) = false;
        kond.f(end+1:end+nkd) = true;
    end


    %K_ff \ f_f_kond
    %f_f_kond = f_f - K_fs*u_s
    [kond.K_sys_ff, kond.F_sys_f_kond] = condensation(K_sys, F_sys, kond.f, 'preserve_size', false, 'known_ui', U_sys(kond.s));

    
%% Lösen
    try
        rc_est  = condest(kond.K_sys_ff);     % ~cond(A,1)
        rce     = 1/rc_est;                   % reciprocal condition estimate
        if ~isfinite(rce) || rce < 1e-12
            warning('Global stiffness is ill-conditioned (est. rcond=%g). Check supports/mechanisms.', rce);
        end
    
        U_sys_kond = kond.K_sys_ff \ kond.F_sys_f_kond;   % never use inv
    
        if any(~isfinite(U_sys_kond))
            error('Solution contains NaN/Inf entries (likely singular system).');
        end
    catch ME
        error('System solve failed: %s\nLikely causes: missing/collinear supports, duplicate nodes, rigid-body mode, or conflicting MPCs.', ME.message);
    end


   if gew_output == 2 && Einflusslinie.TypEL ~=4
       U_sys_kond = U_sys_kond(1:end-nkd);
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
        Stab(i).u_glob = zeros(n6,1);
        d   = Stab(i).DOF;
        a6  = find(Stab(i).activeStabDOF);
        keep = d ~= 0;
        if any(keep)
            Stab(i).u_glob(a6(keep)) = Stab(i).u_glob(a6(keep)) + U_sys(d(keep));
        end
        Stab(i).u_loc = rotiereGlobalToLocal_u(Stab(i).u_glob, Stab(i).R);

   end

   for i = 1:Info.nTeilsys
        Teilsystem(i).u_glob = zeros(n6,1);
        d   = Teilsystem(i).DOF;
        a6  = find(Teilsystem(i).activeTSDOFextern);
        keep = d ~= 0;
        if any(keep)
            Teilsystem(i).u_glob(a6(keep)) = Teilsystem(i).u_glob(a6(keep)) + U_sys(d(keep));
        end
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
    
   %Trims matrices (necessary for LM augmented case)
    K_phys   = K_sys(1:nDOF, 1:nDOF);
    F_k_phys = F_sys_Knoten(1:nDOF);
    F_s_phys = F_sys_Stab(1:nDOF);
    U_phys = U_sys(1:nDOF);
    
    R_sys = K_phys * U_phys - (F_k_phys - F_s_phys); %Internal - External forces

    % Assign to supports
    for i = 1:Info.nSPC
        g = SPC(i).DOF;
        if g ~= 0
            SPC(i).Reaktion = R_sys(g);
        else
            SPC(i).Reaktion = 0;
        end
    end
    
    % Assign to springs
    for i = 1:Info.nFedern
        g = Feder(i).DOF;
        if g ~= 0
            Feder(i).Reaktion = R_sys(g);
        else
            Feder(i).Reaktion = 0;
        end
    end

   %Verdrehungen an einem Momentengelenk

   for i = 1:Info.nStaebe
       Stab(i).u_loc = VerdrehungMomentengelenk(Stab(i).u_loc,Stab(i).L,Stab(i).vorhandeneDOF);
   end

      
%% retourniere Model
   out = copyFields(Knoten, Stab, Teilsystem, Feder, KnotenLast, StabLast, SPC, Info, gew_output, ...
                    K_sys, F_sys, F_sys_Knoten, F_sys_Stab, kond, U_sys, DOF);
end

