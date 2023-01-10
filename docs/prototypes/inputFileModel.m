function [Knoten, Staebe, Querschnitte, Teilsystem, Lager, Feder, VorgeschriebeneVerschiebung, ...
    KnotenLasten, StabLasten_konzentriert, StabLasten_verteilt] = inputFileModel()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EINGABE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nKnoten = 4;
    KnotenArr = [0,0; 0,10; 10,10; 10,0]; % x,y

    nStaebe = 3;
    StabArr = [1,2,1; 2,3,1; 3,4,2]; %StartKnoten, Endknoten, Querschnitt

    nQuerschnitte = 2;
    QuerschnitteArr = [1,1,1,0,0,0,1; 20,10,30,3,2,1,0];
    %Eintrag: [1.E, 2.A, 3.I, 4. GSA, 5. GSE, 6. dehnstarr, 7. biegesteif]
    %für GSA/GSE (GelenkStabAnfang/-Ende) gilt:
        %   0:  kein Gelenk
        %   1:  Normalkraftgelenk
        %   2:  Querkraftgelenk
        %   3:  Momentengelenk
    %für 6. & 7. gilt:
        %   0:  false
        %   1:  true

    TeilsystemeStruct = struct("BeteiligteStaebe", {[1,2], [1,2,3], [4,5]});
    %in den geschweiften Klammern die Teilsysteme als Array eingeben

    nLager = 3;
    nLagerTypen = 4;
    LagerArr = [1,3; 4,2; 5,4];
    %Eintrag: [1. Knoten, 2. Lagerung]
    %Für Lager gilt:
        %   1:  gelenkig gelagert
        %   2:  Einspannung
        %   3:  Rolllager horizontal
        %   4:  Rolllager vertikal

    nFeder = 3;
    nFederTypen = 3;
    FederArr = [1,1,0,1; 2,1,0,0; 4,0,0,1];
    %Eintrag: [1. Knoten, 2. Feder_x, 3. Feder_y, 4. Feder_z]
    %Für Federeinträge gilt:
        %   0:  false
        %   1:  true

    nVorgeschriebeneVerschiebung = 3;
    VorgeschriebeneVerschiebungArr = [1,3,1; 2,3,10; 3,2,-10];
    %Eintrag: [1. Knoten, 2. Richtung, 3. Wert]
    %Für Richtung gilt:
        %   1:  in x
        %   2:  in y
        %   3:  in z

    nKnotenLasten = 2;
    KnotenLastenArr = [2,2,10; 3,1,-20];
    %Eintrag: [1. Stab, 2. Richtung, 3. Wert]
    %Für Richtung gilt wie VV

    nStabLasten_konzentriert = 2;
    StabLasten_konzentriertArr = [1,2,10,0.5; 2,2,5,0.75];
    %Eintrag: [1. Stab, 2. Richtung, 3. Wert, 4. Angriffspunkt als x/L]

    nStabLasten_verteilt = 2;
    StabLasten_verteiltArr = [1,2,10,0,0.5; 2,2,20,0,1];
    %Eintrag: [1. Stab, 2. Richtung, 3. Wert, 4. StartPosition, 5. EndPosition]



%%%%%%%%%%%%%%%%%%%%%% EINGABE IN TABLES PACKEN %%%%%%%%%%%%%%%%%%%%%%%%


%Knoten
    [xPos, yPos] = deal(zeros(nKnoten,1));
    for i = 1:nKnoten
        xPos(i,1) = KnotenArr(i,1);
        yPos(i,1) = KnotenArr(i,2);
    end
    Knoten = table(xPos,yPos);

%Staebe
    [StartKnoten, EndKnoten, Querschnitt] = deal(zeros(nStaebe,1));
    for i = 1:nStaebe
        StartKnoten(i,1) = StabArr(i,1);
        EndKnoten(i,1)   = StabArr(i,2);
        Querschnitt(i,1) = StabArr(i,3);
    end
    Staebe = table(StartKnoten, EndKnoten, Querschnitt);

