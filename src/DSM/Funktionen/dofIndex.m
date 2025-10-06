function idx = dofIndex(node, dir)
% dir: 1=x, 2=y, 3=phi
    idx = (node-1)*3 + dir;
end