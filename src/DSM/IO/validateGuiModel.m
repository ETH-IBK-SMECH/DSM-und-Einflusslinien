function [ok, issues] = validateGuiModel(gui)

% TODO

issues = {};
if isempty(gui.Nodes), issues{end+1} = 'Define at least one node.'; end
% minimal examples:
for k = 1:numel(gui.Members)
    m = gui.Members(k);
    if m.sNode == m.eNode
        issues{end+1} = sprintf('Member %d has identical start/end node.', k);
    end
end
ok = isempty(issues);
if any([gui.Members.E] <= 0), issues{end+1} = 'Each member needs E>0.'; end
if any([gui.Members.A] <= 0), issues{end+1} = 'Each member needs A>0.'; end
if any([gui.Members.Iy] <= 0), issues{end+1} = 'Each member needs Iy>0.'; end
end
