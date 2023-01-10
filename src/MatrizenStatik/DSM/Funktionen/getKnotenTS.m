function KnotenTS = getKnotenTS(KdS,anzahlStaebe)

    KnotesTS = zeros(anzahlStaebe+1,1);
    
    %[3 2 5 3 4 5]
    %zu [2 3 5 4]

    if KdS(1) == KdS(3) || KdS(1) == KdS(4)
        KnotenTS(1) = KdS(2);
        KdS([1,2]) = KdS([2,1]);
    else
        KnotenTS(1) = KdS(1);
    end

    for i = 1:anzahlStaebe-1
        j = i*2;
        KnotenTS(i+1) = KdS(j);
        if KdS(j) == KdS(j+2)
            KdS([j+1,j+2]) = KdS([j+2,j+1]);
        end
    end

    KnotenTS(anzahlStaebe+1) = KdS(length(KdS));


end

