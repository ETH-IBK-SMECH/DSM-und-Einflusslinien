function [out] = drawAuflagerreaktionen(Model)


Knoten  = Model.Input.Knoten;
Knoten  = table2struct(Knoten);
SPC = Model.Analyse.SPC;
meanL = mean([Model.Analyse.Stab.L]);
Feder = Model.Analyse.Feder;

t = tiledlayout(1,1);
title(t,"Auflagerreaktionen")

drawOriginalFig(Model);


formeanSPC = [];
for i = 1:size(SPC,2)
    if SPC(i).dir == 3
        formeanSPC(end+1) = SPC(i).Reaktion/1000;
    else
        formeanSPC(end+1) = SPC(i).Reaktion;
    end
end
meanSPC = abs(mean(formeanSPC));



for i = 1:size(SPC,2)
    KnotenIdx = SPC(i).node;
    dir = SPC(i).dir;
    val = SPC(i).Reaktion/meanSPC;
    LArr = val*0.25*meanL;

    p1 = [Knoten(KnotenIdx).xPos;Knoten(KnotenIdx).yPos];

    ptext = p1;
    
    switch dir
        case 1
            if sign(val) == 1
                ptext = ptext + [-0.2;-0.04]*meanL;
            elseif sign(val) == -1
                ptext = ptext + [0.2;-0.04]*meanL;
            end
        case 2
            if sign(val) == 1
                ptext = ptext + [0.02;-0.2]*meanL;
            elseif sign(val) == -1
                ptext = ptext + [-0.04;0.2]*meanL;
            end
        case 3
            ptext = ptext + [0.15;0.15]*meanL;
    end

    switch dir
        case 1
            p0 = [-LArr;0];
        case 2
            p0 = [0;-LArr];
    end

    switch dir
        case {1,2}
            p0 = p0 + p1;

            drawArrow2(p0,p1,'m',meanL);
            text(ptext(1),ptext(2),num2str(SPC(i).Reaktion));
        case 3
            if val >= 5
                val = val/1000;
            end
            radius = abs(val)*meanL*0.1;

            drawCircularArrow(radius,p1,sign(val),'m');
            text(ptext(1),ptext(2),num2str(SPC(i).Reaktion));
    end

end

%Auflagerreaktion von Feder
if isfield(Feder,'Reaktion')
    for i = 1:size(Feder,2)
        KnotenIdx = Feder(i).node;
        dir = Feder(i).dir;
        val = Feder(i).Reaktion/meanSPC;
        LArr = val*0.25*meanL;
    
        p1 = [Knoten(KnotenIdx).xPos;Knoten(KnotenIdx).yPos];
    
        ptext = p1;
        
        switch dir
            case 1
                if sign(val) == 1
                    ptext = ptext + [-0.2;-0.04]*meanL;
                elseif sign(val) == -1
                    ptext = ptext + [0.2;-0.04]*meanL;
                end
            case 2
                if sign(val) == 1
                    ptext = ptext + [0.02;-0.2]*meanL;
                elseif sign(val) == -1
                    ptext = ptext + [-0.04;0.2]*meanL;
                end
            case 3
                ptext = ptext + [0.15;0.15]*meanL;
        end
    
        switch dir
            case 1
                p0 = [-LArr;0];
            case 2
                p0 = [0;-LArr];
        end
    
        switch dir
            case {1,2}
                p0 = p0 + p1;
    
                drawArrow2(p0,p1,'m',meanL);
                text(ptext(1),ptext(2),num2str(SPC(i).Reaktion));
            case 3
                if val >= 5
                    val = val/1000;
                end
                radius = abs(val)*meanL*0.1;
    
                drawCircularArrow(radius,p1,sign(val),'m');
                text(ptext(1),ptext(2),num2str(SPC(i).Reaktion));
        end
    
    end

end

