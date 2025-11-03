classdef TestGetR < matlab.unittest.TestCase

    methods (Test)
        function size_and_orthonormality(tc)
            ang = linspace(0, 2*pi, 13);
            for a = ang
                c = cos(a);
                s = sin(a);
                R = getR(c, s);
                tc.verifySize(R, [6, 6]);
                tc.verifyEqual(R.'*R, eye(6), 'AbsTol', 1e-12);
                tc.verifyEqual(det(R), 1, 'AbsTol', 1e-12);
            end
        end

        function propagates_nan_inputs(tc)
            R = getR(NaN, 0);
            tc.verifyTrue(any(isnan(R(:))));
        end
    end
end
