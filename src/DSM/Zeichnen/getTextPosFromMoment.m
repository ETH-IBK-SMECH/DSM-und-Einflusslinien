function ptext = getTextPosFromMoment(ax, p1, R_moment, sgn, pix)
    if sgn == 0, sgn = 1; end
    % put label outside the arc (flip with sign)
    base = p1 + [1; sgn] * (0.65 * R_moment);
    ptext = offsetText(ax, base, [1; sgn], pix);
end