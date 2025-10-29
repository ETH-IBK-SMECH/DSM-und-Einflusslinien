classdef TestRandbedingungenKondensierenEinflusslinie < matlab.unittest.TestCase
% Tests for randbedingungenKondensierenEinflusslinie (TypEL 1..3 via LMs)

    methods (Test)
        % Happy path: 2 nodes, nkd=3, keep all 3 comps; TypEL=1 (negative sign)
        function builds_augmented_system_and_sign_for_typ1(tc)
            nkd = 3;
            DOF = (1:6).';             % node1:1..3, node2:4..6
            n   = numel(DOF);
            K_sys = sparse(n,n);       % focus on A blocks
            F_sys = zeros(n,1);
            SPC   = struct([]);        % none

            Ein = struct('cutNodes',[1 2], 'keepMask',true(1,nkd), 'TypEL',1);

            out = randbedingungenKondensierenEinflusslinie(K_sys,F_sys,SPC,DOF,nkd,Ein);

            % m = 3 LM eqs (ux, uy, rz) kept
            tc.verifyEqual(out.nLM, 3);
            % No SPC, so all (n+m) are "free" → K_sys_ff is full K_aug (size 9x9)
            tc.verifySize(out.K_sys_ff, [n+3, n+3]);
            % F2 row for TypEL=1 should be -1 at the row corresponding to comp=1
            % (since your code sets F2(p) = -1 for comp~=2)
            % With no SPC: F_sys_f_kond equals [F_sys; F2]
            tc.verifyEqual(out.F_sys_f_kond(end-2:end), [-1; 0; 0]);
            % All physical DOFs unpinned → phys_freeMask all true, known_U_vector empty
            tc.verifyTrue(all(out.phys_freeMask));
            tc.verifyEmpty(out.known_U_vector);
        end

        % Keep mask filtering + TypEL=2 (positive sign)
        function keepmask_filters_components_and_sign_for_typ2(tc)
            nkd = 3;
            DOF = (1:6).';
            n   = numel(DOF);
            K_sys = sparse(n,n); F_sys = zeros(n,1); SPC = struct([]);

            % keepMask keeps only comp 1 and 3 → m=2
            Ein = struct('cutNodes',[1 2], 'keepMask',[true false true], 'TypEL',2);

            out = randbedingungenKondensierenEinflusslinie(K_sys,F_sys,SPC,DOF,nkd,Ein);

            tc.verifyEqual(out.nLM, 2);
            % TypEL=2 → +1 on the row that corresponds to comp=2; but comp 2 is filtered out,
            % so no +1 should appear. F2 thus all zeros.
            tc.verifyEqual(out.F_sys_f_kond(end-1:end), [0; 0]);
            tc.verifySize(out.K_sys_ff, [n+2, n+2]);
        end

        % SPC application: one physical DOF known must move to 'known' side
        function applies_spc_on_physical_dofs(tc)
            nkd = 3;
            DOF  = (1:6).';
            n    = numel(DOF);
            K_sys = sparse(n,n); F_sys = zeros(n,1);

            % Fix node1,dir1 = 0.1
            SPC(1).node = 1; SPC(1).dir = 1; SPC(1).val = 0.1;

            Ein = struct('cutNodes',[1 2], 'keepMask',true(1,nkd), 'TypEL',3);

            out = randbedingungenKondensierenEinflusslinie(K_sys,F_sys,SPC,DOF,nkd,Ein);

            % One physical DOF known
            tc.verifyEqual(nnz(~out.phys_freeMask), 1);
            % known_U_vector stores only physical knowns (length equals that 1)
            tc.verifyEqual(numel(out.known_U_vector), 1);
            tc.verifyEqual(out.known_U_vector(1), 0.1, 'AbsTol', 1e-12);
        end

        % Error if no active pairs remain at the cut (keepMask culls everything)
        function errors_if_no_active_pairs(tc)
            nkd = 3;
            DOF  = (1:6).';
            K_sys = sparse(6,6); F_sys = zeros(6,1); SPC = struct([]);

            Ein = struct('cutNodes',[1 2], 'keepMask',[false false false], 'TypEL',1);

            tc.verifyError(@() randbedingungenKondensierenEinflusslinie(K_sys,F_sys,SPC,DOF,nkd,Ein), ...
                           ''); % accept any error
        end

        % Works even when some DOFs are inactive on one side (DOF==0) and masked out
        function ignores_inactive_dofs_at_cut(tc)
            nkd = 3;
            DOF = (1:6).';
            % Deactivate node2,dir3 by setting DOF entry to 0:
            DOF(6) = 0;                 % node2 rz inactive
            K_sys = sparse(6,6); F_sys = zeros(6,1); SPC = struct([]);
            Ein = struct('cutNodes',[1 2], 'keepMask',true(1,nkd), 'TypEL',1);

            out = randbedingungenKondensierenEinflusslinie(K_sys,F_sys,SPC,DOF,nkd,Ein);

            % rz should have been dropped → m = 2 (ux, uy)
            tc.verifyEqual(out.nLM, 2);
            % Sizes reflect m=2
            tc.verifySize(out.K_sys_ff, [6+2, 6+2]);
        end
    end
end
