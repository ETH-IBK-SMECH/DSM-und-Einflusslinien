function F_TS_kond = kondensiereFTS(TS)
    
    F_TS = TS.F_TS;
    F_TS_kond = zeros(6,1);
    K = TS.K_sys_TS;

    isActive = TS.isActiveTSDOF;
    nKnoten = length(TS.KnotenTSgeordnet);
    
    e = [1:3,nKnoten*3-2:nKnoten*3];
    eActive = isActive(e);
    e = e(eActive);  

    i = [4:(nKnoten-1)*3];
    iActive = isActive(i);
    i = i(iActive);

    F_TS_kond(eActive) = F_TS(e) - K(e,i)*K(i,i)^(-1)*F_TS(i);

end

