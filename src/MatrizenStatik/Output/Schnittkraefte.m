function [out] = Schnittkraefte(analyseModel)

%welche fields verwendet werden 
%mau do ineschriibe mit Stab = analyseModel.Stab etc
%ds cha när immerno ine funktion packt wärde

%% Vereinfachung
Stab = analyseModel.Stab;
StabLast = analyseModel.StabLast;
nStaebe = size(Stab,2);
nStabLasten = size(StabLast,2);

%% Stablasten am Stab zuordnen und neues struct SKStab iniziieren

for i = 1:nStaebe
    SKStab(i).q_loc_sk = Stab(i).q_loc_sk;
    SKStab(i).L = Stab(i).L;
end

SKStab(nStaebe).Lasten = [];

if isfield(StabLast, 'stab')
    for i = 1:nStabLasten
        stabIdx = StabLast(i).stab;
        SKStab(stabIdx).Lasten(end+1) = i;
    end
end


%% kritische Punkte für N,V,M und die entsprechenden Lastfälle geordnet

for i = 1:nStaebe

    %Initialisierung
    SKStab(i).KP_N = [0,1]; %die kritischen Punkte intialisieren für N-SK-Diagramm
    SKStab(i).Lastfall_N = [0,0]; %welcher Lastfall zum kritischen Punkt gehört
    SKStab(i).SK_N = []; %für Schnittkraftwerte am kritischen Punkt

    SKStab(i).KP_V = [0,1];
    SKStab(i).Lastfall_V = [0,0];
    SKStab(i).SK_V = [];

    SKStab(i).KP_M = []; %leer weil es später mit KP_V gemergt wird
    SKStab(i).Lastfall_M = [];
    SKStab(i).SK_VfM = [];
    SKStab(i).SK_M = [];

    %Zuweisung
    for j = 1:length(SKStab(i).Lasten) %[2,4,5] StabLast wo agriiffe
        last = SKStab(i).Lasten(j);
        direction = StabLast(last).dir;
        sDist = StabLast(last).sDist;
        eDist = StabLast(last).eDist;
        if isempty(eDist); eDist = sDist; end
    
        switch direction
            case 1
                SKStab(i).KP_N([end+1, end+2]) = [sDist,eDist];
                SKStab(i).Lastfall_N([end+1, end+2]) = [last,last];
            case 2
                SKStab(i).KP_V([end+1, end+2]) = [sDist,eDist];
                SKStab(i).Lastfall_V([end+1, end+2]) = [last,last];
            case 3
                SKStab(i).KP_M([end+1, end+2]) = [sDist,eDist];
                SKStab(i).Lastfall_M([end+1, end+2]) = [last,last];
        end

        %zusätzliche KP für KP_M falls verteilte Last
        if StabLast(last).typ == 5
            SKStab(i).KP_M(end+1:end+21) = linspace(sDist,eDist,21);
            SKStab(i).Lastfall_M(end+1:end+21) = last;
        end


    end

    %V und M mergen für M
    SKStab(i).KP_M = [SKStab(i).KP_V, SKStab(i).KP_M];
    SKStab(i).Lastfall_M = [SKStab(i).Lastfall_V, SKStab(i).Lastfall_M];

    %entsprechend sortieren
    [SKStab(i).KP_N, I_N] = sort(SKStab(i).KP_N);
    SKStab(i).Lastfall_N  = SKStab(i).Lastfall_N(I_N);
    SKStab(i).SK_N([1:length(SKStab(i).KP_N)]) = SKStab(i).q_loc_sk(1);

    [SKStab(i).KP_V, I_V] = sort(SKStab(i).KP_V);
    SKStab(i).Lastfall_V  = SKStab(i).Lastfall_V(I_V);
    SKStab(i).SK_V([1:length(SKStab(i).KP_V)]) = SKStab(i).q_loc_sk(2);

    [SKStab(i).KP_M, I_M] = sort(SKStab(i).KP_M);
    SKStab(i).Lastfall_M  = SKStab(i).Lastfall_M(I_M);
    SKStab(i).SK_VfM([1:length(SKStab(i).KP_M)]) = SKStab(i).q_loc_sk(2);
    SKStab(i).SK_M([1:length(SKStab(i).KP_M)]) = SKStab(i).q_loc_sk(3);
    


end


%% N und V Array erstellen für kritische Punkte

