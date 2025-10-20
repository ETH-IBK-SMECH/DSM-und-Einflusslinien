function [u_loc] = rotiereGlobalToLocal_u(u_glob, R)

    u_loc = R * u_glob;

end

