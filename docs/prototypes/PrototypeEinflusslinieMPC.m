%{
In diesem Skript zeige ich auf, dass man mit "Lagrange multipliers" die MPC
(multi-point constraints) für z.B. die EInflusslinie für die Querkraft
einführen kann. Das Ursprungssystem ist ein beidseitig eingespannter Stab.
Dieser wird in the Mitte unterteilt und mit den MPC zusammengeklebt.
Konkret sind diese:
    DOF1 = uX_Stab1 = uX_Stab2     = DOF4
    DOF3 = uZ_Stab1 = uZ_Stab2     = DOF6
    DOF2 = uY_Stab1 = uY_Stab2 + 1 = DOF5
Wegen der Stabunterteilung existieren 6 DOF in der Mitte (3 für jedes
Stabende). 
%}

%% Dummy Input mit komischen Zahlen, damit nicht per Zufall sich etwas richtig rauskürzt.
    %Stabparameter
    E = 2.5
    A = 17
    I = 14
    L = 11
    %Konstanten der Steifigkeitsmatrix um Übersicht zu gewinnen
    c1 =    E*A/L
    c2 = 12*E*I/(L^3)
    c3 =  6*E*I/(L^2)
    c4 =  4*E*I/L
    %Systemsteifigkeitsmatrix
    k_sys = [c1,  0,  0, 0, 0, 0;
              0, c2,-c3, 0, 0, 0;
              0,-c3, c4, 0, 0, 0;
              0,  0,  0,c1, 0, 0;
              0,  0,  0, 0,c2,c3;
              0,  0,  0, 0,c3,c4]

    %ein Stab wird in 2 Stäbe getrennt
    k_sys_2 = [k_sys,  zeros(6);
               zeros(6), k_sys];

    %Randbedingungskoeffizienten
    A = [1,0,0,-1, 0, 0;
         0,1,0, 0,-1, 0;
         0,0,1, 0, 0,-1] 

    A_2 = [0,0,0,1,0,0,-1,0,0,0,0,0;
           0,0,0,0,1,0,0,-1,0,0,0,0;
           0,0,0,0,0,1,0,0,-1,0,0,0];

    %augmented stiffness matrix
    K_lag = [k_sys,       A';
                 A, zeros(3)]

    K_lag_2 = [k_sys_2,      A_2';
                   A_2, zeros(3)];

    %system Lastvektor. Da keine äusseren Kräfte ist alles gleich Null
    f_sys = zeros(6,1)
    %augmented Lastvektor mit inhomogener Anteil der Randbedingunen
    f_lag = [f_sys;0;1;0]

    f_sys_2 = zeros(12,1);
    f_lag_2 = [f_sys_2;0;1;0];
    %lösen des gleichungssystems
    u_lag = K_lag \ f_lag

    u_lag_2 = K_lag_2 \ f_lag_2;
    %extrahieren der DOF 1:6, welche physische Bedeutung haben
    u_sys = u_lag(1:6)

    u_sys_2 = u_lag_2(4:9);

    %MIT F_LAG_2 CHAME JETZE AU VERSCHIDNIGI LENGINE IGÄÄH AUSO AR
    %GWÜNSCHTE STÖU TRENNE UND ES GITT DIE ENTSPRÄCHENDI VRSCHIEBIG
    %
    %Im programm so ibinge ds d steifigkeitsmatrix vom stab wos betrifft
    %efach erwitteret wird uf die art mit L_1 und L_2 und när chame d
    %constraints-gliichige entsprächend ifüehere und verschiebige bestimme
    %und mit däm zruggrächne mit de entsprächend trennte
    %Steifigkeitsmatrize
    %
    %solution no nötig für verschiebige am ändi: aber do chame d
    %verschiebig efach aus knotelasht ibringe und lo rächne

%{
Weil u_sys(3) (= Rotation am End vom Stab 1) und u_sys(6) (= Rotation am
Start von Stab 2) ungleich Null sind, sehen wir, dass mit MPC das korrekte
Resultat für die Einflusslinie erzeugt werden kann. ERFOLG!
%}