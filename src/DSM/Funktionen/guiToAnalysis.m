function A = guiToAnalysis(G)
% Map GUI struct to the analysis struct expected by extractFields()

A.Knoten = arrayfun(@(n) struct('x', n.x, 'y', n.y), G.Nodes);
A.Stab   = arrayfun(@(m) struct( ...
    'sNode', m.sNode, 'eNode', m.eNode, ...
    'E', m.E, 'A', m.A, 'Iy', m.Iy, ...
    'sRelease', m.sRelease, 'eRelease', m.eRelease ...
), G.Members);

A.SPC = arrayfun(@(s) struct('node', s.node, 'dir', s.dir, 'val', s.val), G.Supports);

A.Feder = arrayfun(@(f) struct('node', f.node, 'dir', f.dir, 'val', f.k), G.Springs);

A.KnotenLast = arrayfun(@(l) struct('node', l.node, 'dir', l.dir, 'val', l.val), G.NodeLoads);

A.StabLast = arrayfun(@(q) struct( ...
    'stab', q.member, 'typ', q.type, 'val', q.val, 'x', q.xSpan ...
), G.MemberLoads);

A.Info.nKnotenDOF = 3;    % keep your constants here
% (add any other small fields your extractFields/DSM expects)
end
