classdef TestLastenAssemblieren < matlab.unittest.TestCase
    % Tests for:
    %  - knotenLastenAssemblieren(model, DOF, nDOF)
    %  - stabLastenAssemblieren(model, DOF, nDOF)

    methods (Test)

        %% ---------- KNOTEN-LASTEN ----------

        function knoten_no_loads_returns_zero(tc)
            % No KnotenLast -> zero vector of correct size
            M = tests.util.ModelBuilder.minimal(2, 3);
            % activate some DOFs so nDOF>0 (no elements needed)
            M.SPC = struct('node', 1, 'dir', 1);
            M.Info.nSPC = 1;
            M.Feder = struct('node', 2, 'dir', 2);
            M.Info.nFedern = 1;

            [DOF, nDOF, ~] = dofNummerieren(M);
            F = knotenLastenAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(size(F), [nDOF, 1]);
            tc.verifyEqual(nnz(F), 0);
        end

        function knoten_loads_map_to_correct_global_dofs(tc)
            % With one horizontal bar (all DOFs active, 1..6), loads map to indices
            % node1-ux -> index 1; node2-uy -> index 5
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Stab = S;
            M.Info.nStaebe = 1;

            % two nodal loads
            M.KnotenLast = struct( ...
                'node', {1, 2}, ...
                'dir', {1, 2}, ... % 1=ux, 2=uy
                'val', {10, -5});

            [DOF, nDOF, ~] = dofNummerieren(M);
            F = knotenLastenAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(nDOF, 6);
            tc.verifyEqual(full(F(1)), 10); % node1-ux
            tc.verifyEqual(full(F(5)), -5); % node2-uy
            tc.verifyEqual(nnz(F), 2);
        end
        %% ---------- STAB-LASTEN ----------

        function stab_no_element_loads_returns_zero(tc)
            % No StabLast entries -> zero vector, even if elements exist
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            % Provide required fields used downstream
            S.k_loc_v = getK(C.E, C.A, C.I, C.L);
            S.R = getR(1, 0);
            S.L = C.L;
            M.Stab = S;
            M.Info.nStaebe = 1;

            [DOF, nDOF, M] = dofNummerieren(M);
            [F_stab, ~] = stabLastenAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(size(F_stab), [nDOF, 1]);
            tc.verifyEqual(nnz(F_stab), 0);
        end

        function stab_invalid_load_references_are_ignored(tc)
            % StabLast referencing a non-existent element index is skipped
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.k_loc_v = getK(C.E, C.A, C.I, C.L);
            S.R = getR(1, 0);
            S.L = C.L;
            M.Stab = S;
            M.Info.nStaebe = 1;

            % Invalid stab index (99) -> should be ignored
            M.StabLast = struct('stab', 99, 'typ', 1, 'val', 123, 'sDist', 0, 'eDist', 0);
            M.Info.nStabLasten = 1;

            [DOF, nDOF, M] = dofNummerieren(M);
            [F_stab, ~] = stabLastenAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(nnz(F_stab), 0);
        end

        function stab_all_local_dofs_released_produces_no_contribution(tc)
            % Even if StabLast exists, if all local DOFs are inactive for the element,
            % nothing is assembled (masking via activeStabDOF & dof_e).
            C = tests.util.Const;
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.k_loc_v = getK(C.E, C.A, C.I, C.L);
            S.R = getR(1, 0);
            S.L = C.L;
            S.sRelease = [1, 2, 3];
            S.eRelease = [1, 2, 3]; % all six local DOFs released
            M.Stab = S;
            M.Info.nStaebe = 1;

            % A dummy StabLast is fine; contribution will be masked out
            M.StabLast = struct('stab', 1, 'typ', 1, 'val', 10, 'sDist', 0, 'eDist', 0);
            M.Info.nStabLasten = 1;

            [DOF, nDOF, M] = dofNummerieren(M);
            [F_stab, ~] = stabLastenAssemblieren(M, DOF, nDOF);

            tc.verifyEqual(nnz(F_stab), 0);
        end
    end
end
