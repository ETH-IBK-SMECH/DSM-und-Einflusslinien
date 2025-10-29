classdef TestElementeErzeugen < matlab.unittest.TestCase
% Unit tests for elementeErzeugen.m
% Verifies geometry, rotation, stiffness, and release behavior.

    methods (Test)
        % Simple 2-node horizontal bar: geometry and stiffness correct
        function horizontal_bar_geometry_and_stiffness(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            C = tests.util.Const;
            S.Iy = C.I;        % ensure field name matches function input
            M.Stab = S; 
            M.Info.nStaebe = 1;

            M2 = elementeErzeugen(M);

            % geometry
            tc.verifyEqual(M2.Stab(1).L, 1, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).cs, 1, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).sn, 0, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).phi, 0, 'AbsTol', 1e-12);

            % stiffness matrices created
            tc.verifySize(M2.Stab(1).k_loc_v, [6 6]);
            tc.verifySize(M2.Stab(1).k_loc,   [6 6]);
            tc.verifyTrue(issymmetric(M2.Stab(1).k_loc_v));

            % rotation matrix consistent with getR
            R = getR(1,0);
            tc.verifyEqual(M2.Stab(1).R, R, 'AbsTol', 1e-12);
        end

        % Vertical bar orientation correctly computed
        function vertical_bar_orientation(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            % set vertical geometry (x=0 constant, y increasing)
            M.Knoten(1).x = 0; M.Knoten(1).y = 0;
            M.Knoten(2).x = 0; M.Knoten(2).y = 2;

            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            S.sn = 1; S.cs = 0; S.Iy = tests.util.Const.I;
            M.Stab = S; M.Info.nStaebe = 1;

            M2 = elementeErzeugen(M);

            tc.verifyEqual(M2.Stab(1).L, 2, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).cs, 0, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).sn, 1, 'AbsTol', 1e-12);
            tc.verifyEqual(M2.Stab(1).phi, pi/2, 'AbsTol', 1e-12);
        end

        % Releases deactivate local DOFs as expected
        function releases_condense_stiffness(tc)
            M = tests.util.ModelBuilder.minimal(2,3);
            S = tests.util.ModelBuilder.oneBarHoriz(M,1,2);
            S.Iy = tests.util.Const.I;
            % Release bending DOF at start node (local index 3)
            S.sRelease = 3;  
            M.Stab = S; M.Info.nStaebe = 1;

            M2 = elementeErzeugen(M);
            k_full = M2.Stab(1).k_loc_v;
            k_cond = M2.Stab(1).k_loc;

            tc.verifySize(k_cond, [6 6]);
            tc.verifyTrue(issymmetric(k_cond));
            tc.verifyNotEqual(k_full, k_cond, 'Releases should modify stiffness');
            % released DOF rows/cols zeroed
            tc.verifyTrue(all(k_cond(3,:)==0) && all(k_cond(:,3)==0));
        end

        % Works for multiple bars (loop over all Staebe)
        function multiple_elements_processed(tc)
            M = tests.util.ModelBuilder.minimal(3,3);
            S(1) = tests.util.ModelBuilder.oneBarHoriz(M,1,2);
            S(2) = tests.util.ModelBuilder.oneBarHoriz(M,2,3);
            for i=1:2
                S(i).Iy = tests.util.Const.I;
            end
            M.Stab = S; M.Info.nStaebe = 2;

            M2 = elementeErzeugen(M);
            tc.verifyEqual(numel(M2.Stab), 2);
            tc.verifyTrue(all([M2.Stab.L] > 0));
            tc.verifyTrue(all(cellfun(@(x) isequal(size(x), [6 6]), ...
                {M2.Stab.k_loc_v})));
        end

        % Empty input (no Staebe) returns unchanged model 
        function handles_no_elements(tc)
            M = tests.util.ModelBuilder.minimal(2,3);
            M.Stab = struct([]); 
            M.Info.nStaebe = 0;
            M2 = elementeErzeugen(M);
            tc.verifyEqual(M2.Stab, M.Stab);
        end
    end
end
