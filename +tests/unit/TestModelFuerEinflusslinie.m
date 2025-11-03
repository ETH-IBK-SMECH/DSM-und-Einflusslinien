classdef TestModelFuerEinflusslinie < matlab.unittest.TestCase
    % Tests for ModelFuerEinflusslinie (model rewiring for influence lines)

    methods (Test)
        % TypEL=4: adds an SPC (node,dir,val=-1) and returns early
        function typ4_adds_spc_only(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            S.Iy = tests.util.Const.I;
            M.Stab = S;
            M.Info.nStaebe = 1;
            M.SPC = struct([]);
            M.Einflusslinie = struct('TypEL', 4, 'Knoten', 2, 'Richtung', 1);

            out = modelFuerEinflusslinie(M);

            tc.verifyEqual(numel(out.SPC), 1);
            tc.verifyEqual(out.SPC(1).node, 2);
            tc.verifyEqual(out.SPC(1).dir, 1);
            tc.verifyEqual(out.SPC(1).val, -1);
            % Nothing else changed materially
            tc.verifyEqual(out.Knoten, M.Knoten);
            tc.verifyEqual(numel(out.Stab), 1);
        end

        % TypEL=1..3: splits one bar at Stelle, creates twin nodes & two bars
        function split_bar_creates_twin_nodes_and_updates_fields(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            % bar from (0,0) to (1,0)
            M.Knoten(1).x = 0;
            M.Knoten(1).y = 0;
            M.Knoten(2).x = 1;
            M.Knoten(2).y = 0;
            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            S.Iy = tests.util.Const.I;
            M.Stab = S;
            M.Info.nStaebe = 1;
            M.Info.nKnoten = 2;
            M.SPC = struct([]);
            M.Einflusslinie = struct('TypEL', 1, 'Stab', 1, 'Stelle', 0.3); % cut at 30%

            out = modelFuerEinflusslinie(M);

            % Two new nodes at the same coordinates (0.3,0)
            tc.assertGreaterThan(numel(out.Knoten), 2);
            xnew = 0.3;
            ynew = 0;
            % The last two nodes are the cut pair:
            N = numel(out.Knoten);
            tc.verifyEqual([out.Knoten(N-1).x, out.Knoten(N-1).y], [xnew, ynew], 'AbsTol', 1e-12);
            tc.verifyEqual([out.Knoten(N).x, out.Knoten(N).y], [xnew, ynew], 'AbsTol', 1e-12);

            % Old bar removed, two bars added
            tc.verifyEqual(numel(out.Stab), 2);
            % cutNodes set to the two new nodes
            tc.verifyEqual(out.Einflusslinie.cutNodes, [N - 1, N]);
            % keepMask provided (all true by default)
            tc.verifyTrue(isfield(out.Einflusslinie, 'keepMask'));
            tc.verifyTrue(all(out.Einflusslinie.keepMask));
        end

        % Repeated calls update Info counts and preserve required fields
        function updates_info_counts(tc)
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2);
            S.Iy = tests.util.Const.I;
            M.Stab = S;
            M.Info.nStaebe = 1;
            M.Info.nKnoten = 2;
            M.SPC = struct([]);
            M.Einflusslinie = struct('TypEL', 3, 'Stab', 1, 'Stelle', 0.5);

            out = modelFuerEinflusslinie(M);

            tc.verifyEqual(out.Info.nKnoten, numel(out.Knoten));
            tc.verifyEqual(out.Info.nStaebe, numel(out.Stab));
            % Required auxiliary fields exist
            req = {'Feder', 'KnotenLast', 'StabLast'};
            for k = 1:numel(req)
                tc.verifyTrue(isfield(out, req{k}));
            end
        end
    end
end
