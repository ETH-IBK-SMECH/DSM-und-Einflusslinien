classdef TestLocalStiffness < matlab.unittest.TestCase

    methods (Test)

        function symmetricK(testCase)
            E = 210e9;
            A = 0.02;
            I = 8e-6;
            L = 3.0;
            k = getK(E, A, I, L);
            testCase.verifyEqual(k, k.', 'AbsTol', 1e-12)
        end

    end

end