for i = 1:nStaebe

    %für N
    for j = 2:length(SKStab(i).KP_N)-2
        if SKStab(i).Lastfall_N(j+1) == SKStab(i).Lastfall_N(j)
            switch StabLast(SKStab(i).Lastfall_N(j)).typ
                case 1
                    SKStab(i).SK_N(j+1:end) = SKStab(i).SK_N(j+1:end) - StabLast(SKStab(i).Lastfall_N(j)).val;
                case 4
                    SKStab(i).SK_N(j+1:end) = SKStab(i).SK_N(j+1:end) - StabLast(SKStab(i).Lastfall_N(j)).val*(SKStab(i).KP_N(j+1)-SKStab(i).KP_N(j))*SKStab(i).L;
            end
        elseif find(SKStab(i).Lastfall_N == SKStab(i).Lastfall_N(j),1) == j
            z = find(SKStab(i).Lastfall_N == SKStab(i).Lastfall_N(j));
            for y = z(1):z(end)-1
                SKStab(i).SK_N(y+1:end) = SKStab(i).SK_N(y+1:end) - StabLast(SKStab(i).Lastfall_N(j)).val*(SKStab(i).KP_N(y+1)-SKStab(i).KP_N(y))*SKStab(i).L;
            end
        end
    end

    %für V
    for j = 2:length(SKStab(i).KP_V)-2
        if SKStab(i).Lastfall_V(j+1) == SKStab(i).Lastfall_V(j)
            switch StabLast(SKStab(i).Lastfall_V(j)).typ
                case 2
                    SKStab(i).SK_V(j+1:end) = SKStab(i).SK_V(j+1:end) + StabLast(SKStab(i).Lastfall_V(j)).val;
                case 5
                    SKStab(i).SK_V(j+1:end) = SKStab(i).SK_V(j+1:end) + StabLast(SKStab(i).Lastfall_V(j)).val*(SKStab(i).KP_V(j+1)-SKStab(i).KP_V(j))*SKStab(i).L;
            end
        elseif find(SKStab(i).Lastfall_V == SKStab(i).Lastfall_V(j),1) == j
            z = find(SKStab(i).Lastfall_V == SKStab(i).Lastfall_V(j));
            for y = z(1):z(end)-1
                SKStab(i).SK_V(y+1:end) = SKStab(i).SK_V(y+1:end) + StabLast(SKStab(i).Lastfall_V(j)).val*(SKStab(i).KP_V(y+1)-SKStab(i).KP_V(y))*SKStab(i).L;
            end
        end
    end

end
    
%% schauen wo überall V = 0, um dies als kritische Punkte für M einzufügen


%% M Array

for i = 1:nStaebe
   
    for j = 2:length(SKStab(i).KP_M)-1
        if SKStab(i).Lastfall_M(j) == SKStab(i).Lastfall_M(j+1) && length(find(SKStab(i).Lastfall_M == SKStab(i).Lastfall_M(j))) == 2 
            switch StabLast(SKStab(i).Lastfall_M(j)).typ
                case 2
                    SKStab(i).SK_VfM(j+1:end) = SKStab(i).SK_VfM(j+1:end) + StabLast(SKStab(i).Lastfall_M(j)).val;
                    %SKStab(i).SK_M(j:end) = SKStab(i).SK_M(j:end) + SKStab(i).SK_VfM(j-1)*SKStab(i).L*(SKStab(i).KP_M(j)-SKStab(i).KP_M(j-1));
                case 3
                    SKStab(i).SK_M(j+1:end) = SKStab(i).SK_M(j+1:end) - StabLast(SKStab(i).Lastfall_M(j)).val;
            end
        elseif find(SKStab(i).Lastfall_M == SKStab(i).Lastfall_M(j),1) == j
            %SKStab(i).SK_M(j:end) = SKStab(i).SK_M(j:end) + SKStab(i).SK_VfM(j-1)*SKStab(i).L*(SKStab(i).KP_M(j)-SKStab(i).KP_M(j-1));
            z = find(SKStab(i).Lastfall_M == SKStab(i).Lastfall_M(j));
            for y = z(1)+1:z(end)
                SKStab(i).SK_VfM(y:end) = SKStab(i).SK_VfM(y:end) + StabLast(SKStab(i).Lastfall_M(j)).val*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1))*SKStab(i).L;
               % SKStab(i).SK_M(y:end) = SKStab(i).SK_M(y:end) + SKStab(i).SK_VfM(y-1)*SKStab(i).L*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1)) + 0.5*StabLast(SKStab(i).Lastfall_M(j)).val*SKStab(i).L*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1))*SKStab(i).L*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1));
            end
        end
    end
    %SKStab(i).SK_M(end) = SKStab(i).q_loc_sk(6);
    %SKStab(i).SK_M(end) = SKStab(i).SK_M(end) + SKStab(i).SK_VfM(end-1)*SKStab(i).L*(SKStab(i).KP_M(end)-SKStab(i).KP_M(end-1));
    
    for j = 2:length(SKStab(i).KP_M)
        SKStab(i).SK_M(j:end) = SKStab(i).SK_M(j:end) + SKStab(i).SK_VfM(j-1)*SKStab(i).L*(SKStab(i).KP_M(j)-SKStab(i).KP_M(j-1));
        if find(SKStab(i).Lastfall_M == SKStab(i).Lastfall_M(j),1) == j
            z = find(SKStab(i).Lastfall_M == SKStab(i).Lastfall_M(j));
            for y = z(1)+1:z(end)
                SKStab(i).SK_M(y:end) = SKStab(i).SK_M(y:end) + 0.5*StabLast(SKStab(i).Lastfall_M(j)).val*SKStab(i).L*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1))*SKStab(i).L*(SKStab(i).KP_M(y)-SKStab(i).KP_M(y-1));
            end
        end
    end


end

%% Skalierung

for i = 1:nStaebe
    SKStab(i).KP_N = SKStab(i).KP_N*SKStab(i).L;
    SKStab(i).KP_V = SKStab(i).KP_V*SKStab(i).L;
    SKStab(i).KP_M = SKStab(i).KP_M*SKStab(i).L;

    SKStab(i).KP_N = [0,SKStab(i).KP_N,SKStab(i).L];
    SKStab(i).SK_N = [0,SKStab(i).SK_N,0];

    SKStab(i).KP_V = [0,SKStab(i).KP_V,SKStab(i).L];
    SKStab(i).SK_V = [0,SKStab(i).SK_V,0];

    SKStab(i).KP_M = [0,SKStab(i).KP_M,SKStab(i).L];
    SKStab(i).SK_M = [0,SKStab(i).SK_M,0];
end


%% zurück überweisen
out.StabLast = StabLast;
out.SKStab = SKStab;


end

