function ptext = getTextPosFromArrow(ax, p0, sign, pix)
switch sign
    case 1
        ptext = offsetText(ax, p0, [1; 1], pix);
    case -1
        ptext = offsetText(ax, p0, [1; -1], pix);
end    
end