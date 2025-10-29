classdef TestDofNummerieren < matlab.unittest.TestCase
    % Tests for dofNummerieren(model)
    %
    % Covered:
    %  - contiguous numbering for a simple 2-node horizontal bar
    %  - releases deactivate local DOFs (dof_e = 0 at those positions)
    %  - vertical orientation swaps translational flags (x<->y)
    %  - springs (Federn) and SPCs activate DOFs even without elements

    methods (Test)
        function simple_two_node_bar_contiguous(tc)
            % Build minimal model with 2 nodes, nkd=3
            M = tests.util.ModelBuilder.minimal(2, 3);
            % One horizontal element (cs=1,sn=0)
            M.Stab = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Info.nStaebe = numel(M.Stab);   % 1

            [DOF, nDOF, Mout] = dofNummerieren(M);

            % Expected: 6 active dofs (3 per node), numbered 1..6
            tc.verifyEqual(nDOF, 6);
            tc.verifyEqual(DOF, 1:6);

            % dof_e maps local 6 dofs to global [1..6]
            tc.verifyTrue(isfield(Mout.Stab, 'dof_e'));
            tc.verifyEqual(Mout.Stab(1).dof_e, 1:6);
        end

        function releases_deactivate(tc)
            % Minimal model
            M = tests.util.ModelBuilder.minimal(2, 3);

            % Horizontal bar with releases:
            % start: release [2 3] (uy, φ), end: release [1] (ux)
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            S.sRelease = [2 3];
            S.eRelease = 1;
            M.Stab = S;
            M.Info.nStaebe = 1;

            [DOF, nDOF, Mout] = dofNummerieren(M);

            % Active locals: 1, 5, 6
            tc.verifyEqual(nDOF, 3);

            de = Mout.Stab(1).dof_e;
            disp(de)
            % Released positions should be zero in dof_e:
            % local order is [1 2 3 4 5 6]
            tc.verifyEqual(de(2), 0); % start uy 
            tc.verifyEqual(de(3), 0); % start φ  
            tc.verifyEqual(de(4), 0); % end   ux  

            % Remaining positions must be nonzero and unique, numbered 1..3
            kept = de(de>0);
            tc.verifyEqual(numel(kept), 3);
            tc.verifyEqual(numel(unique(kept)), 3);
            tc.verifyEqual(sort(kept), 1:3);
        end

        function vertical_orientation_swaps_xy(tc)
            % Vertical member so the transIdx swap path is exercised
            M = tests.util.ModelBuilder.minimal(2, 3);

            S = tests.util.ModelBuilder.oneBarHoriz(M);
            % Overwrite orientation to vertical (cs=0, sn=1)
            S.cs = 0; S.sn = 1;
            % Release only start x (local DOF 1) to make swap visible
            S.sRelease = 1; 
            S.eRelease = [];
            M.Stab = S;
            M.Info.nStaebe = 1;

            [~, ~, Mout] = dofNummerieren(M);

            vorhanden = Mout.Stab(1).vorhandeneDOF;   % after releases
            active    = Mout.Stab(1).activeStabDOF;   % after vertical swap

            nkd = 3;
            transIdx = [1, 2, nkd+1, nkd+2];

            % Expected: active(transIdx) = vorhanden(transIdx([2 1 4 3]))
            expected = vorhanden;
            expected(transIdx) = vorhanden(transIdx([2 1 4 3]));

            tc.verifyEqual(active, expected);

            % Since start x (1) was off and start y (2) on,
            % after swap we expect start x ON and start y OFF:
            tc.verifyFalse(vorhanden(1));  % release applied
            tc.verifyTrue(vorhanden(2));
            tc.verifyTrue(active(1));      % swapped from 2
            tc.verifyFalse(active(2));     % swapped from 1
        end

        function springs_and_spc_activate_without_elements(tc)
            % No elements; only a spring and an SPC should activate DOFs
            M = tests.util.ModelBuilder.minimal(2, 3);
            M.Info.nStaebe = 0;

            % Spring at node 2 in dir 2 (uy), SPC at node 1 in dir 1 (ux)
            M.Feder = struct('node', 2, 'dir', 2);
            M.Info.nFedern = 1;
            M.SPC   = struct('node', 1, 'dir', 1);
            M.Info.nSPC = 1;

            [DOF, nDOF, ~] = dofNummerieren(M);

            % Expected active global DOFs:
            % node1-x -> index 1
            % node2-y -> index ( (2-1)*3 + 2 ) = 5
            tc.verifyEqual(nDOF, 2);

            activeIdx = find(DOF>0);
            tc.verifyEqual(activeIdx, [1 5]);

            % Numbering must be 1..2 in ascending order at those positions
            tc.verifyEqual(DOF(DOF>0), [1 2]);
        end

        function two_elements_sharing_node(tc)
            M = tests.util.ModelBuilder.minimal(3, 3); % nodes 1-3
            S1 = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2); % 1-2
            S2 = tests.util.ModelBuilder.oneBarHoriz(M, 2, 3); % 2-3
            M.Stab = [S1 S2]; M.Info.nStaebe = 2;
        
            [DOF, nDOF, ~] = dofNummerieren(M);
        
            tc.verifyEqual(nDOF, 9);          % 3 nodes * 3 dof
            tc.verifyEqual(DOF, 1:9);         % contiguous numbering
        end

        function invalid_spc_and_spring_are_ignored(tc)
            % check that invalid entries dont break numbering
            M = tests.util.ModelBuilder.minimal(2, 3);
            M.Info.nStaebe = 0;

            % One valid, one invalid for each
            M.SPC   = struct('node', {1, 99}, 'dir', {1, 1});
            M.Info.nSPC = numel(M.SPC);
            M.Feder = struct('node', {2, 2}, 'dir', {2, 9});
            M.Info.nFedern = numel(M.Feder);
        
            [DOF, nDOF, ~] = dofNummerieren(M);
        
            tc.verifyEqual(nDOF, 2);          % only two valid activations
            tc.verifyEqual(find(DOF>0), [1 5]); % node1-ux, node2-uy
        end

        function released_local_dof_stays_zero_even_if_global_active(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
        
            % Element releases start-uy (local 2)…
            S1 = tests.util.ModelBuilder.oneBarHoriz(M);
            S1.sRelease = 2;
            % …but SPC activates node1-uy globally:
            M.SPC = struct('node', 1, 'dir', 2); M.Info.nSPC = 1;
        
            M.Stab = S1; M.Info.nStaebe = 1;
        
            [~, ~, Mout] = dofNummerieren(M);
            tc.verifyEqual(Mout.Stab(1).dof_e(2), 0, ...
                'Element-local release must keep dof_e=0 even if global DOF is active by SPC.');
        end

    end
end
