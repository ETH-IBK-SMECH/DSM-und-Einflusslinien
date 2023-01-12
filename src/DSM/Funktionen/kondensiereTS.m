function [activeTS, k_glob, isActiveTS, K_sys_TS] = kondensiereTS(Teilsystem,Stab)
    %mit Stab.activeStabDOF arbeite ums zämezstöue
    %mit Teilsystem.KnotenDesTS
    %mit Teilsystem.KnotenTSgeordnet

    Staebe = Teilsystem.BeteiligteStaebe; %[1,3,2]
    Knoten = Teilsystem.KnotenTSgeordnet; %[2 3 5 4]
    KnotenMitRichtung = Teilsystem.KnotenDesTS; %[3 2 5 3 4 5]

    k_glob = zeros(6);

    %zersch mau für aui zämestöue K_TS whoole
    K_sys_TS = zeros(length(Knoten)*3);

    %isActive
    isActive = false(1,length(Knoten)*3);

    for i = 1:length(Staebe)

        %sNode drzuezöue mit find
        %idxsnode seit a welere stöu vo knoten snode vo stab isch
        IdxSNode = find(Knoten == KnotenMitRichtung(i*2-1));
        sNodes = IdxSNode*3-2:IdxSNode*3;
        K_sys_TS(sNodes,sNodes) = K_sys_TS(sNodes,sNodes) + Stab(Staebe(i)).k_glob(1:3,1:3);
        activeSN = Stab(Staebe(i)).activeStabDOF(1:3);
        isActive(sNodes(activeSN)) = true;
     
        %eNode drzuezöue mit find
        IdxENode = find(Knoten == KnotenMitRichtung(i*2));
        eNodes = IdxENode*3-2:IdxENode*3;
        K_sys_TS(eNodes,eNodes) = K_sys_TS(eNodes,eNodes) + Stab(Staebe(i)).k_glob(4:6,4:6);
        activeEN = Stab(Staebe(i)).activeStabDOF(4:6);
        isActive(eNodes(activeEN)) = true;

    end
    
    isActiveTS = isActive;

    %jetz hei mir K_sys und es isActive zum luege weli mir dürfe näh
    %e = [1:3, length*3-2:length*3]

    %externe Dofs herausfiltern
    e = [1:3,length(Knoten)*3-2:length(Knoten)*3];
    eActive = isActive(e);
    e = e(eActive);
    activeTS = eActive; %ist wie activeStabDOF für Stäbe
    
    %interne Dofs herausfiltern
    i = [4:(length(Knoten)-1)*3];
    iActive = isActive(i);
    i = i(iActive);

    k_glob(eActive,eActive) = K_sys_TS(e,e) - K_sys_TS(e,i)*K_sys_TS(i,i)^(-1)*K_sys_TS(i,e);


end

