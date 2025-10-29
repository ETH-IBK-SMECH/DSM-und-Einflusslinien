classdef Test_StatischeKondensation < matlab.unittest.TestCase
    % Straightforward unit tests for Statische_Kondensation_durchfuehren:
    %  - no-op when Kondensation is empty
    %  - condense a single component
    %  - early return when mask implies keep-all or keep-none

    methods (Static)
        function M = mkModel(nNodes, nkd, nodes, compMask)
            % Build a minimal model via tests.util.ModelBuilder and attach Kondensation.
            M = tests.util.ModelBuilder.minimal(nNodes, nkd);
            if nargin >= 3 && ~isempty(nodes)
                M.Kondensation = struct( ...
                    'Knoten', nodes, ...
                    'KomponentenMaske', logical(compMask(:).') );
            else
                M.Kondensation = [];
            end
        end

        function [K_ff, F_f] = spdSystem(n)
            A    = randn(n);
            K_ff = A'*A + eye(n);
            F_f  = randn(n,1);
        end
    end

    methods (Test)
        function noOpWhenEmpty(tc)
            % No Kondensation block -> function must be a no-op (but kond is populated for back-sub).
            M = tc.mkModel(3, 3, [], []);
            [kond0.K_sys_ff, kond0.F_sys_f_kond] = tc.spdSystem(4);

            [K2, F2, kond2] = Statische_Kondensation_durchfuehren(M, 1:999, kond0);

            tc.verifyEqual(K2, kond0.K_sys_ff);
            tc.verifyEqual(F2, kond0.F_sys_f_kond);

            % kond is always populated (also in no-op case)
            tc.verifyTrue(isfield(kond2,'K_ff_voll') && isfield(kond2,'F_f_voll') && isfield(kond2,'Meta'));
            tc.verifyEqual(kond2.K_ff_voll, kond0.K_sys_ff);
            tc.verifyEqual(kond2.F_f_voll,  kond0.F_sys_f_kond);

            n = size(kond0.K_sys_ff,1);
            tc.verifyEqual(kond2.Meta.ne, n);
            tc.verifyEqual(numel(kond2.Meta.eIdx), n);
            tc.verifyEmpty(kond2.Meta.iIdx);
            tc.verifyEqual(kond2.Meta.n, n);
        end

        function condenseOneComp(tc)
            % nkd=3, one node free -> condense its ux (mask = [1 0 0])
            nkd = 3;
            DOF = 1:3;  % one node's free-space (ux,uy,rz)
            M = tc.mkModel(1, nkd, 1, [1 0 0]);
            [kond0.K_sys_ff, kond0.F_sys_f_kond] = tc.spdSystem(3);

            [Kred, Fred, kond2] = Statische_Kondensation_durchfuehren(M, DOF, kond0);

            tc.verifySize(Kred, [2 2]);
            tc.verifySize(Fred, [2 1]);

            % Meta should reflect that exactly 1 internal, 2 kept
            tc.verifyTrue(isfield(kond2,'Meta'));
            tc.verifyEqual(kond2.Meta.ne, 2);
            tc.verifyEqual(kond2.Meta.n,  3);
            tc.verifyEqual(numel(kond2.Meta.iIdx), 1);
            % In this simple DOF=1:3 case, condensing ux means iIdx==1 (but don't over-assume ordering)
            tc.verifyTrue(ismember(1, kond2.Meta.iIdx));
            tc.verifyEqual(sort(kond2.Meta.eIdx(:)).', [2 3]);
        end

        function allOrNoneEarlyReturn(tc)
            % If mask yields "keep all" or "keep none", reduced K/F must equal input (no change).
            nkd = 3; DOF = 1:3;
            [kond0.K_sys_ff, kond0.F_sys_f_kond] = tc.spdSystem(3);

            % keep all (no internal)
            M_keepAll = tc.mkModel(1, nkd, 1, [0 0 0]);
            [K2, F2, kond2] = Statische_Kondensation_durchfuehren(M_keepAll, DOF, kond0);
            tc.verifyEqual(K2, kond0.K_sys_ff);
            tc.verifyEqual(F2, kond0.F_sys_f_kond);
            % Meta consistent
            tc.verifyEqual(kond2.Meta.ne, 3);
            tc.verifyEmpty(kond2.Meta.iIdx);
            tc.verifyEqual(sort(kond2.Meta.eIdx(:)).', [1 2 3]);

            % keep none (all internal) -> also early return (no change)
            M_keepNone = tc.mkModel(1, nkd, 1, [1 1 1]);
            [K3, F3, kond3] = Statische_Kondensation_durchfuehren(M_keepNone, DOF, kond0);
            tc.verifyEqual(K3, kond0.K_sys_ff);
            tc.verifyEqual(F3, kond0.F_sys_f_kond);
            % Meta consistent
            tc.verifyEqual(kond3.Meta.ne, 0);
            tc.verifyEqual(sort(kond3.Meta.iIdx(:)).', [1 2 3]);
            tc.verifyEmpty(kond3.Meta.eIdx);
        end
    end
end
