classdef TestRandbedingungenKondensieren < matlab.unittest.TestCase
    methods (Test)
        function known_and_free_masks_and_sizes(tc)
            % 2 nodes, nkd=3, one element so DOF=1..6
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Stab = S;
            M.Info.nStaebe = 1;
            [DOF, nDOF, ~] = dofNummerieren(M);

            K = speye(nDOF);
            F = (1:nDOF).';
            % fix node1-ux (global 1) and node2-uy (global 5)
            SPC = struct('node', {1, 2}, 'dir', {1, 2}, 'val', {0, 0});

            kk = randbedingungenKondensieren(K, F, SPC, DOF, nDOF, 3);
            tc.verifyTrue(isfield(kk, 'K_sys_ff') && isfield(kk, 'F_sys_f_kond'));
            tc.verifyEqual(kk.s, ~kk.f);
            tc.verifyEqual(size(kk.K_sys_ff), [sum(kk.f), sum(kk.f)]);
            tc.verifyEqual(size(kk.F_sys_f_kond), [sum(kk.f), 1]);
        end

        function spc_on_inactive_dof_is_ignored(tc)
            % release node1-ux so it becomes inactive; SPC there should be ignored
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.sRelease = 1;
            M.Stab = S;
            M.Info.nStaebe = 1;
            [DOF, nDOF, ~] = dofNummerieren(M);

            K = speye(nDOF);
            F = zeros(nDOF, 1);
            SPC = struct('node', 1, 'dir', 1, 'val', 123); % maps to DOF==0

            kk = randbedingungenKondensieren(K, F, SPC, DOF, nDOF, 3);
            tc.verifyFalse(any(kk.s)); % no known dofs marked
            tc.verifyEqual(kk.K_sys_ff, K);
            tc.verifyEqual(kk.F_sys_f_kond, F);
        end

        function sums_multiple_spc_values_on_same_dof(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Stab = S;
            M.Info.nStaebe = 1;
            [DOF, nDOF, ~] = dofNummerieren(M);
            K = speye(nDOF);
            F = zeros(nDOF, 1);

            % two SPCs on node2-ux (global 4) with values 0.1 and 0.2
            SPC = struct('node', {2, 2}, 'dir', {1, 1}, 'val', {0.1, 0.2});
            kk = randbedingungenKondensieren(K, F, SPC, DOF, nDOF, 3);

            g = DOF((2 - 1)*3+1); % mapped index
            tc.verifyTrue(kk.s(g));
            tc.verifyEqual(kk.known.U_s, 0.3, 'AbsTol', 1e-12);
        end

        function matches_condensation_with_known_ui(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Stab = S;
            M.Info.nStaebe = 1;
            [DOF, nDOF, ~] = dofNummerieren(M);
            K = gallery('poisson', 2);
            K = kron(K, eye(3));
            K = K(1:nDOF, 1:nDOF);
            K = K + K.' + speye(nDOF);
            F = (1:nDOF).';

            SPC = struct('node', {1}, 'dir', {2}, 'val', {0.5}); % node1-uy

            kk = randbedingungenKondensieren(K, F, SPC, DOF, nDOF, 3);

            % Manual via condensation
            isKnown = false(1, nDOF);
            U = zeros(nDOF, 1);
            localIdx = (1 - 1) * 3 + 2;
            g = DOF(localIdx);
            isKnown(g) = true;
            U(g) = 0.5;
            [Kc, Fc] = condensation(K, F, ~isKnown, 'preserve_size', false, 'known_ui', U(isKnown));

            tc.verifyEqual(full(kk.K_sys_ff), full(Kc), 'AbsTol', 1e-10);
            tc.verifyEqual(full(kk.F_sys_f_kond), full(Fc), 'AbsTol', 1e-10);
        end
    end
end
