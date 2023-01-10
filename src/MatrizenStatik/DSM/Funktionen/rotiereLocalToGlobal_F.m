function [f_glob] = rotiereLocalToGlobal_F(f_loc, R)

    f_glob = R' * f_loc;

end

