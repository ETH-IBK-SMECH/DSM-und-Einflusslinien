function [out] = drawOriginalFig(Model)
% aus input: [Model.Input]

Knoten  = Model.Input.Knoten;
Knoten  = table2struct(Knoten);
Staebe  = Model.Input.Staebe;
QS      = Model.Input.Querschnitte;
Feder   = Model.Input.Feder;
Lager   = Model.Input.Lager;
VV      = Model.Input.VorgeschriebeneVerschiebung;
KnotenLast = Model.Analyse.KnotenLast;
StabLast_konz = table2struct(Model.Input.StabLasten_konzentriert);
StabLast_vert = table2struct(Model.Input.StabLasten_verteilt);
       

meanL = mean([Model.Analyse.Stab.L]);

%mean konzentrierte Stablasten -> beachte ds momänt in kNmm erfasst wird -> dswege momänt dür 1000 teile
if isfield(StabLast_konz,'Wert')
    formeanSLk = [];
    for i = 1:size(StabLast_konz,1)
        if StabLast_konz(i).Richtung == 3
            formeanSLk(end+1) = StabLast_konz(i).Wert/1000;
        else
            formeanSLk(end+1) = StabLast_konz(i).Wert;
        end
    end
    meanSLk = abs(mean(abs(formeanSLk)));
else
    meanSLk = 1;
end

%mean verteilte Stablasten
if isfield(StabLast_vert,'Wert')
    formeanSLv = [];
    for i = 1:size(StabLast_vert,1)
        if StabLast_vert(i).Richtung == 3
            formeanSLv(end+1) = StabLast_vert(i).Wert/1000;
        else
            formeanSLv(end+1) = StabLast_vert(i).Wert;
        end
    end
    meanSLv = abs(mean(abs(formeanSLv)));
else
    meanSLv = 1;
end

%mean Knotenlasten
if isfield(Model.Analyse.KnotenLast,'val')
    formeanKL = [];
    for i = 1:size(KnotenLast,2)
        if KnotenLast(i).dir == 3
            formeanKL(end+1) = KnotenLast(i).val/1000;
        else
            formeanKL(end+1) = KnotenLast(i).val;
        end
    end
    meanKL = abs(mean(abs(formeanKL)));
    nKL = size(KnotenLast,2);
else
    meanKL = 1;
    nKL = 0;
end


%System (Knoten & Stäbe)
KnotenKORD = table2array(struct2table(Knoten));
StaebeS = Staebe.StartKnoten;
StaebeE = Staebe.EndKnoten;
StaebeKORD = [StaebeS,StaebeE];


patch('Faces', StaebeKORD,'Vertices',KnotenKORD,'LineWidth',1);

%some properties for Staebe
Staebe = table2struct(Staebe);

for i = 1:size(Staebe,1)
       sX = Knoten(Staebe(i).StartKnoten).xPos; eX = Knoten(Staebe(i).EndKnoten).xPos; %x-Koordinate für Start- und Endknoten
       sY = Knoten(Staebe(i).StartKnoten).yPos; eY = Knoten(Staebe(i).EndKnoten).yPos; %y-Koordinate für Start- und Endknoten
       Staebe(i).L = sqrt( (eX - sX)^2 + (eY - sY)^2 ); %Stablänge
       Staebe(i).c = (eX - sX) / Staebe(i).L; %Stabwinkel cosinus
       Staebe(i).s = (eY - sY) / Staebe(i).L; %Stabwinkel sinus
       Staebe(i).R = getR(Staebe(i).c, Staebe(i).s); %Rotationsmatrix
end


%Lager
for i = 1:size(Lager,1)
    type = find(Lager(i,:).Lagerung);
    node = Lager(i,:).Knoten;
    centre = [Knoten(node).xPos;Knoten(node).yPos];

    switch type
        case 1
            stabnodes = [Staebe.StartKnoten;Staebe.EndKnoten]';
            stabnodeidx = find(stabnodes == node);
            if stabnodeidx/size(Staebe,1) <= 1
                R = Staebe(stabnodeidx).R(1:2,1:2);
            else
                stabnodeidx = stabnodeidx - size(Staebe,1);
                R = [-1,0;0,-1]*Staebe(stabnodeidx).R(1:2,1:2);
            end
            drawLager(type,centre,R,0.6*meanL);
        case {2,3,4}
            R = [1,0;0,1];
            drawLager(type,centre,R,0.5*meanL);
        case {5,6}
            stabnodes = [Staebe.StartKnoten;Staebe.EndKnoten]';
            stabnodeidx = find(stabnodes == node);
            if stabnodeidx/size(Staebe,1) <= 1
                R = [1,0;0,1];
            else
                R = [-1,0;0,-1];
            end
            drawLager(type,centre,R,0.6*meanL);
    end



end

%Feder
for i = 1:size(Feder,1)
    type = Feder(i,:).Feder;
    node = Feder(i,:).Knoten;
    centre = [Knoten(node).xPos;Knoten(node).yPos];

    drawFeder(type,centre,4*meanL);
end


%Querschnitte
QS = table2struct(QS);
momentengelenk = true(1,size(Knoten,1)); %nur zum schauen ob momentengelenk für alle stäbe oder nur für den einen

