classdef TestSystemSteifigkeitAssemblieren < matlab.unittest.TestCase
    % Tests for systemSteifigkeitAssemblieren(model, DOF, nDOF)

    methods (Test)
        function empty_system_returns_zero(tc) %
            % No elements, no teilsysteme, some DOFs activated by SPC/Feder
            % Assures that empty system does not lead to crash or invalid
            % output
            M = tests.util.ModelBuilder.minimal(2, 3);
            M.Info.nStaebe = 0;
            % Activate two DOFs so nDOF>0
            M.SPC = struct('node', 1, 'dir', 1);
            M.Info.nSPC = 1;
            M.Feder = struct('node', 2, 'dir', 2);
            M.Info.nFedern = 1;

            M = sanitizeAnalysisModel(M); % creates all necessary fields (Stab.inTeilSys etc.)
            [DOF, nDOF, ~] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(size(K), [nDOF, nDOF]);
            tc.verifyTrue(issparse(K));
            tc.verifyEqual(nnz(K), 0);
        end

        function one_element_no_releases_matches_RtKR(tc)
            % Single horizontal element, all 6 DOFs active -> K_sys = R'*Kloc*R
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.cs = 1;
            S.sn = 0;
            S.k_loc = getK(C.E, C.A, C.I, C.L);
            S.R = getR(S.cs, S.sn);
            S.k_glob = S.R.' * S.k_loc * S.R;
            M.Stab = S;
            M.Info.nStaebe = 1;

            M = sanitizeAnalysisModel(M);
            [DOF, nDOF, M] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            Ke = S.R.' * S.k_loc * S.R;
            tc.verifyEqual(full(K), Ke, 'AbsTol', C.ABS, 'RelTol', C.REL);
        end

        function one_element_with_releases_masks_rows_and_cols(tc)
            % Releases: start [uy,phi], end [ux] -> only 3 active globals
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.cs = 1;
            S.sn = 0;
            S.sRelease = [2, 3];
            S.eRelease = 1;
            S.k_loc = getK(C.E, C.A, C.I, C.L);
            S.R = getR(S.cs, S.sn);
            S.k_glob = S.R.' * S.k_loc * S.R;
            M.Stab = S;
            M.Info.nStaebe = 1;

            M = sanitizeAnalysisModel(M);
            [DOF, nDOF, M] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            % Build expected by masking Ke with element's activeStabDOF and placing at dd
            Ke = S.R.' * S.k_loc * S.R;
            mask = M.Stab(1).activeStabDOF(:).';
            dd = M.Stab(1).dof_e(mask);
            Ke_m = Ke(mask, mask);

            % K should equal Ke(mask,mask) placed at dd indices -> since numbering is contiguous,
            % K(dd,dd) must equal Ke_m and size(K) = nDOF = 3
            tc.verifyEqual(size(K), [nDOF, nDOF]);
            tc.verifyEqual(full(K(dd, dd)), Ke_m, 'AbsTol', C.ABS, 'RelTol', C.REL);
        end

        function two_elements_sharing_node_are_additive(tc)
            % 3 nodes -> two bars [1-2] and [2-3]; assembly must add both contributions
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(3, 3);

            S1 = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            S1.cs = 1;
            S1.sn = 0;
            S1.k_loc = getK(C.E, C.A, C.I, C.L);
            S1.R = getR(S1.cs, S1.sn);
            S1.k_glob = S1.R.' * S1.k_loc * S1.R;

            S2 = tests.util.ModelBuilder.oneBarHoriz(M, 2, 3);
            S2.cs = 1;
            S2.sn = 0;
            S2.k_loc = getK(C.E, C.A, C.I, C.L);
            S2.R = getR(S2.cs, S2.sn);
            S2.k_glob = S2.R.' * S2.k_loc * S2.R;

            M.Stab = [S1, S2];
            M.Info.nStaebe = 2;

            M = sanitizeAnalysisModel(M);
            [DOF, nDOF, M] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            % Manual expected (using the same rules) to check additivity
            Kexp = sparse(nDOF, nDOF);
            for i = 1:2
                Ke = M.Stab(i).R.' * M.Stab(i).k_loc * M.Stab(i).R;
                mask = M.Stab(i).activeStabDOF(:).';
                dd = M.Stab(i).dof_e(mask);
                Kexp(dd, dd) = Kexp(dd, dd) + Ke(mask, mask);
            end

            tc.verifyEqual(full(K), full(Kexp), 'AbsTol', C.ABS, 'RelTol', C.REL);
        end

        function teilsystem_with_insufficient_nodes_is_skipped(tc)
            % Provide a Teilsystem with <2 KnotenTSgeordnet -> must be ignored
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);

            % One free bar
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.cs = 1;
            S.sn = 0;
            S.k_loc = getK(C.E, C.A, C.I, C.L);
            S.R = getR(S.cs, S.sn);
            S.k_glob = S.R.' * S.k_loc * S.R;
            M.Stab = S;
            M.Info.nStaebe = 1;

            % Teilsystem present but not usable
            M.Teilsystem = struct('KnotenTSgeordnet', 1); % length==1
            M.Info.nTeilsys = 1;

            M = sanitizeAnalysisModel(M);
            [DOF, nDOF, M] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            % Expected = same as one_element_no_releases case
            Ke = S.R.' * S.k_loc * S.R;
            tc.verifyEqual(full(K), Ke, 'AbsTol', C.ABS, 'RelTol', C.REL);
        end

        function element_all_masked_yields_no_contribution(tc)
            % If active mask is all false, element contributes nothing
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);

            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.cs = 1;
            S.sn = 0;
            S.k_loc = getK(C.E, C.A, C.I, C.L);
            S.R = getR(S.cs, S.sn);

            % Brutally release all 6 local DOFs
            S.sRelease = [1, 2, 3];
            S.eRelease = [1, 2, 3];

            M.Stab = S;
            M.Info.nStaebe = 1;

            M = sanitizeAnalysisModel(M);
            [DOF, nDOF, M] = dofNummerieren(M);
            K = systemSteifigkeitAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(nnz(K), 0);
        end
    end
end
