function u_loc = VerdrehungMomentengelenk(u_loc, L, vorhandeneDOF)
    
    if sum(vorhandeneDOF) == 5
        if ~vorhandeneDOF(3)
            u2 = -u_loc(2)*3/(2*L);
            u5 = u_loc(5)*3/(2*L);
            u6 = -u_loc(6)*1/2;
            u_loc(3) = u2 + u5 + u6;
        elseif ~vorhandeneDOF(6)
            u2 = -u_loc(2)*3/(2*L);
            u3 = -u_loc(3)*1/2;
            u5 = u_loc(5)*3/(2*L);
            u_loc(6) = u2 + u3 + u5;
        end
    elseif sum(vorhandeneDOF) == 2
        if ~vorhandeneDOF(3) && ~vorhandeneDOF(6)
            u2 = -u_loc(2)*1/L;
            u5 = u_loc(5)*1/L;
            u_loc(3) = u2 + u5;
            u_loc(6) = u2 + u5;
        end
    end

end

