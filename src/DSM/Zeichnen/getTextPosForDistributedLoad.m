function ptext = getTextPosForDistributedLoad(ax, SKKord, R, L, sign, sDist, eDist, LArr, pix)
    % Center location along the member in local coords
    jmid = 0.5*(sDist + eDist) * L;

    baseLocal = [jmid; -LArr];

    % Transform to global
    base = SKKord + R' * baseLocal;
    switch sign
        case 1
            ptext = offsetText(ax, base, [0; -1], pix);
        case -1
            ptext = offsetText(ax, base, [0; 1], pix);
    end
end