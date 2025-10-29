classdef TestCondensation < matlab.unittest.TestCase
    methods (Test)
        function block_elimination_matches_formula(tc)
            K = [10 2 3; 2 5 1; 3 1 7];  f = [1;2;3];
            keep = [1 3];  % e = [1 3], i = [2]

            % manual
            e=[1 3]; i=2;
            Kred = K(e,e) - K(e,i)*(K(i,i)\K(i,e));
            fred = f(e)   - K(e,i)*(K(i,i)\f(i));

            % preserve_size=false
            [Kc, fc] = condensation(K,f,keep,'preserve_size',false);
            tc.verifyEqual(Kc, Kred, 'AbsTol',1e-12);
            tc.verifyEqual(fc, fred, 'AbsTol',1e-12);

            % preserve_size=true
            [Kc2, fc2] = condensation(K,f,keep,'preserve_size',true);
            Z = zeros(3); Z(e,e)=Kred;
            zf = zeros(3,1); zf(e)=fred;
            tc.verifyEqual(Kc2, Z, 'AbsTol',1e-12);
            tc.verifyEqual(fc2, zf, 'AbsTol',1e-12);
        end

        function rhs_reduction_with_known_ui(tc)
            K = [4 1 0; 1 3 2; 0 2 5]; f = [0;0;0];
            keep = 1:2;      % i = 3
            ui = [0];        % known_ui length must equal numel(i)=1
            [Kc, fc] = condensation(K,f,keep,'preserve_size',false,'known_ui',ui);
            tc.verifyEqual(Kc, K(keep,keep), 'AbsTol',1e-12);
            tc.verifyEqual(fc, -K(keep,3)*ui, 'AbsTol',1e-12);
        end

        function logical_vs_index_keepmask(tc)
            K = magic(4); f = (1:4).';
            keepIdx = [1 3];
            keepLog = false(1,4); keepLog(keepIdx)=true;
            [K1,f1]=condensation(K,f,keepIdx,'preserve_size',false);
            [K2,f2]=condensation(K,f,keepLog,'preserve_size',false);
            tc.verifyEqual(K1,K2); tc.verifyEqual(f1,f2);
        end

        function all_or_none_kept(tc)
            K = diag([2 3 4]); f = [1;2;3];
            % all kept
            [K1,f1]=condensation(K,f,1:3,'preserve_size',false);
            tc.verifyEqual(K1,K); tc.verifyEqual(f1,f);
            % none kept -> 0x0 and 0x1
            [K2,f2]=condensation(K,f,[], 'preserve_size',false);
            tc.verifyEqual(size(K2), [0 0]);
            tc.verifyEqual(size(f2), [0 1]);
        end

        function wrong_known_ui_length_errors(tc)
            K = eye(3); f = zeros(3,1);
            tc.verifyError(@()condensation(K,f,[1 2],'known_ui',[1 2]), ...
                           'Kondensation:known_ui_size');
        end
    end
end
