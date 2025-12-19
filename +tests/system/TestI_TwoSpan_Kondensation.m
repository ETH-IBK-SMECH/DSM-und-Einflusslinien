classdef TestI_TwoSpan_Kondensation < matlab.unittest.TestCase
    % Integration + unit tests for the new static condensation logic on a two-span beam.
    %
    % Covers:
    %   - Statische_Kondensation_durchfuehren (none, full-node, partial components)
    %   - Rueckrechnung_interner_DOF (reconstruct internals = full free solution)
    %   - dofsZuKondensieren (mapping nodes/components → free DOF keep mask)
    %   - Equivalence Full vs Condensed on external DOFs & reactions
    %   - Rotation invariance with condensation present

    properties
        C % tests.util.Const
        M2 % base two-span model (no loads)
    end

    methods (TestClassSetup)
        function build_two_span_base(tc)
            tc.C = tests.util.Const;
            E = tc.C.E;
            A = tc.C.A;
            I = tc.C.I;
            L = tc.C.L;

            % 3 nodes: (0,0) (L,0) (2L,0)
            M = tests.util.ModelBuilder.minimal(3, 3);
            M.Knoten(1).x = 0;
            M.Knoten(1).y = 0;
            M.Knoten(2).x = L;
            M.Knoten(2).y = 0;
            M.Knoten(3).x = 2 * L;
            M.Knoten(3).y = 0;

            % Bars 1:(1-2), 2:(2-3)
            S1 = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2, E, A, I);
            S1.L = L;
            S2 = tests.util.ModelBuilder.oneBarHoriz(M, 2, 3, E, A, I);
            S2.L = L;
            M.Stab = [S1; S2];
            M.Info.nStaebe = 2;
            M.Info.nKnotenDOF = 3;

            % Pinned at nodes 1,2,3 in ux,uy (rz free)
            SPC = repmat(struct('node', 1, 'dir', 1, 'val', 0), 0, 1);
            for node = [1, 2, 3]
                for dir = 1:2
                    SPC(end+1, 1) = struct('node', node, 'dir', dir, 'val', 0); %#ok<AGROW>
                end
            end
            M.SPC = SPC;
            M.Info.nSPC = numel(SPC);

            tc.M2 = M;
        end
    end

    methods (Test)

        function full_vs_noCondensation_are_identical(tc)
            % Sanity: if no model.Kondensation is present, pipeline is unchanged
            M = tc.M2;
            M.StabLast = struct('stab', 2, 'typ', 2, 'dir', 2, 'val', -10e3, 'sDist', 0.5, 'eDist', []);
            M.Info.nStabLasten = 1;

            out1 = tests.util.it_run_main(M);

            % Add an empty/invalid condensation block → should no-op
            M.Kondensation = []; % explicitly empty
            out2 = tests.util.it_run_main(M);

            tc.verifyEqual(out2.U_sys, out1.U_sys, 'AbsTol', 1e-12, 'RelTol', 1e-12);
            tc.verifyEqual(sum([out2.SPC.Reaktion]), sum([out1.SPC.Reaktion]), 'AbsTol', 1e-9);
        end

        function condense_middle_node_all_components_matches_full_external(tc)
            % Condense node 2 (ux,uy,rz) and compare external DOFs & reactions to full
            P = -10e3;

            % ---- Full
            Mf = tc.M2;
            Mf.StabLast = struct('stab', 2, 'typ', 2, 'dir', 2, 'val', P, 'sDist', 0.5, 'eDist', []);
            Mf.Info.nStabLasten = 1;
            outF = tests.util.it_run_main(Mf);

            % ---- Condensed: node 2 all components internal
            Mc = tc.M2;
            Mc.StabLast = Mf.StabLast;
            Mc.Info.nStabLasten = 1;
            Mc.Kondensation = struct('Knoten', 2, 'KomponentenMaske', logical([1, 1, 1]));
            outC = tests.util.it_run_main(Mc);

            % Compare external DOFs (nodes 1 & 3)
            [gextF, gextC] = externalDOFs(outF, outC, [1, 3]);
            tc.verifyEqual(outC.U_sys(gextC), outF.U_sys(gextF), 'RelTol', 1e-9, 'AbsTol', 1e-9);

            % Compare support reactions at nodes 1 & 3
            rF = collectReactions(outF, [1, 3]);
            rC = collectReactions(outC, [1, 3]);
            tc.verifyEqual(rC, rF, 'RelTol', 1e-7, 'AbsTol', 1e-5);
        end

        function condense_middle_node_partial_components_matches_full_external(tc)
            % Condense only ux at node 2, leave (uy,rz) in the system
            q = -8e3;
            nkd = tc.M2.Info.nKnotenDOF;

            % ---- Full (UDL on both spans)
            Mf = tc.M2;
            Mf.StabLast = [ ...
                struct('stab', 1, 'typ', 2+nkd, 'dir', 2, 'val', q, 'sDist', 0.0, 'eDist', 1.0); ...
                struct('stab', 2, 'typ', 2+nkd, 'dir', 2, 'val', q, 'sDist', 0.0, 'eDist', 1.0), ...
                ];
            Mf.Info.nStabLasten = numel(Mf.StabLast);
            outF = tests.util.it_run_main(Mf);

            % ---- Condense only ux at node 2
            Mc = tc.M2;
            Mc.StabLast = Mf.StabLast;
            Mc.Info.nStabLasten = Mf.Info.nStabLasten;
            Mc.Kondensation = struct('Knoten', 2, 'KomponentenMaske', logical([1, 0, 0]));
            outC = tests.util.it_run_main(Mc);

            % External DOFs (nodes 1 & 3)
            [gextF, gextC] = externalDOFs(outF, outC, [1, 3]);
            tc.verifyEqual(outC.U_sys(gextC), outF.U_sys(gextF), 'RelTol', 1e-9, 'AbsTol', 1e-9);

            % Reactions equal
            rF = collectReactions(outF, [1, 3]);
            rC = collectReactions(outC, [1, 3]);
            tc.verifyEqual(rC, rF, 'RelTol', 1e-7, 'AbsTol', 1e-5);
        end

        function rotation_invariance_with_condensation(tc)
            % Rotate geometry; condense node 2 (all comps); Full vs Condensed external equivalence
            theta = pi / 10;
            P = -12e3;

            Mf = rotateAll(tc.M2, theta);
            Mf.StabLast = struct('stab', 1, 'typ', 2, 'dir', 2, 'val', P, 'sDist', 0.5, 'eDist', []);
            Mf.Info.nStabLasten = 1;
            outF = tests.util.it_run_main(Mf);

            Mc = rotateAll(tc.M2, theta);
            Mc.StabLast = Mf.StabLast;
            Mc.Info.nStabLasten = 1;
            Mc.Kondensation = struct('Knoten', 2, 'KomponentenMaske', logical([1, 1, 1]));
            outC = tests.util.it_run_main(Mc);

            [gextF, gextC] = externalDOFs(outF, outC, [1, 3]);
            tc.verifyEqual(outC.U_sys(gextC), outF.U_sys(gextF), 'RelTol', 1e-9, 'AbsTol', 1e-9);

            rF = collectReactions(outF, [1, 3]);
            rC = collectReactions(outC, [1, 3]);
            tc.verifyEqual(rC, rF, 'RelTol', 1e-7, 'AbsTol', 1e-5);
        end

        function rueckrechnung_rebuilds_internal_equals_full_free_solution(tc)
            P = -7.5e3;

            % Full
            Mf = tc.M2;
            Mf.StabLast = struct('stab', 2, 'typ', 2, 'dir', 2, 'val', P, 'sDist', 0.5, 'eDist', []);
            Mf.Info.nStabLasten = 1;
            outF = tests.util.it_run_main(Mf);

            % Condensed (node 2, all comps)
            Mc = tc.M2;
            Mc.StabLast = Mf.StabLast;
            Mc.Info.nStabLasten = 1;
            Mc.Kondensation = struct('Knoten', 2, 'KomponentenMaske', logical([1, 1, 1]));
            outC = tests.util.it_run_main(Mc);

            % Ensure pipeline exposed data
            tc.verifyTrue(isfield(outC, 'kond') && isfield(outC.kond, 'K_ff_voll') && ~isempty(outC.kond.K_ff_voll), ...
                'Pipeline must export K_ff_voll/F_f_voll/Meta on out.kond.');
            tc.verifyTrue(isfield(outC, 'u_kept') && ~isempty(outC.u_kept), ...
                'Pipeline must export reduced kept solution as out.u_kept.');

            % Back-substitute (free-space)
            u_recon = rueckrechnung_interner_DOF(outC.kond, outC.u_kept);

            % Expand to GLOBAL space using the condensed run's free-mask
            U_recon = zeros(size(outC.DOF)); % global-length vector
            U_recon(outC.kond.f) = u_recon; % place free DOFs; fixed DOFs remain 0

            % Compare global displacement vectors
            tc.verifyEqual(U_recon(:), outF.U_sys, 'RelTol', 1e-10, 'AbsTol', 1e-10);

        end


        function unit_dofsZuKondensieren_mapping(tc)
            % Arrange
            M = tc.M2;
            nkd = M.Info.nKnotenDOF;

            [DOF, ~, ~] = dofNummerieren(M);

            % Build the free list and a fast map globalDOF -> positionInFree
            freeList = find(DOF(:) > 0); % global IDs of free DOFs
            n_free = numel(freeList);
            posMap = zeros(max(freeList), 1); % inverse map (global -> free-pos)
            posMap(freeList) = 1:n_free;

            % Select: all 3 comps at node 2 should be made "internal"
            comp = logical([1, 1, 1]);

            freeList = find(DOF(:) > 0);          % global IDs of free DOFs (this is your assumed free ordering)
            kond = struct('DOF', freeList(:));    % current impl expects kond.DOF(:) == find(kond.f)
            mask_keep_ff = dofsZuKondensieren(M, DOF, kond, 2, comp);

            % Assert size
            tc.verifyEqual(numel(mask_keep_ff), n_free, ...
                'Keep mask length must equal number of free DOFs.');

            % Global indices of node 2's DOFs
            idx2 = (2 - 1) * nkd + (1:nkd); % local DOF slots for node 2
            g2 = DOF(idx2); % global DOF IDs (0 if constrained)
            g2 = g2(g2 > 0); % keep only free ones

            % Map those global IDs to positions in the free vector
            p2 = posMap(g2); % positions in mask_keep_ff

            % Those positions must be FALSE (i.e., "internal" → not kept)
            tc.verifyFalse(any(mask_keep_ff(p2)), ...
                'Node 2 components should be marked internal (keep=false) in the free-DOF mask.');
        end

    end