for i = 1:size(Staebe,1)
    QSIdx = Staebe(i).Querschnitt;
    EI = QS(QSIdx).EModul * QS(QSIdx).Traegheitsmoment;
    startK = Staebe(i).StartKnoten;
    endK   = Staebe(i).EndKnoten;
    if EI >= 10^5
        x = [Knoten(startK).xPos,Knoten(endK).xPos,NaN];
        y = [Knoten(startK).yPos,Knoten(endK).yPos,NaN];

        patch(x,y,'k','LineWidth',2.1,'LineJoin','round');
    end

    Staebe(i).sRelease = QS(QSIdx).GelenkStabAnfang;
    Staebe(i).eRelease = QS(QSIdx).GelenkStabende;
    if(Staebe(i).sRelease ~= 3)
        momentengelenk(Staebe(i).StartKnoten) = false;
    end
    if(Staebe(i).eRelease ~=3)
        momentengelenk(Staebe(i).EndKnoten) = false;
    end
    
end


%Gelenke

for i = 1:size(Staebe,1)

    if(Staebe(i).sRelease == 3 && momentengelenk(Staebe(i).StartKnoten))
        centre = [Knoten(Staebe(i).StartKnoten).xPos;Knoten(Staebe(i).StartKnoten).yPos];
        drawGelenk(3,centre,meanL);
    elseif(Staebe(i).sRelease == 3)
        centre = [0.025*meanL;0];
        centre = Staebe(i).R(1:2,1:2)'*centre;
        centre = [Knoten(Staebe(i).StartKnoten).xPos;Knoten(Staebe(i).StartKnoten).yPos] + centre;
        drawGelenk(3,centre,meanL);
    end
    if(Staebe(i).eRelease == 3 && momentengelenk(Staebe(i).EndKnoten))
        centre = [Knoten(Staebe(i).EndKnoten).xPos;Knoten(Staebe(i).EndKnoten).yPos];
        drawGelenk(3,centre,meanL);
    elseif(Staebe(i).eRelease == 3)
        centre = [-0.025*meanL;0];
        centre = Staebe(i).R(1:2,1:2)'*centre;
        centre = [Knoten(Staebe(i).EndKnoten).xPos;Knoten(Staebe(i).EndKnoten).yPos] + centre;
        drawGelenk(3,centre,meanL);
    end
    
end


%StabLasten_vert
for i = 1:size(StabLast_vert,1)
    StabIdx = StabLast_vert(i).Stab;
    dir = StabLast_vert(i).Richtung;
    val = StabLast_vert(i).Wert/meanSLv;
    sDist = StabLast_vert(i).StartPosition;
    eDist = StabLast_vert(i).EndPosition;
    LArr = val*0.125*meanL; 

    R = Staebe(StabIdx).R(1:2,1:2);
    SKKord = [Knoten(Staebe(StabIdx).StartKnoten).xPos;Knoten(Staebe(StabIdx).StartKnoten).yPos];
    L = Staebe(StabIdx).L;

    for j = linspace(sDist*L,eDist*L,6)
        p1 = [sDist*L;0] + [j;0];

        switch dir
            case 1
                p0 = [sDist*L-LArr+j;0];
            case 2
                p0 = [sDist*L+j;-LArr];
        end

        p1 = SKKord + R'*p1;
        p0 = SKKord + R'*p0;

        drawArrow2(p0,p1,'b',meanL);
    end

    if dir == 2
        sKordLine = [sDist*L;-LArr];
        eKordLine = [eDist*L;-LArr];

        sKL = SKKord + R'*sKordLine;
        eKL = SKKord + R'*eKordLine;

        line([sKL(1),eKL(1)],[sKL(2),eKL(2)],'color','b','LineWidth',1.5);
    end


end



%StabLasten_konz
for i = 1:size(StabLast_konz,1)
    StabIdx = StabLast_konz(i).Stab;
    dir = StabLast_konz(i).Richtung;
    val = StabLast_konz(i).Wert/meanSLk;
    sDist = StabLast_konz(i).StartPosition;
    LArr = val*0.25*meanL;


    R = Staebe(StabIdx).R(1:2,1:2);
    SKKord = [Knoten(Staebe(StabIdx).StartKnoten).xPos;Knoten(Staebe(StabIdx).StartKnoten).yPos];
    L = Staebe(StabIdx).L;

    p1 = [sDist*L;0];

    switch dir
        case 1
            p0 = [sDist*L-LArr;0];
        case 2
            p0 = [sDist*L;-LArr];
    end

    p1 = SKKord + R'*p1;
    
    switch dir
        case {1,2}
            p0 = SKKord + R'*p0;

            drawArrow2(p0,p1,'r',meanL);
        case 3
            if val >= 10
                val = val/1000;
            end
            radius = val*meanL*0.125;
            
            drawCircularArrow(radius,p1,sign(val),'r');
    end
end


%KnotenLast
for i = 1:nKL
    KnotenIdx = KnotenLast(i).node;
    dir = KnotenLast(i).dir;
    val = KnotenLast(i).val/meanKL;
    LArr = val*0.25*meanL;
    

    p1 = [Knoten(KnotenIdx).xPos;Knoten(KnotenIdx).yPos];

    switch dir
        case 1
            p0 = [-LArr;0];
        case 2
            p0 = [0;-LArr];
    end

    switch dir
        case {1,2}
            p0 = p0 + p1;

            drawArrow2(p0,p1,'r',meanL);
        case 3
            val = val/1000;
            radius = abs(val)*meanL*0.1;

            drawCircularArrow(radius,p1,sign(val),'r');
    end
end



end

