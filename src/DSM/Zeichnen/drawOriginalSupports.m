function drawOriginalSupports(ax, Knoten, Staebe, Lager, meanL, nStaebe)
% Zeichnet Lager gemäss Lager-Typ

for i = 1:size(Lager, 1)
    type = Lager.Lagerung(i);
    node = Lager.Knoten(i);
    centre = [Knoten(node).xPos; Knoten(node).yPos];

    switch type
        case 1
            % now it is always in the correct direction even if multiple
            % beams meet at the support
            u = [0; 0];   % summed unit direction vectors away from the node

            for e = 1:nStaebe
                sK = Staebe(e).StartKnoten;
                eK = Staebe(e).EndKnoten;

                xs = [Knoten(sK).xPos; Knoten(sK).yPos];
                xe = [Knoten(eK).xPos; Knoten(eK).yPos];

                if node == sK
                    v = xe - xs;     % away from node
                elseif node == eK
                    v = xs - xe;     % away from node
                else
                    continue;
                end

                nv = norm(v);
                if nv > 0
                    u = u + v / nv;
                end
            end

            if norm(u) < 1e-12
                % fallback: use first connected member orientation (prevents errors)
                stabnodes = [Staebe.StartKnoten; Staebe.EndKnoten]';
                stabnodeidx = find(stabnodes == node, 1, 'first');

                if isempty(stabnodeidx)
                    R = eye(2);
                elseif stabnodeidx <= nStaebe
                    R = Staebe(stabnodeidx).R(1:2, 1:2);
                else
                    stabnodeidx = stabnodeidx - nStaebe;
                    R = [-1 0; 0 -1] * Staebe(stabnodeidx).R(1:2, 1:2);
                end
            else
                u = u / norm(u);      % unit bisector direction
                c = u(1); s = u(2);
                R = [c s; -s c]; 
            end

            drawLager(ax, type, centre, R, 0.6*meanL, node);

        case {2, 3, 4}
            R = eye(2);
            drawLager(ax, type, centre, R, 0.5*meanL, node);

        case {5, 6}
            stabnodes = [Staebe.StartKnoten; Staebe.EndKnoten]';
            stabnodeidx = find(stabnodes == node);
            if stabnodeidx / nStaebe <= 1
                R = eye(2);
            else
                R = [-1, 0; 0, -1];
            end
            drawLager(ax, type, centre, R, 0.6*meanL, node);
    end
end
end
