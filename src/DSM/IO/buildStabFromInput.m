function Stab = buildStabFromInput(in)
    nStaebe = size(in.Staebe,1);

    Stab(nStaebe) = struct();

    for i = 1:nStaebe
        % Geometry
        Stab(i).sNode = in.Staebe.StartKnoten(i);
        Stab(i).eNode = in.Staebe.EndKnoten(i);

        % Section & material
        QsIdx  = in.Staebe.Querschnitt(i);
        MatIdx = in.Querschnitte.Material(QsIdx);

        Stab(i).E  = in.Material.EModul(MatIdx);
        Stab(i).A  = in.Querschnitte.Flaeche(QsIdx);
        Stab(i).Iy = in.Querschnitte.Traegheitsmoment(QsIdx);

        % Stiffness flags
        Stab(i).EAinf = in.Querschnitte.dehnstarr(QsIdx);
        Stab(i).EIinf = in.Querschnitte.biegesteif(QsIdx);

        % Releases
        r = in.Staebe.GelenkStabAnfang(i);
        if r == 0
            Stab(i).sRelease = [];
        else
            Stab(i).sRelease = r;
        end

        r = in.Staebe.GelenkStabende(i);
        if r == 0
            Stab(i).eRelease = [];
        else
            Stab(i).eRelease = r;
        end
    end
end
