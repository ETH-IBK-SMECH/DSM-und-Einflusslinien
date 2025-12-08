function ptext = getTextPos(basePoint, dir, val, meanL)

ptext = basePoint;

switch dir
    case 1 % horizontal
        if sign(val) >= 0
            ptext = ptext + [-0.2; -0.04] * meanL;
        else
            ptext = ptext + [0.2; -0.04] * meanL;
        end
    case 2 % vertikal
        if sign(val) >= 0
            ptext = ptext + [0.02; -0.2] * meanL;
        else
            ptext = ptext + [-0.04; 0.2] * meanL;
        end
    case 3 % Moment
        ptext = ptext + [0.15; 0.15] * meanL;
end
end
