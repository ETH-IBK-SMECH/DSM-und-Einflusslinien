% +tests/unit/TestFedernHinzufuegen.m
classdef TestFedernHinzufuegen < matlab.unittest.TestCase
    methods (Test)
        function adds_diagonals(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M);
            M.Stab = S;
            M.Info.nStaebe = 1;
            [DOF, nDOF, ~] = dofNummerieren(M);
            K = sparse(nDOF, nDOF);
            M.Feder = struct('node', {1, 1}, 'dir', {1, 1}, 'val', {100, 50}); % sum 150
            K2 = federnHinzufuegen(K, M.Feder, DOF, nDOF, 3);
            g = DOF(1);
            tc.verifyEqual(full(K2(g, g)), 150);
            tc.verifyEqual(nnz(K2), 1);
        end
        function ignores_invalid(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            [DOF, nDOF, ~] = dofNummerieren(M);
            K = sparse(nDOF, nDOF);
            M.Feder = struct('node', {99}, 'dir', {1}, 'val', {123});
            K2 = federnHinzufuegen(K, M.Feder, DOF, nDOF, 3);
            tc.verifyEqual(nnz(K2), 0);
        end
    end
end
