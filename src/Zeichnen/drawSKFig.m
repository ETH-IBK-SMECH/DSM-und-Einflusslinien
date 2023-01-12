function [out] = drawSKFig(model)


    Knoten = model.Analyse.Knoten;
    KnotenKORD = table2array(struct2table(Knoten));

    Staebe = model.Input.Staebe;
    StaebeS = Staebe.StartKnoten;
    StaebeE = Staebe.EndKnoten;
    StaebeKORD = [StaebeS,StaebeE];

   

    Stab = model.Analyse.Stab;
    SKStab = model.Output.SKStab;
    nStaebe = size(Stab,2);

    t = tiledlayout(nStaebe+1,3);
    title(t,"Schnittkraftdiagramme");

    meanL = mean([model.Analyse.Stab.L]);
 
    skalierung = -1/(4*log(meanL)); %falls die Schnittkräfte nicht ersichtlich sind ändere die skalierung wie z.b. in der nächsten Zeile
    %skalierung = -1/(10*meanL); %ändere x*meanL wie du möchtest

    nexttile;
    for i = 1:nStaebe
        
        R = Stab(i).R(1:2,1:2);

        N = [SKStab(i).KP_N;SKStab(i).SK_N*skalierung];
        if meanL >= 1000
            N = [SKStab(i).KP_N;SKStab(i).SK_N*skalierung*100];
        end

        N_rot = R' * N;

        startKnoten = Stab(i).sNode;
        startKORD = KnotenKORD(startKnoten,:)';

        N_KORD = N_rot + startKORD;
        
        patch(N_KORD(1,:),N_KORD(2,:),'b','FaceAlpha',0.5);
        patch('Faces', StaebeKORD,'Vertices',KnotenKORD,'LineWidth',1);
    end
    title("N - Diagramm");
    axis equal;

    nexttile;
    for i = 1:nStaebe
        
        R = Stab(i).R(1:2,1:2);

        V = [SKStab(i).KP_V;SKStab(i).SK_V*skalierung];
        if meanL >= 1000
            V = [SKStab(i).KP_V;SKStab(i).SK_V*skalierung*100];
        end

        V_rot = R' * V;

        startKnoten = Stab(i).sNode;
        startKORD = KnotenKORD(startKnoten,:)';

        V_KORD = V_rot + startKORD;
        
        patch(V_KORD(1,:),V_KORD(2,:),'b','FaceAlpha',0.5);
        patch('Faces', StaebeKORD,'Vertices',KnotenKORD,'LineWidth',1);
    end
    title("V - Diagramm");
    axis equal;

    nexttile;
    for i = 1:nStaebe
        
        R = Stab(i).R(1:2,1:2);

        M = [SKStab(i).KP_M;SKStab(i).SK_M*skalierung];
        M_rot = R' * M;

        startKnoten = Stab(i).sNode;
        startKORD = KnotenKORD(startKnoten,:)';

        M_KORD = M_rot + startKORD;
        
        patch(M_KORD(1,:),M_KORD(2,:),'b','FaceAlpha',0.5);
        patch('Faces', StaebeKORD,'Vertices',KnotenKORD,'LineWidth',1);
    end
    title("M - Diagramm");
    axis equal;



for i = 1:nStaebe

    x0 = [0,SKStab(i).L];
    y0 = [0,0];


    nexttile;
    plot(SKStab(i).KP_N,SKStab(i).SK_N);
    hold on
    plot(x0,y0);
    hold off
    title("Stab " + i + ", N");
    maxN = max(SKStab(i).SK_N);
    minN = min(SKStab(i).SK_N);
    mN = max(abs(maxN),abs(minN));
    if mN < 1; mN = 1; end
    axis([0 SKStab(i).L -mN-0.1*mN mN+0.1*mN]);
    axis ij;
    
    nexttile;
    plot(SKStab(i).KP_V,SKStab(i).SK_V);
    hold on
    plot(x0,y0);
    hold off
    title("Stab " + i + ", V");
    maxV = max(SKStab(i).SK_V);
    minV = min(SKStab(i).SK_V);
    mV = max(abs(maxV),abs(minV));
    if mV < 1; mV = 1; end
    axis([0 SKStab(i).L -mV-0.1*mV mV+0.1*mV]);
    axis ij;
    
    nexttile;
    plot(SKStab(i).KP_M,SKStab(i).SK_M);
    %plot(SKStab(i).KP_M,SKStab(i).SK_VfM); %für Kontrolle von VfM
    hold on
    plot(x0,y0);
    hold off
    title("Stab " + i + ", M");
    maxM = max(SKStab(i).SK_M);
    minM = min(SKStab(i).SK_M);
    %maxM = max(SKStab(i).SK_VfM);
    %minM = min(SKStab(i).SK_VfM);
    mM = max(abs(maxM),abs(minM));
    if mM < 1; mM = 1; end
    axis([0 SKStab(i).L -mM-0.1*mM mM+0.1*mM]);
    axis ij;

end


end