%Querschnitt
    [EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabEnde] = deal(zeros(nQuerschnitte,1));
    [dehnstarr, biegesteif] = deal(false(nQuerschnitte,1));
    for i = 1:nQuerschnitte
        EModul(i,1)           = QuerschnitteArr(i,1);
        Flaeche(i,1)          = QuerschnitteArr(i,2);
        Traegheitsmoment(i,1) = QuerschnitteArr(i,3);
        GelenkStabAnfang(i,1) = QuerschnitteArr(i,4);
        GelenkStabEnde(i,1)   = QuerschnitteArr(i,5);
        if isequal(QuerschnitteArr(i,6),1)
            dehnstarr(i,1)  = true;
        end
        if isequal(QuerschnitteArr(i,7),1)
            biegesteif(i,1) = true;
        end
    end
    Querschnitte = table(EModul, Flaeche, Traegheitsmoment, GelenkStabAnfang, GelenkStabEnde, dehnstarr, biegesteif);
 
%Teilsysteme
    Teilsystem = struct2table(TeilsystemeStruct);

%Lager
    KnotenL = zeros(nLager,1);
    Lagerung = false(nLager, nLagerTypen);
    for i = 1:nLager
        KnotenL(i,1) = LagerArr(i,1);
        for j = 1:nLagerTypen
            if isequal(LagerArr(i,2),j)
                Lagerung(i,j) = true;
            end
        end
    end
    Lager = table(KnotenL, Lagerung);

%Feder
    KnotenF = zeros(nFeder,1);
    FederArt = false(nFeder,3);
    for i = 1:nFeder
        KnotenF(i,1) = FederArr(i,1);
        for j = 1:nFederTypen
            if isequal(FederArr(i,j+1),1)
                FederArt(i,j) = true;
            end
        end
    end
    Feder = table(KnotenF, FederArt);
    
%VorgeschriebeneVerschiebung
    [KnotenVV, RichtungVV, WertVV] = deal(zeros(nVorgeschriebeneVerschiebung,1));
    for i = 1:nVorgeschriebeneVerschiebung
        KnotenVV(i,1)   = VorgeschriebeneVerschiebungArr(i,1);
        RichtungVV(i,1) = VorgeschriebeneVerschiebungArr(i,2);
        WertVV(i,1)     = VorgeschriebeneVerschiebungArr(i,3);
    end
    VorgeschriebeneVerschiebung = table(KnotenVV, RichtungVV, WertVV);

%KnotenLasten
    [StabKL, RichtungKL, WertKL] = deal(zeros(nKnotenLasten,1));
    for i = 1:nKnotenLasten
        StabKL(i,1)     = KnotenLastenArr(i,1);
        RichtungKL(i,1) = KnotenLastenArr(i,2);
        WertKL(i,1)     = KnotenLastenArr(i,3);
    end
    KnotenLasten = table(StabKL, RichtungKL, WertKL);

%StabLasten_konzentriert
    [StabSLK, RichtungSLK, WertSLK, PositionSLK] = deal(zeros(nStabLasten_konzentriert,1));
    for i = 1:nStabLasten_konzentriert
        StabSLK(i,1)        = StabLasten_konzentriertArr(i,1);
        RichtungSLK(i,1)    = StabLasten_konzentriertArr(i,2);
        WertSLK(i,1)        = StabLasten_konzentriertArr(i,3);
        PositionSLK(i,1)    = StabLasten_konzentriertArr(i,4);
    end
    StabLasten_konzentriert = table(StabSLK, RichtungSLK, WertSLK, PositionSLK);

%StabLasten_verteilt
    [StabSLV, RichtungSLV, WertSLV, StartPositionSLV, EndPositionSLV] = ...
        deal(zeros(nStabLasten_verteilt,1));
    for i = 1:nStabLasten_verteilt
        StabSLV(i,1)            = StabLasten_verteiltArr(i,1);
        RichtungSLV(i,1)        = StabLasten_verteiltArr(i,2);
        WertSLV(i,1)            = StabLasten_verteiltArr(i,3);
        StartPositionSLV(i,1)   = StabLasten_verteiltArr(i,4);
        EndPositionSLV(i,1)     = StabLasten_verteiltArr(i,5);
    end
    StabLasten_verteilt = table(StabSLV, RichtungSLV, WertSLV, StartPositionSLV, EndPositionSLV);


end

