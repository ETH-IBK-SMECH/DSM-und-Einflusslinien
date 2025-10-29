classdef Test_RueckrechnungInternerDOF < matlab.unittest.TestCase
    % Tests for Rueckrechnung_interner_DOF:
    %  - passthrough if no Meta (no condensation)
    %  - reconstructs full free vector identical to direct solve

    methods (Static)
        function M = baseModel(nNodes, nkd)
            % Use ModelBuilder for consistency across tests
            M = tests.util.ModelBuilder.minimal(nNodes, nkd);
        end

        function [K_ff, F_f] = spdSystem(n)
            A    = randn(n);
            K_ff = A'*A + eye(n);
            F_f  = randn(n,1);
        end
    end

    methods (Test)
        function passthroughIfNoMeta(tc)
            % Build a tiny model via ModelBuilder (not strictly needed here)
            tc.baseModel(2, 3);  % just to ensure ModelBuilder loads correctly

            u_kept = randn(5,1);
            u_free = rueckrechnung_interner_DOF(struct(), u_kept);

            tc.verifyEqual(u_free, u_kept);
        end

        function reconstructsFull(tc)
            % Use ModelBuilder to define a consistent DOF scale
            M = tc.baseModel(2, 3);   % nkd=3 (ux,uy,rz), 2 nodes -> n = 6
            n = M.Info.nKnotenDOF * M.Info.nKnoten;  % 3*2 = 6

            % SPD-ish free system
            [K_ff, F_f] = tc.spdSystem(n);

            % Choose some kept DOFs (e-set) and condense the rest (i-set)
            keepMask = false(1, n);
            keepMask([1 3 6]) = true;   % arbitrary kept set of size 3

            % Perform condensation to get reduced system and meta mapping
            [Kred, Fred, meta] = condensation(K_ff, F_f, keepMask, 'preserve_size', false);
            u_kept = Kred \ Fred;

            % Build the KMeta structure as produced by your pipeline
            KMeta = struct();
            KMeta.K_ff_voll = K_ff;
            KMeta.F_f_voll  = F_f;
            KMeta.Meta = struct( ...
                'eIdx',    meta.eIdx, ...
                'iIdx',    meta.iIdx, ...
                'ne', meta.ne, ...
                'n',     meta.n );

            % Reconstruct full free vector and compare against direct solve
            u_recon = rueckrechnung_interner_DOF(KMeta, u_kept);
            u_full  = K_ff \ F_f;

            tc.verifyEqual(u_recon, u_full, 'AbsTol', 1e-10, 'RelTol', 1e-10);
        end
    end
end
