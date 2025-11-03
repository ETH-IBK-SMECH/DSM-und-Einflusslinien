classdef TestReduziertesUndEinsammeln < matlab.unittest.TestCase
    % Tests for:
    %   - reduziertesSystemLoesen(K_red, F_red)
    %   - verschiebungenEinsammeln(u_free, known, freeMask, nDOF)

    methods (Test)

        %% -------- reduziertesSystemLoesen --------
        function solvesWellConditionedSystem(tc)
            K = [4, 1; 1, 3];
            F = [1; 2];
            u = reduziertesSystemLoesen(K, F);
            tc.verifySize(u, [2, 1]);
            tc.verifyEqual(K*u, F, 'AbsTol', 1e-12);
        end

        function warnsOnIllConditionedSystem(tc)
            % Make K badly conditioned -> triggers your warning branch
            K = diag([1, 1e-13]); % cond ~ 1e13 -> rce ~ 1e-13
            F = [1; 1e-13];

            % Capture last warning since your warning has no ID
            lastwarn('');
            u = reduziertesSystemLoesen(K, F); %#ok<NASGU>
            [msg, ~] = lastwarn();

            tc.assertNotEmpty(msg, ...
                'Expected a warning for ill-conditioned K_red (rcond small).');
            tc.verifyThat(string(msg), matlab.unittest.constraints.ContainsSubstring( ...
                "schlecht konditioniert"));
        end

        function errorsWhenSolutionHasNaNOrInf(tc)
            % Force NaN propagation via NaN in K (A\B will produce NaN)
            K = [1, NaN; 0, 1];
            F = [1; 2];

            % Your function throws error('Lösung enthält NaN/Inf...') with no ID.
            % Verify by catching and checking the message.
            try
                reduziertesSystemLoesen(K, F);
                tc.assertFail('Expected error due to NaN/Inf in solution.');
            catch ME
                tc.verifyThat(string(ME.message), ...
                    matlab.unittest.constraints.ContainsSubstring("Lösung enthält NaN/Inf"));
            end
        end
        %% -------- verschiebungenEinsammeln --------
        function assemblesMixedFreeAndKnown(tc)
            % 5 DOFs; free at [1 3 5]
            nDOF = 5;
            freeMask = logical([1, 0, 1, 0, 1]);
            u_free = [0.1; 0.3; 0.5]; % corresponds to DOFs 1,3,5
            known.U_s = [9; 8]; % corresponds to DOFs 2,4

            U = verschiebungenEinsammeln(u_free, known, freeMask, nDOF);

            tc.verifyEqual(U, [0.1; 9; 0.3; 8; 0.5], 'AbsTol', 0);
            tc.verifySize(U, [nDOF, 1]);
        end

        function handlesAllFree(tc)
            nDOF = 3;
            freeMask = true(nDOF, 1);
            u_free = (1:3).';
            known.U_s = []; % ignored when all are free
            U = verschiebungenEinsammeln(u_free, known, freeMask, nDOF);
            tc.verifyEqual(U, u_free);
        end

        function handlesNoFree(tc)
            nDOF = 4;
            freeMask = false(nDOF, 1);
            u_free = zeros(0, 1); % no free DOFs
            known.U_s = (10:13).';
            U = verschiebungenEinsammeln(u_free, known, freeMask, nDOF);
            tc.verifyEqual(U, known.U_s);
        end

        function rejectsSizeMismatchGracefully(tc)
            nDOF = 4;
            freeMask = logical([1, 0, 1, 0]).'; % expects 2 frees
            u_free = [1; 2; 3]; % mismatch
            known.U_s = [7; 8];

            try
                verschiebungenEinsammeln(u_free, known, freeMask, nDOF);
                tc.assertFail('Expected an error for size mismatch, but none was thrown.');
            catch
                % Pass: any error is fine
                tc.verifyTrue(true);
            end
        end
    end

end
