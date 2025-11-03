classdef Const
    % Shared constants for tests (tweak once, used everywhere)
    properties (Constant)
        E = 210e9
        A = 0.01
        I = 1e-5
        L = 2.0
        ABS = 1e-12
        REL = 1e-12
        ANG = pi / 7
    end
    methods (Static)
        function R = R6(a)
            if nargin == 0, a = tests.util.Const.ANG; end
            R = getR(cos(a), sin(a));
        end
        function K = K6(E, A, I, L)
            % Convenience wrapper (defaults to Const values)
            if nargin < 1 || isempty(E), E = tests.util.Const.E; end
            if nargin < 2 || isempty(A), A = tests.util.Const.A; end
            if nargin < 3 || isempty(I), I = tests.util.Const.I; end
            if nargin < 4 || isempty(L), L = tests.util.Const.L; end
            K = getK(E, A, I, L);
        end
    end
end
