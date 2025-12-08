function drawOriginalNodes(Knoten)
% Zeichnet nur die Knoten als Punkte (für Live-Viewer)

if isempty(Knoten)
    return;
end

KnotenKORD = table2array(struct2table(Knoten));
x = KnotenKORD(:, 1);
y = KnotenKORD(:, 2);

holdState = ishold;
hold on;
plot(x, y, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
if ~holdState
    hold off;
end
end
