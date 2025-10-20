function [K_glob] = rotiereLocalToGlobal_K(K_loc, R)

    K_glob = R' * K_loc * R;

end

