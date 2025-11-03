classdef TestVectorRotations < matlab.unittest.TestCase
    % Tests for:
    %   f_glob = rotiereLocalToGlobal_F(f_loc, R)   -> f_glob = R' * f_loc
    %   u_loc  = rotiereGlobalToLocal_u(u_glob, R)  -> u_loc  = R  * u_glob


    methods (Test)
        function size_and_identity_angle(tc)
            a = 0;
            c = cos(a);
            s = sin(a);
            R = getR(c, s);

            % random but fixed vectors
            rng(1);
            f_loc = randn(6, 1);
            u_glob = randn(6, 1);

            f_glob = rotiereLocalToGlobal_F(f_loc, R);
            u_loc = rotiereGlobalToLocal_u(u_glob, R);

            tc.verifySize(f_glob, [6, 1]);
            tc.verifySize(u_loc, [6, 1]);

            % At angle 0, R is identity -> no change
            tc.verifyEqual(f_glob, f_loc, 'AbsTol', 1e-12);
            % For u, with a=0: u_loc = u_glob
            tc.verifyEqual(u_loc, u_glob, 'AbsTol', 1e-12);
        end

        function roundtrip_consistency(tc)
            a = pi / 5;
            c = cos(a);
            s = sin(a);
            R = getR(c, s);

            rng(2);
            u_glob = randn(6, 1);
            f_loc = randn(6, 1);

            % Displacements: u_loc = R*u_glob  ->  u_glob_back = R'*u_loc
            u_loc = rotiereGlobalToLocal_u(u_glob, R);
            u_glob_back = R' * u_loc;
            tc.verifyEqual(u_glob_back, u_glob, 'AbsTol', 1e-12);

            % Forces: f_glob = R'*f_loc -> f_loc_back = R*f_glob
            f_glob = rotiereLocalToGlobal_F(f_loc, R);
            f_loc_back = R * f_glob;
            tc.verifyEqual(f_loc_back, f_loc, 'AbsTol', 1e-12);
        end

        function energy_invariance(tc)
            % Virtual work invariance: u^T f is invariant under rotation
            a = 0.37 * pi;
            c = cos(a);
            s = sin(a);
            R = getR(c, s);

            rng(3);
            u_glob = randn(6, 1);
            f_loc = randn(6, 1);

            % Transform to common frame and compare u^T f
            u_loc = rotiereGlobalToLocal_u(u_glob, R); % local
            f_glob = rotiereLocalToGlobal_F(f_loc, R); % global

            work_local = u_loc.' * f_loc;
            work_global = u_glob.' * f_glob;

            tc.verifyEqual(work_local, work_global, 'AbsTol', 1e-12, ...
                'Virtual work should be invariant under orthonormal rotation.');
        end
    end
end
