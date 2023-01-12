function [out] = Verformungslinie(analyseModel)

    Stab = analyseModel.Stab;
    nStaebe = size(Stab,2);

%% Verformungslinie mit shape functions aus Kassimali S.172

    for i = 1:nStaebe

        VLStab(i).u_loc = Stab(i).u_loc;
        L = Stab(i).L;

        x = linspace(0,L);
        VLStab(i).x = x;

        N1 = 1-x/L;
        N2 = 1-3*x.^2/L^2+2*x.^3/L^3;
        N3 = x-2*x.^2/L+x.^3/L^2;

        N4 = x/L;
        N5 = 3*x.^2/L^2-2*x.^3/L^3;
        N6 = -x.^2/L+x.^3/L^2;

        N = [N1; N2; N3; N4; N5; N6];

        u = N' * VLStab(i).u_loc;
        VLStab(i).u = u;

    end

%% Plotten

    t = tiledlayout(nStaebe,1);
    title(t,"Verformungslinie");

    for i = 1:nStaebe

        nexttile;
        plot(VLStab(i).x,VLStab(i).u);
        hold on
        plot([0,Stab(i).L],[0,0]);
        hold off
        title("Stab " + i);
        maxU = max(VLStab(i).u);
        minU = min(VLStab(i).u);
        mU = max(abs(maxU),abs(minU));
        axis([0 Stab(i).L -mU-0.1*mU mU+0.1*mU]);
        axis ij;

    end


%% Dr Rescht no usgääh
    % fausi öbbis im output darstöue wie vrschiebige  
    out.VLStab = VLStab;

end