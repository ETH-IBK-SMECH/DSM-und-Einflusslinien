function K_loc = kondensiereK(Klv, activeDOF)
% Condense local stiffness by eliminating internal DOFs (no inv).
% Keeps original size; writes Schur complement into the kept block.

    n   = numel(activeDOF);
    K_loc = zeros(n, 'like', Klv);     % preserve class (double/single)
    e   = logical(activeDOF);          % kept (external)
    i   = ~e;                          % eliminated (internal)

    if ~any(i)                         % nothing to condense
        K_loc(e,e) = Klv(e,e);
        return
    end

    K_loc(e,e) = Klv(e,e) - Klv(e,i) * (Klv(i,i) \ Klv(i,e));
end
