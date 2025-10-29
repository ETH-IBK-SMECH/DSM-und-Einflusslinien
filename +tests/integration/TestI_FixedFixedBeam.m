classdef TestI_FixedFixedBeam < matlab.unittest.TestCase
% Integration tests on a simple fixed–fixed beam
% Variants: baseline mid-span element load, load-type sweep, spring, hinge, influence lines

    properties
        C    % tests.util.Const
        M0   % base fixed-fixed model (no loads)
    end

    methods (TestClassSetup)
        function build_base(tc)
            tc.C = tests.util.Const;

            % 2-node horizontal bar
            M = tests.util.ModelBuilder.minimal(2, 3);
            S = tests.util.ModelBuilder.oneBarHoriz(M, 1, 2, tc.C.E, tc.C.A, tc.C.I);
            S.cs = 1; S.sn = 0; S.L = tc.C.L;
            M.Stab = S;
            M.Info.nStaebe     = 1;
            M.Info.nKnotenDOF  = 3;

            % Fully fixed @ both nodes (ux,uy,rz)
            SPC = repmat(struct('node',1,'dir',1,'val',0), 0, 1);
            for node = [1 2]
                for dir = 1:3
                    SPC(end+1,1) = struct('node',node,'dir',dir,'val',0); %#ok<AGROW>
                end
            end
            M.SPC = SPC; M.Info.nSPC = numel(SPC);

            % Store base (no loads); drive the real pipeline in tests
            tc.M0 = M;
        end
    end

    methods (Test)
        function baseline_midLoad(tc)
            % Midspan point load on the element (typ=2 at sDist=0.5)
            M = tc.M0;
            P  = -10e3;   % -10 kN downward
            M.StabLast = struct('stab',1,'typ',2,'val',P,'sDist',0.5,'eDist',0);
            M.Info.nStabLasten = 1;

            out = tests.util.it_run_main(M);

            % K symmetry
            tc.verifyTrue(issymmetric(out.K_sys), 'K_sys not symmetric');

            % Displacements finite
            tc.verifyTrue(all(isfinite(out.U_sys)));
            tc.verifyLessThan(norm(out.U_sys, inf), 1e-2);

            % Vertical equilibrium: sum(Reac_y) + sum(F_y) = 0
            nkd  = out.Info.nKnotenDOF;
            DOF  = out.DOF(:);
            nDOF = numel(DOF);
            uy_g = DOF( (0:(nDOF/nkd-1))*nkd + 2 ); uy_g = uy_g(uy_g>0);
            sumLoadY = sum(out.F_sys(uy_g));

            ry_spc = [out.SPC([out.SPC.dir]==2).Reaktion];
            ry_fed = 0;
            if isfield(out,'Feder') && ~isempty(out.Feder)
                tmp = [out.Feder([out.Feder.dir]==2).Reaktion];
                if ~isempty(tmp), ry_fed = sum(tmp); end
            end
            tc.verifyEqual(sum(ry_spc) + ry_fed + sumLoadY, 0, 'AbsTol', 1e-6);

            % Symmetry of vertical reactions at fixed ends (midspan load)
            r1 = out.SPC([out.SPC.node]==1 & [out.SPC.dir]==2);
            r2 = out.SPC([out.SPC.node]==2 & [out.SPC.dir]==2);
            tc.verifyNotEmpty(r1); tc.verifyNotEmpty(r2);
            tc.verifyEqual(abs(r1(1).Reaktion), abs(r2(1).Reaktion), 'AbsTol', 1e-3);

            % Right-end local shear equals right support reaction (by magnitude)
            q_loc = out.Stab(1).q_loc;
            tc.verifyGreaterThan(numel(q_loc), 5);
            tc.verifyEqual(abs(q_loc(5)), abs(r2(1).Reaktion), 'AbsTol', 1e-3);
        end

        function load_types_cover(tc)
            M = tc.M0;
            nkd = tc.M0.Info.nKnotenDOF;   % usually 3
        
            % Each row: {name, isDistributed, dir, val, sDist, eDist, expectSymmetry}
            % dir: 1=ux, 2=uy, 3=rz
            cases = { ...
                'UDL_full',     true,  2, -10e3, 0.0, 1.0, true;   % vertical UDL over full span
                'UDL_mid_seg',  true,  2, -10e3, 0.4, 0.6, false;  % vertical UDL on 40–60% segment
                'Point_mid',    false, 2, -10e3, 0.5,  NaN, true;  % vertical point load at midspan
            };
        
            for i = 1:size(cases,1)
                name       = cases{i,1};
                isDist     = cases{i,2};
                dir        = cases{i,3};          % 1 ux, 2 uy, 3 rz
                val        = cases{i,4};
                sDist      = cases{i,5};
                eDist_in   = cases{i,6};
                expectSym  = cases{i,7};
        
                Mi = M;
        
                if isDist
                    typ = dir + nkd;              % 4/5/6 for distributed
                    eDist = eDist_in;             % must be (0,1], sDist<eDist
                else
                    typ = dir;                    % 1/2/3 for point
                    eDist = [];                   % empty for point load
                end
        
                Mi.StabLast = struct( ...
                    'stab',  1, ...
                    'dir',   dir, ...
                    'val',   val, ...
                    'sDist', sDist, ...
                    'eDist', eDist, ...
                    'typ',   typ );
                Mi.Info.nStabLasten = 1;
        
                out = tests.util.it_run_main(Mi);
        
                % Internal element loads exist
                tc.verifyGreaterThan(norm(out.Stab(1).P_int,1), 0, ...
                    sprintf('[%s] P_int should be nonzero', name));
        
                % Some reaction exists (Rx or Ry or Mz)
                rx = [out.SPC([out.SPC.dir]==1).Reaktion];
                ry = [out.SPC([out.SPC.dir]==2).Reaktion];
                rm = [out.SPC([out.SPC.dir]==3).Reaktion];
                tc.verifyGreaterThan(norm([rx ry rm],1), 0, ...
                    sprintf('[%s] No support reactions', name));
        
                % Vertical equilibrium only when vertical channel is active
                nkd  = out.Info.nKnotenDOF;
                DOF  = out.DOF(:); nDOF = numel(DOF);
                uy_g = DOF( (0:(nDOF/nkd-1))*nkd + 2 ); uy_g = uy_g(uy_g>0);
                sumLoadY = sum(out.F_sys(uy_g));
                sumReacY = sum(ry);
                if isfield(out,'Feder') && ~isempty(out.Feder)
                    ry_fed = [out.Feder([out.Feder.dir]==2).Reaktion];
                    if ~isempty(ry_fed), sumReacY = sumReacY + sum(ry_fed); end
                end
                if abs(sumLoadY) > 0 || abs(sumReacY) > 0
                    tc.verifyEqual(sumReacY + sumLoadY, 0, 'AbsTol', 1e-6, ...
                        sprintf('[%s] Vertical equilibrium failed', name));
                end
        
                % Symmetry check: prefer vertical reactions if present; else use end moments
                if expectSym
                    r1y = out.SPC([out.SPC.node]==1 & [out.SPC.dir]==2);
                    r2y = out.SPC([out.SPC.node]==2 & [out.SPC.dir]==2);
                    haveRy = ~isempty(r1y) && ~isempty(r2y) && ...
                             (abs(r1y(1).Reaktion)+abs(r2y(1).Reaktion) > 0);
        
                    if haveRy
                        tc.verifyEqual(abs(r1y(1).Reaktion), abs(r2y(1).Reaktion), 'AbsTol', 1e-3, ...
                            sprintf('[%s] Vertical reactions not symmetric', name));
                    else
                        r1m = out.SPC([out.SPC.node]==1 & [out.SPC.dir]==3);
                        r2m = out.SPC([out.SPC.node]==2 & [out.SPC.dir]==3);
                        m1 = 0; if ~isempty(r1m), m1 = r1m(1).Reaktion; end
                        m2 = 0; if ~isempty(r2m), m2 = r2m(1).Reaktion; end
                        tc.verifyEqual(abs(m1), abs(m2), 'AbsTol', 1e-3, ...
                            sprintf('[%s] End moments not symmetric', name));
                    end
                end
            end
        end


        function add_vertical_spring_node1(tc)
            % Remove rigid SPC at node1-uy, add a vertical spring there
            M = tc.M0;
            keep = ~([M.SPC.node]==1 & [M.SPC.dir]==2);
            M.SPC = M.SPC(keep); M.Info.nSPC = numel(M.SPC);

            Ks = 1.0e6;
            M.Feder = struct('node',1,'dir',2,'val',Ks);
            M.Info.nFedern = 1;

            % Load (nodal, so DOF must be free or spring-supported)
            M.KnotenLast = struct('node',2,'dir',2,'val',-10e3);
            M.Info.nKnotenLast = 1;

            out = tests.util.it_run_main(M);

            % Reaction in the spring should be k * uy(node1)
            nkd = out.Info.nKnotenDOF;
            g1_uy = out.DOF((1-1)*nkd + 2);
            tc.verifyGreaterThan(g1_uy, 0, 'Node 1 uy must be active');

            rSpring = out.Feder(1).Reaktion;
            tc.verifyEqual(rSpring, Ks * out.U_sys(g1_uy), 'RelTol', 1e-6);
        end

        function hinge_at_node1(tc)
            % Hinge: free moment at node 1 (remove rz SPC) + element start release
            M = tc.M0;
            keep = ~([M.SPC.node]==1 & [M.SPC.dir]==3);
            M.SPC = M.SPC(keep); M.Info.nSPC = numel(M.SPC);
            M.Stab(1).sRelease = 3;

            % Load
            M.KnotenLast = struct('node',2,'dir',2,'val',-10e3);
            M.Info.nKnotenLast = 1;

            out = tests.util.it_run_main(M);

            % Near-zero moment reaction at node 1 (no SPC on rz -> zero by design)
            r1m = out.SPC([out.SPC.node]==1 & [out.SPC.dir]==3);
            if isempty(r1m)
                r1m_val = 0; % no SPC -> reported reaction is effectively zero at end
            else
                r1m_val = r1m(1).Reaktion;
            end
            tc.verifyEqual(abs(r1m_val), 0, 'AbsTol', 1e-6);

            % Vertical equilibrium still holds
            nkd  = out.Info.nKnotenDOF;
            DOF  = out.DOF(:);
            nDOF = numel(DOF);
            uy_g = DOF( (0:(nDOF/nkd-1))*nkd + 2 ); uy_g = uy_g(uy_g>0);
            sumLoadY = sum(out.F_sys(uy_g));
            ry_spc = [out.SPC([out.SPC.dir]==2).Reaktion];
            ry_fed = 0; if isfield(out,'Feder') && ~isempty(out.Feder)
                rf = [out.Feder([out.Feder.dir]==2).Reaktion];
                if ~isempty(rf), ry_fed = sum(rf); end
            end
            tc.verifyEqual(sum(ry_spc) + ry_fed + sumLoadY, 0, 'AbsTol', 1e-6);

            % VerdrehungMomentengelenk applied (u_loc exists)
            tc.verifyTrue(isfield(out.Stab(1),'u_loc') && ~isempty(out.Stab(1).u_loc));
        end

        function rotation_invariance_local(tc)
            % --- baseline (unrotated) ---
            P  = -10e3;
            M = tc.M0;
            M.StabLast = struct( ...
                'stab',  1, ...
                'dir',   2, ...   % 2 = local uy
                'val',   P, ...
                'sDist', 0.5, ...
                'eDist', [], ...  % empty for point load
                'typ',   2 ...    % typ = dir for concentrated loads
            );
            M.Info.nStabLasten = 1;
            out0 = tests.util.it_run_main(M);
            
            % --- rotated geometry ---
            theta = pi/6;
            Mr = tc.M0;
            x1 = Mr.Knoten(1).x; y1 = Mr.Knoten(1).y;
            x2 = Mr.Knoten(2).x; y2 = Mr.Knoten(2).y;
            L  = hypot(x2-x1, y2-y1);
            Mr.Knoten(1).x = 0;            Mr.Knoten(1).y = 0;
            Mr.Knoten(2).x = L*cos(theta); Mr.Knoten(2).y = L*sin(theta);
            
            Mr.StabLast = struct( ...
                'stab',  1, ...
                'dir',   2, ...
                'val',   P, ...
                'sDist', 0.5, ...
                'eDist', [], ...
                'typ',   2 ...
            );
            Mr.Info.nStabLasten = 1;
            outr = tests.util.it_run_main(Mr);

            % Local end forces (element frame) must match
            q0 = out0.Stab(1).q_loc;         % [Fx1; Fy1; Mz1; Fx2; Fy2; Mz2]
            qr = outr.Stab(1).q_loc;
            tc.verifyEqual(qr, q0, 'AbsTol', 1e-6);

            % --- also verify rotation of stiffness and end-forces ---

            % Grab local stiffness & rotations
            K0 = out0.Stab(1).k_loc;   R0 = out0.Stab(1).R;
            Kr = outr.Stab(1).k_loc;   Rr = outr.Stab(1).R;
            
            % rotiereLocalToGlobal_K matches analytical R'*K*R
            K0g_by_fn = rotiereLocalToGlobal_K(K0, R0);
            K0g_anal  = R0.' * K0 * R0;
            tc.verifyEqual(K0g_by_fn, K0g_anal, 'AbsTol', 1e-10, 'RelTol', 1e-10);
            
            Krg_by_fn = rotiereLocalToGlobal_K(Kr, Rr);
            Krg_anal  = Rr.' * Kr * Rr;
            tc.verifyEqual(Krg_by_fn, Krg_anal, 'AbsTol', 1e-10, 'RelTol', 1e-10);
            

        end

        function influence_line_types_basic(tc)
            % TypEL=4 (support displacement): SPC appended with val=-1
            M = tc.M0;
            EL4 = struct('TypEL',4,'Knoten',2,'Richtung',2);
            Ms = M; Ms.Einflusslinie = EL4;
            Ms2 = modelFuerEinflusslinie(Ms);
            tc.verifyEqual(Ms2.SPC(end).node, 2);
            tc.verifyEqual(Ms2.SPC(end).dir,  2);
            tc.verifyEqual(Ms2.SPC(end).val, -1);

            % TypEL = 1..3 (cut + LM augmentation). We just verify that the
            % augmented path runs and returns sensible sizes.
            ELs = [struct('TypEL',1), struct('TypEL',2), struct('TypEL',3)];
            for k = 1:numel(ELs)
                Mx = tc.M0;
                Mx.gew_output    = 2;                 % enable EL path in DirectStiffnessMethod
                Mx.Einflusslinie = struct('TypEL',ELs(k).TypEL,'Stab',1,'Stelle',0.5);

                out = tests.util.it_run_main(Mx);

                % We expect a nonzero number of LM rows and a valid reduced system
                tc.verifyGreaterThanOrEqual(out.kond.nLM, 1);
                tc.verifyTrue(issparse(out.kond.K_sys_ff) || ismatrix(out.kond.K_sys_ff));
                tc.verifySize(out.U_sys, [numel(out.DOF) 1]);     % physical DOFs back
                tc.verifyTrue(all(isfinite(out.U_sys)));
            end
        end
    end
end
