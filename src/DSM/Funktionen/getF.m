function [f_loc] = getF(StabLast, L)
%gibt f_loc für volleingespannten Fall wieder
%input ist Model.Analyse.StabLasten(i)
%für L: Model.Analyse.Stab(Model.Analyse.StabLasten(i).Stab).L
%auso in.Stab().L und dinne in.StabLasten(i).stab isetze

%när mit StabLast.typ case 1,2,3 und 4,5,6 mache
%ACHTUNG VORZEICHEN

    W = StabLast.val;
    l_1 = StabLast.sDist * L;


    switch StabLast.typ

        case 1
            l_2 = L - l_1;
            f_loc = -[W*l_2/L; 0; 0; W*l_1/L; 0; 0];

        case 2
            l_2 = L - l_1;
            f_loc = - [0;
                       W*(l_2^2)*(3*l_1 + l_2)/(L^3);
                       W*l_1*(l_2^2)/(L^2);
                       0;
                       W*(l_1^2)*(l_1 + 3*l_2)/(L^3);
                       -W*(l_1^2)*l_2/(L^2)];

        case 3
            l_2 = L - l_1;
            f_loc = - [0;
                       -6*W*l_1*l_2/(L^3);
                       W*l_2*(l_2 - 2*l_1)/(L^2);
                       0;
                       6*W*l_1*l_2/(L^3);
                       W*l_1*(l_1 - 2*l_2)/(L^2)];

        case 4
            l_2 = (1-StabLast.eDist) * L;
            f_loc = - [W*(L - l_1 - l_2)*(L - l_1 + l_2)/(2*L);
                       0;
                       0;
                       W*(L - l_1 - l_2)*(L + l_1 - l_2)/(2*L);
                       0;
                       0];

        case 5
            l_2 = (1-StabLast.eDist) * L;
            f_loc = - [0;
                       (W*L/2)*(1 - l_1*(2*L^3 - 2*(l_1^2)*L + (l_1^3))/(L^4) - (l_2^3)*(2*L - l_2)/(L^4));
                       (W*(L^2)/12)*(1 - (l_1^2)*(6*L^2 - 8*l_1*L + 3*(l_1^2))/(L^4) - (l_2^3)*(4*L - 3*l_2)/(L^4));
                       0;
                       (W*L/2)*(1 - l_2*(2*L^3 - 2*(l_2^2)*L + (l_2^3))/(L^4) - (l_1^3)*(2*L - l_1)/(L^4));
                       -(W*(L^2)/12)*(1 - (l_2^2)*(6*L^2 - 8*l_2*L + 3*(l_2^2))/(L^4) - (l_1^3)*(4*L - 3*l_1)/(L^4))];                    

        %case 6 sött eig scho nid vorcho

    end
                        


end

