function [out] = copyFields(Knoten, Stab, Feder, KnotenLast, StabLast, SPC, Info, gew_output,...
                            K_sys, F_sys, F_sys_Knoten, F_sys_Stab, kond, U_sys, DOF, u_kept)
   out.Knoten       = Knoten;   
   out.Stab         = Stab; 
   out.Feder        = Feder; 
   out.KnotenLast   = KnotenLast; 
   out.StabLast     = StabLast; 
   out.SPC          = SPC; 
   out.Info         = Info; 
   out.gew_output   = gew_output;
   out.K_sys        = K_sys; 
   out.F_sys        = F_sys; 
   out.F_sys_Knoten = F_sys_Knoten; 
   out.F_sys_Stab   = F_sys_Stab; 
   out.U_sys        = U_sys; 
   out.kond         = kond;
   out.DOF          = DOF;
   out.u_kept       = u_kept;
   
   %...
end                         