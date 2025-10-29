classdef TestIsOrientation < matlab.unittest.TestCase
    % Unit tests for:
    %   [isH, isV] = isOrientation(c, s, tol)
    %
    % Behavior covered:
    %   - Exact horizontal/vertical detection
    %   - Tolerance band around axes
    %   - Renormalization when ||(c,s)|| ~= 1
    %   - Degenerate input (near-zero vector)
    %   - Generic non-axis angles

    methods (Test)
        function exact_axes(tc)
            % 0 rad -> horizontal
            [h, v] = isOrientation(1, 0);
            tc.verifyTrue(h);
            tc.verifyFalse(v);

            % pi/2 -> vertical
            [h, v] = isOrientation(0, 1);
            tc.verifyFalse(h);
            tc.verifyTrue(v);

            % pi -> horizontal (cos = -1)
            [h, v] = isOrientation(-1, 0);
            tc.verifyTrue(h);
            tc.verifyFalse(v);
        end

        function tolerance_band(tc)
            tol = 1e-6;

            % Slightly off horizontal: s within tol -> still horizontal
            [h, v] = isOrientation(cos(1e-7), sin(1e-7), tol);
            tc.verifyTrue(h);
            tc.verifyFalse(v);

            % Slightly off vertical: c within tol -> still vertical
            [h, v] = isOrientation(cos(pi/2 + 1e-7), sin(pi/2 + 1e-7), tol);
            tc.verifyFalse(h);
            tc.verifyTrue(v);

            % Outside tol -> neither horizontal nor vertical
            [h, v] = isOrientation(cos(1e-3), sin(1e-3), tol);
            tc.verifyFalse(h);
            tc.verifyFalse(v);
        end

        function renormalization_works(tc)
            % Angle 30°, but scaled vector (2c, 2s) should be renormalized internally
            a = pi/6; c = cos(a); s = sin(a);
            [h1, v1] = isOrientation(c, s);
            [h2, v2] = isOrientation(2*c, 2*s); % not unit length
            tc.verifyEqual([h2 v2], [h1 v1]);   % same classification
            tc.verifyFalse(h1);
            tc.verifyFalse(v1);
        end

        function degenerate_zero_vector(tc)
            % If (c,s) ~ (0,0): n <= eps branch -> no renormalization
            % Classification falls back to |s|<tol and |c|<tol -> both true
            [h, v] = isOrientation(0, 0);
            tc.verifyTrue(h,  'With c=s=0, |s|<tol holds → horizontal');
            tc.verifyTrue(v,  'With c=s=0, |c|<tol holds → vertical');
        end

        function generic_non_axis_angles(tc)
            % 37 degrees → neither horizontal nor vertical
            a = 37*pi/180;
            [h, v] = isOrientation(cos(a), sin(a));
            tc.verifyFalse(h);
            tc.verifyFalse(v);

            % 89.9 degrees with default tol (1e-12) → still not vertical exactly
            a = 89.9*pi/180;
            [h, v] = isOrientation(cos(a), sin(a)); % default tol is very tight
            tc.verifyFalse(h);
            tc.verifyFalse(v);
        end
    end
end
