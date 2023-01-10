function [K_loc] = kondensiereK(Klv, activeDOF)
%für input in.Stab(i).k_loc und in.Staebe(i)

    sz = size(activeDOF,2);
    K_loc = zeros(sz);
    

    e = find(activeDOF);
    i = find(~activeDOF);


    K_loc(e,e) = Klv(e,e) - Klv(e,i)*Klv(i,i)^(-1)*Klv(i,e);
    

end

