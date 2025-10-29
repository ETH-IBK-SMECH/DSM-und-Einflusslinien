classdef TestAuflagerUndStabkraefte < matlab.unittest.TestCase
% Rudimentary tests for:
%  - auflagerreaktionenBerechnen
%  - stabkraefteBerechnen

    methods (Test)
        % SPC reaction equals K*U - (F_N - P_int) at constrained DOF
        function reactions_basic_spc(tc)
            nkd = 3; n = 6;
            K = speye(n);                         % simple: R_sys = U - (F-P)
            U = (1:n).';
            F = zeros(n,1);
            P = zeros(n,1);
            DOF = (1:n).';
            SPC(1) = struct('node',1,'dir',1,'val',0,'Reaktion',[]);
            Feder = struct([]);                   % none

            [R, SPCo, FedO] = auflagerreaktionenBerechnen(K,U,F,P,SPC,Feder,DOF,nkd);

            tc.verifyEqual(SPCo(1).Reaktion, U(1));      % equals R_sys(1)
            tc.verifyEqual(R(1), U(1));
            tc.verifyEmpty(FedO);                        % unchanged
        end

        % SPC on inactive DOF (DOF==0) stores zero reaction and leaves vector zero
        function reactions_inactive_dof(tc)
            nkd = 3; n = 6;
            K = speye(n); U = ones(n,1); F = zeros(n,1); P = zeros(n,1);
            DOF = (1:n).'; DOF(1) = 0;                  % deactivate node1,dir1
            SPC(1) = struct('node',1,'dir',1,'val',0,'Reaktion',[]);
            Feder = struct([]);
            [R, SPCo] = auflagerreaktionenBerechnen(K,U,F,P,SPC,Feder,DOF,nkd);
            tc.verifyEqual(SPCo(1).Reaktion, 0);
            tc.verifyEqual(R(1), 0);
        end

        % Element forces with identity rotation: u_loc=q_loc=U(dof_e)
        function stab_forces_identity(tc)
            nkd = 3; n6 = 2*nkd;
            U = (1:6).';                              % global DOFs 1..6 used directly
            S = struct();
            S.dof_e = 1:n6;                           % direct mapping
            S.activeStabDOF = true(1,n6);
            S.R = eye(n6);
            S.k_loc = eye(n6);
            S.P_int = zeros(n6,1);
            S.L = 1;
            S.vorhandeneDOF = true(1,n6);
            Stab = S;

            Stab = stabkraefteBerechnen(Stab, U, nkd);

            tc.verifyEqual(Stab.u_glob, U);
            tc.verifyEqual(Stab.u_loc,  U);
            tc.verifyEqual(Stab.q_loc,  U);
            tc.verifyEqual(Stab.q_glob, U);
            tc.verifyEqual(Stab.q_loc_sk, U .* [-1;1;-1;1;-1;1]);
        end

        % Masking and zero dof indices: only active/mappped entries are filled
        function stab_forces_masking(tc)
            nkd = 3; n6 = 2*nkd;
            U = (10:15).';
            S = struct();
            S.dof_e = [1 0 3 0 5 0];                  % some unmapped (0)
            S.activeStabDOF = logical([1 0 1 0 1 0]); % some inactive
            S.R = eye(n6);
            S.k_loc = eye(n6);
            S.P_int = zeros(n6,1);
            S.L = 1;
            S.vorhandeneDOF = true(1,n6);
            Stab = S;

            Stab = stabkraefteBerechnen(Stab, U, nkd);

            exp_u = zeros(n6,1); exp_u([1 3 5]) = U([1 3 5]);
            tc.verifyEqual(Stab.u_glob, exp_u);
            tc.verifyEqual(Stab.u_loc,  exp_u);
            tc.verifyEqual(Stab.q_loc,  exp_u);             % k_loc = I, P_int=0
        end

        % VerdrehungMomentengelenk correction applied when a rotation is missing
        function stab_verdrehung_correction(tc)
            nkd = 3; n6 = 2*nkd; L = 2;
            % Build u_glob such that u2,u5,u6 non-zero; u3 reconstructed
            U = zeros(6,1); U([2 5 6]) = [0.01; 0.02; 0.005];
            S = struct();
            S.dof_e = 1:6;
            S.activeStabDOF = true(1,6);
            S.R = eye(n6);
            S.k_loc = eye(n6);
            S.P_int = zeros(n6,1);
            S.L = L;
            S.vorhandeneDOF = [1 1 0 1 1 1];          % DOF 3 missing
            Stab = S;

            Stab = stabkraefteBerechnen(Stab, U, nkd);

            % expected u3 = (-3*u2/(2L)) + (3*u5/(2L)) - 0.5*u6
            u2 = -U(2)*3/(2*L);
            u5 =  U(5)*3/(2*L);
            u6 = -U(6)*0.5;
            exp_u3 = u2 + u5 + u6;

            tc.verifyEqual(Stab.u_loc(3), exp_u3, 'AbsTol', 1e-12);
        end
    end
end
