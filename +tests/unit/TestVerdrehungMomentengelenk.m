classdef TestVerdrehungMomentengelenk < matlab.unittest.TestCase
    % Unit tests for VerdrehungMomentengelenk.m
    % Checks rotational DOF reconstruction for 5-DOF and 2-DOF hinge cases.

    methods (Test)
        % Missing start rotation (DOF 3) reconstructed correctly
        function reconstruct_start_rotation(tc)
            L = 2;
            u_loc = zeros(6, 1);
            u_loc([2, 5, 6]) = [0.01, 0.02, 0.005]; % vertical displacements + end rotation
            vorhandene = [1, 1, 0, 1, 1, 1]; % DOF 3 missing

            u_new = verdrehungMomentengelenk(u_loc, L, vorhandene);

            % expected rotation at node 1 (u3)
            u2 = -u_loc(2) * 3 / (2 * L);
            u5 = u_loc(5) * 3 / (2 * L);
            u6 = -u_loc(6) * 0.5;
            expected_u3 = u2 + u5 + u6;

            tc.verifyEqual(u_new(3), expected_u3, 'AbsTol', 1e-12);
        end

        % Missing end rotation (DOF 6) reconstructed correctly
        function reconstruct_end_rotation(tc)
            L = 2;
            u_loc = zeros(6, 1);
            u_loc([2, 3, 5]) = [0.01, 0.002, 0.02];
            vorhandene = [1, 1, 1, 1, 1, 0]; % DOF 6 missing

            u_new = verdrehungMomentengelenk(u_loc, L, vorhandene);

            u2 = -u_loc(2) * 3 / (2 * L);
            u3 = -u_loc(3) * 0.5;
            u5 = u_loc(5) * 3 / (2 * L);
            expected_u6 = u2 + u3 + u5;

            tc.verifyEqual(u_new(6), expected_u6, 'AbsTol', 1e-12);
        end

        % Both rotations missing (typical double hinge)
        function reconstruct_both_rotations(tc)
            L = 2;
            u_loc = zeros(6, 1);
            u_loc([2, 5]) = [0.01, 0.03]; % only vertical DOFs active
            vorhandene = [0, 1, 0, 0, 1, 0]; % only 2 active (u2,u5)

            u_new = verdrehungMomentengelenk(u_loc, L, vorhandene);

            expected = (-u_loc(2) / L) + (u_loc(5) / L);
            tc.verifyEqual(u_new(3), expected, 'AbsTol', 1e-12);
            tc.verifyEqual(u_new(6), expected, 'AbsTol', 1e-12);
        end

        % If no DOFs missing, nothing changes
        function no_change_if_all_active(tc)
            L = 2;
            u_loc = rand(6, 1);
            vorhandene = true(1, 6);
            u_new = verdrehungMomentengelenk(u_loc, L, vorhandene);
            tc.verifyEqual(u_new, u_loc);
        end

        % If mask does not match any condition, vector unchanged
        function unchanged_for_other_counts(tc)
            L = 2;
            u_loc = rand(6, 1);
            vorhandene = [1, 1, 1, 1, 0, 0]; % 4 active, not handled explicitly
            u_new = verdrehungMomentengelenk(u_loc, L, vorhandene);
            tc.verifyEqual(u_new, u_loc);
        end
    end
end
