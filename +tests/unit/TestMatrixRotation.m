classdef TestMatrixRotation < matlab.unittest.TestCase
    methods (Test)
        function congruence_equals_formula(tc)
            C = tests.util.Const;
            K = C.K6();
            R = C.R6();

            Kglob = rotiereLocalToGlobal_K(K, R);
            tc.verifyEqual(Kglob, R.'*K*R, 'AbsTol', C.ABS, 'RelTol', C.REL);
        end

        function energy_invariance(tc)
            C = tests.util.Const;
            K = C.K6();
            R = C.R6(pi/5);

            u_glob = tests.util.randvec(6, 7);
            u_loc = R * u_glob;

            Wloc = u_loc.' * K * u_loc;
            Wglob = u_glob.' * (R.' * K * R) * u_glob;
            tc.verifyEqual(Wglob, Wloc, 'AbsTol', 1e-10, 'RelTol', 1e-10);
        end
    end
end
