function [f_loc] = kondensiereF(flv, klv, activeDOF)
% für flv: in.StabLasten(i).f_loc
% für klv: Model.Analyse.Stab(StabLasten(i).stab).k_loc_v

    f_loc = zeros(6,1);
    
    e = find(activeDOF);
    i = find(~activeDOF);

    f_loc(e) = flv(e) - klv(e,i)*klv(i,i)^(-1)*flv(i);

end