end

% -------------------- local helpers -------------------

function [gextF, gextC] = externalDOFs(outF, outC, nodeList)
nkd = outF.Info.nKnotenDOF;
gextF = [];
gextC = [];
for n = nodeList(:).'
    gf = outF.DOF((n - 1)*nkd+(1:nkd));
    gf = gf(gf > 0);
    gc = outC.DOF((n - 1)*nkd+(1:nkd));
    gc = gc(gc > 0);
    gextF = [gextF; gf(:)]; %#ok<AGROW>
    gextC = [gextC; gc(:)]; %#ok<AGROW>
end
end

function r = collectReactions(out, nodes)
rx = [];
ry = [];
mz = [];
for n = nodes(:).'
    rx = [rx, sum([out.SPC([out.SPC.node] == n & [out.SPC.dir] == 1).Reaktion])]; %#ok<AGROW>
    ry = [ry, sum([out.SPC([out.SPC.node] == n & [out.SPC.dir] == 2).Reaktion])]; %#ok<AGROW>
    mv = [out.SPC([out.SPC.node] == n & [out.SPC.dir] == 3).Reaktion];
    mz = [mz, (isempty(mv) * 0) + (~isempty(mv) * sum(mv))]; %#ok<AGROW>
end
r = [rx; ry; mz];
r = r(:).';
end

function M = rotateAll(M, theta)
x0 = M.Knoten(1).x;
y0 = M.Knoten(1).y;
c = cos(theta);
s = sin(theta);
for k = 1:numel(M.Knoten)
    x = M.Knoten(k).x - x0;
    y = M.Knoten(k).y - y0;
    M.Knoten(k).x = x0 + c * x - s * y;
    M.Knoten(k).y = y0 + s * x + c * y;
end
end
