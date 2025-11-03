classdef TestGetK < matlab.unittest.TestCase
    % Unit tests for getK(E,A,I,L)
    % Checks symmetry, scaling, and invalid input behavior.

    methods (Test)
        function basic_properties(tc)
            C = tests.util.Const;
            K = getK(C.E, C.A, C.I, C.L);

            tc.verifySize(K, [6, 6]);
            tc.verifyEqual(K, K.', 'AbsTol', C.ABS, ...
                'Matrix should be symmetric');
        end

        function scales_with_E(tc)
            C = tests.util.Const;
            K1 = getK(C.E, C.A, C.I, C.L);
            K2 = getK(2*C.E, C.A, C.I, C.L);

            tc.verifyEqual(K2, 2*K1, ...
                'RelTol', C.REL, 'AbsTol', C.ABS, ...
                'K should scale linearly with E');
        end

        function invalid_length(tc)
            C = tests.util.Const;
            K = getK(C.E, C.A, C.I, 0);

            tc.verifyTrue(any(~isfinite(K(:))), ...
                'Expected Inf/NaN entries for L = 0 (division by zero)');
        end
    end
end
